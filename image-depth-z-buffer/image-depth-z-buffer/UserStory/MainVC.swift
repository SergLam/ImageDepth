//
//  ViewController.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit
import AVFoundation
import ImageIO
import MobileCoreServices

class MainVC: UIViewController {
    
    private let testImageName1 = "test"
    private let testImageExt1 = "jpg"
    
    private let testImageName2 = "realTest"
    private let testImageExt2 = "jpeg"
    
    private let testImageName3 = "original_image"
    private let testImageExt3 = "jpg"
    
    private let bufferImageName = "zbuffer"
    private let bufferImageExt = "jpg"
    
    let contentView = MainView()
    
    override func loadView() {
        view = contentView
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        contentView.delegate = self
        contentView.loadInitialData()
    }
    
    
}

extension MainVC: MainViewDelegate {
    
    func didTapApplyButton() {
        
//        let _ = addDepthToImage(imageName: testImageName3, imageExt: testImageExt3)
//        guard let url = Bundle.main.url(forResource: testImageName1, withExtension: testImageExt1) else {
//            assertionFailure("Unable to locate image file")
//            return
//        }
//        ImageSaver.saveToPhotosLibrary(url)
    }
    
    func didTapExportButton() {
        
//        let storyboard = UIStoryboard(name: "DepthFromCameraRoll", bundle: nil)
//        guard let controller = storyboard.instantiateInitialViewController() else {fatalError()}
//        controller.title = title
//        navigationController?.pushViewController(controller, animated: true)
        
//        addBlurEffectViaZBuffer()
        
        addDepthToImage(imageName: testImageName1, imageExt: testImageExt1)
    }
    
    private func addBlurEffectViaZBuffer() {
        
        guard let mainURL = Bundle.main.url(forResource: "original_image", withExtension: "jpg") else {
            assertionFailure("Unable to locate image file")
            return
        }
        guard let dispURL = Bundle.main.url(forResource: "zbuffer", withExtension: "jpg") else {
            assertionFailure("Unable to locate image file")
            return
        }
        
        let mainImage = CIImage(contentsOf: mainURL)
        let disparityImage = CIImage(contentsOf: dispURL)
        
        let filter = CIFilter(name: "CIMaskedVariableBlur", parameters: [kCIInputImageKey: mainImage])
        filter?.setValue(disparityImage, forKey: "inputMask")
        filter?.setValue(30, forKey: "inputRadius")
        
        guard let resultImage = filter?.outputImage else {
            assertionFailure("Unable to get output image")
            return
        }
        
        let context = CIContext() // Prepare for create CGImage
        guard let cgImage = context.createCGImage(resultImage, from: resultImage.extent) else {
            assertionFailure("Unable to create cg image")
            return
        }
        let uiImage = UIImage(cgImage: cgImage)
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        
    }
    
    private func addDepthToImage(imageName: String, imageExt: String) -> CGImageDestination? {
        
        guard let image = ImageLoader.loadImageFromBundle(imageName: imageName,
                                                          fileExtension: imageExt), let ciImage = CIImage(image: image), let origCgImage = image.cgImage else {
            assertionFailure("Unable to load image")
            return nil
        }
        
        guard let zImage = ImageLoader.loadImageFromBundle(imageName: bufferImageName, fileExtension: bufferImageExt) else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
  
        
        let pixelBuffer = image.pixelBufferFromImage()
        
        let cfData = CVPixelBufferLockBaseAddress(pixelBuffer.normalize(), .readOnly)
        let cfDictionary = [kCGImageAuxiliaryDataInfoData: cfData]
        
        guard let cfURL = Bundle.main.url(forResource: imageName, withExtension: imageExt) as CFURL? else {
            assertionFailure("Unable to locate image file")
            return nil
        }
//        ImageSaver.saveToPhotosLibrary(cfURL as URL)
//        return nil
        guard let fileData = ImageLoader.loadDataFromBundle(fileName: imageName, fileExtension: imageExt) else {
            assertionFailure("Unable to locate file")
            return nil
        }

        let bytes = [UInt8](fileData)
        guard let cfData1 = CFDataCreateMutable(kCFAllocatorDefault, bytes.count) else {
            assertionFailure("Unable to create mutable data")
            return nil
        }
        guard let destination = CGImageDestinationCreateWithData(cfData1, kUTTypeJPEG, 1, nil) else {
            assertionFailure("Unable to create image destination \(cfURL)")
            return nil
        }

        guard let cgImage = zImage.cgImage, let ciZimage = CIImage(image: zImage) else {
            assertionFailure("Unable to get images")
            return nil
        }

        // Add an image to the destination.
        CGImageDestinationAddImage(destination, cgImage, cfDictionary as CFDictionary)

        // Use AVDepthData to get the auxiliary data dictionary.
        let ciContext = CIContext()
        // InfoData
        let zImageData = ciContext.jpegRepresentation(of: ciZimage, colorSpace: CGColorSpaceCreateDeviceRGB(), options: [.avDepthData: ciZimage])
        // InfoDataDescription
        let zBuffer = zImage.pixelBufferFromImage()

        let zImageDataDescription = [ kCGImagePropertyPixelFormat: CVPixelBufferGetPixelFormatType(zBuffer),
                                     kCGImagePropertyWidth: CVPixelBufferGetWidth(zBuffer),
                                     kCGImagePropertyHeight: CVPixelBufferGetHeight(zBuffer),
                                     kCGImagePropertyBytesPerRow: CVPixelBufferGetBytesPerRow(zBuffer)
            ] as [CFString : Any]
        // Metadata
        let provider = CGDataProvider(data: zImage.jpegData(compressionQuality: 1)! as CFData)!
        let source: CGImageSource = CGImageSourceCreateWithDataProvider(provider, nil)!
        let metadata: CGImageMetadata = CGImageSourceCopyMetadataAtIndex(source, 0, nil)!

        let auxData = [kCGImageAuxiliaryDataInfoData: zImageData!,
                       kCGImageAuxiliaryDataInfoDataDescription: zImageDataDescription,
                       kCGImageAuxiliaryDataInfoMetadata: metadata] as [CFString : Any]


        let auxDataType: NSString = kCGImageAuxiliaryDataTypePortraitEffectsMatte as NSString

        // Add auxiliary data to the image destination.
        CGImageDestinationAddAuxiliaryDataInfo(destination, auxDataType, auxData as CFDictionary)

        // saveAsHeif(ciImage: ciImage, url: cfURL as URL)
        ImageSaver.saveHeifImage(origCgImage)
        return nil
//        if CGImageDestinationFinalize(destination) {
//            ImageSaver.saveToPhotosLibrary(cfURL as URL)
//            return destination
//        } else {
//            return nil
//        }
        
        
    }
    
}

