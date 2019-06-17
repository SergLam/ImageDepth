//
//  DepthReader.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit
import AVFoundation

class DepthReader {
    
    static func depthData(imageName: String, imageExtension: String) -> AVDepthData? {
        
        guard let fileURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension) as CFURL? else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
        guard let source = CGImageSourceCreateWithURL(fileURL, nil) else {
            assertionFailure("Unable to create source")
            return nil
        }
        
        guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0,
                                                                          kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
                                                                            assertionFailure("Unable to get Auxiliary Data Info")
                                                                            return nil
        }
        
        var depthData: AVDepthData
        
        do {
            depthData = try AVDepthData(fromDictionaryRepresentation: auxDataInfo)
            return depthData
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    static func depthDataMap(imageName: String, imageExtension: String) -> CVPixelBuffer? {
        
        guard let fileURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension) as CFURL? else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
        guard let source = CGImageSourceCreateWithURL(fileURL, nil) else {
            assertionFailure("Unable to create source")
            return nil
        }
        
        guard let auxDataInfo = CGImageSourceCopyAuxiliaryDataInfoAtIndex(source, 0,
                                                                          kCGImageAuxiliaryDataTypeDisparity) as? [AnyHashable : Any] else {
                                                                            assertionFailure("Unable to get Auxiliary Data Info")
                                                                            return nil
        }
        
        var depthData: AVDepthData
        
        do {
            depthData = try AVDepthData(fromDictionaryRepresentation: auxDataInfo)
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
        
        if depthData.depthDataType != kCVPixelFormatType_DisparityFloat32 {
            depthData = depthData.converting(toDepthDataType: kCVPixelFormatType_DisparityFloat32)
        }
        
        return depthData.depthDataMap
    }
    
    static func imageToDepthData(imageName: String, imageExtension: String) -> AVDepthData? {
        
        guard let fileURL = Bundle.main.url(forResource: imageName, withExtension: imageExtension) else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
        do {
            let imageData = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            guard let imageSource = CGImageSourceCreateWithData(imageData as CFData, nil)
                else {
                    assertionFailure("Unable to get image source")
                    return nil
            }
            guard let auxiliaryData = CGImageSourceCopyAuxiliaryDataInfoAtIndex(imageSource, 0, kCGImageAuxiliaryDataTypeDepth) as? [AnyHashable: Any]
                else {
                    assertionFailure("Unable to get image Auxiliary Data")
                    return nil
            }
            guard let depthData = try? AVDepthData(fromDictionaryRepresentation: auxiliaryData)
                else {
                    assertionFailure("Unable to get image Depth Data")
                    return nil
            }
            return depthData
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
        
       
    }
    
}
