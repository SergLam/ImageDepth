//
//  UIImage+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit
import AVFoundation

extension UIImage {
    
    func depthData() -> AVDepthData? {
        
        guard let data = self.pngData() else {
            assertionFailure("Unable to get jpeg data")
            return nil
        }
        guard let imageSource = CGImageSourceCreateWithData(data as CFData, nil)
            else {
                assertionFailure("Unable to get cfdata")
                return nil
        }
        guard let auxiliaryData = CGImageSourceCopyAuxiliaryDataInfoAtIndex(imageSource, 0, kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable: Any]
            else {
                assertionFailure("Unable to get auxiliaryData")
                return nil
        }
        guard let depthData = try? AVDepthData(fromDictionaryRepresentation: auxiliaryData)
            else {
                assertionFailure("Unable to get depthData")
                return nil
        }
        return depthData
    }
    
    convenience init?(ciImage: CIImage?) {
        
        guard let ciImage = ciImage else {
            return nil
        }
        
        self.init(ciImage: ciImage)
    }
    
    func pixelBufferFromImage() -> CVPixelBuffer {
        
        let ciimage = CIImage(image: self)
        //let cgimage = convertCIImageToCGImage(inputImage: ciimage!)
        let tmpcontext = CIContext(options: nil)
        let cgimage =  tmpcontext.createCGImage(ciimage!, from: ciimage!.extent)
        
        let cfnumPointer = UnsafeMutablePointer<UnsafeRawPointer>.allocate(capacity: 1)
        let cfnum = CFNumberCreate(kCFAllocatorDefault, .intType, cfnumPointer)
        let keys: [CFString] = [kCVPixelBufferCGImageCompatibilityKey, kCVPixelBufferCGBitmapContextCompatibilityKey, kCVPixelBufferBytesPerRowAlignmentKey]
        let values: [CFTypeRef] = [kCFBooleanTrue, kCFBooleanTrue, cfnum!]
        let keysPointer = UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        let valuesPointer =  UnsafeMutablePointer<UnsafeRawPointer?>.allocate(capacity: 1)
        keysPointer.initialize(to: keys)
        valuesPointer.initialize(to: values)
        
        let options = CFDictionaryCreate(kCFAllocatorDefault, keysPointer, valuesPointer, keys.count, nil, nil)
        
        let width = cgimage!.width
        let height = cgimage!.height
        
        var pxbuffer: CVPixelBuffer?
        // if pxbuffer = nil, you will get status = -6661
        var status = CVPixelBufferCreate(kCFAllocatorDefault, width, height,
                                         kCVPixelFormatType_32BGRA, options, &pxbuffer)
        status = CVPixelBufferLockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        
        let bufferAddress = CVPixelBufferGetBaseAddress(pxbuffer!);
        
        
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB();
        let bytesperrow = CVPixelBufferGetBytesPerRow(pxbuffer!)
        let context = CGContext(data: bufferAddress,
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: bytesperrow,
                                space: rgbColorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedFirst.rawValue | CGBitmapInfo.byteOrder32Little.rawValue);
        context?.concatenate(CGAffineTransform(rotationAngle: 0))
        context?.concatenate(__CGAffineTransformMake( 1, 0, 0, -1, 0, CGFloat(height) )) //Flip Vertical
        //        context?.concatenate(__CGAffineTransformMake( -1.0, 0.0, 0.0, 1.0, CGFloat(width), 0.0)) //Flip Horizontal
        
        
        context?.draw(cgimage!, in: CGRect(x:0, y:0, width:CGFloat(width), height:CGFloat(height)));
        status = CVPixelBufferUnlockBaseAddress(pxbuffer!, CVPixelBufferLockFlags(rawValue: 0));
        return pxbuffer!;
        
    }
    
    public convenience init?(pixelBuffer: CVPixelBuffer) {
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let pixelBufferWidth = CGFloat(CVPixelBufferGetWidth(pixelBuffer))
        let pixelBufferHeight = CGFloat(CVPixelBufferGetHeight(pixelBuffer))
        let imageRect:CGRect = CGRect(x: 0, y: 0, width: pixelBufferWidth, height: pixelBufferHeight)
        let ciContext = CIContext.init()
        guard let cgImage = ciContext.createCGImage(ciImage, from: imageRect) else {
            return nil
        }
        self.init(cgImage: cgImage)
    }
    
    func adjustedCIImage(targetSize: CGSize) -> CIImage? {
        guard let cgImage = cgImage else { fatalError() }
        
        let imageWidth = cgImage.width
        let imageHeight = cgImage.height
        
        // Video preview is running at 1280x720. Downscale background to same resolution
        let videoWidth = Int(targetSize.width)
        let videoHeight = Int(targetSize.height)
        
        let scaleX = CGFloat(imageWidth) / CGFloat(videoWidth)
        let scaleY = CGFloat(imageHeight) / CGFloat(videoHeight)
        
        let scale = min(scaleX, scaleY)
        
        // crop the image to have the right aspect ratio
        let cropSize = CGSize(width: CGFloat(videoWidth) * scale, height: CGFloat(videoHeight) * scale)
        let croppedImage = cgImage.cropping(to: CGRect(origin: CGPoint(
            x: (imageWidth - Int(cropSize.width)) / 2,
            y: (imageHeight - Int(cropSize.height)) / 2), size: cropSize))
        
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(data: nil,
                                      width: videoWidth,
                                      height: videoHeight,
                                      bitsPerComponent: 8,
                                      bytesPerRow: 0,
                                      space: colorSpace,
                                      bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
                                        assertionFailure("failed to create context")
                                        return nil
        }
        
        let bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: videoWidth, height: videoHeight))
        context.clear(bounds)
        
        context.draw(croppedImage!, in: bounds)
        
        guard let scaledImage = context.makeImage() else {
            assertionFailure("failed to create scaledImage")
            return nil
        }
        
        return CIImage(cgImage: scaledImage)
    }
    
    
}
