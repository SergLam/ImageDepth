//
//  ImageSaver.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import Foundation
import AVFoundation
import Photos
import UIKit

final class ImageSaver {
    
    static func saveToPhotosLibrary(_ imageURL: URL) {
        
            DispatchQueue.main.async {
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: imageURL)
                
            }, completionHandler: { (success, error) in
                
                DispatchQueue.main.async {
                    guard let vc = UIApplication.topViewController() else {
                        return
                    }
                    guard let error = error else {
                        AlertPresenter.showSuccessMessage(at: vc, message: "Image saved \(imageURL.lastPathComponent)")
                        return
                    }
                    AlertPresenter.showError(at: vc, error: error.localizedDescription)
                }
               
            })
                
        }
    }
    
    static func saveHeifImage(_ cgImage: CGImage) {
        
        let docsurl = try! FileManager.default.url(for:.documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let url = docsurl.appendingPathComponent("output.HEIC")
        
        guard let destination = CGImageDestinationCreateWithURL(url as CFURL, AVFileType.heic as CFString, 1, nil) else {
            assertionFailure("unable to create CGImageDestination")
            return
        }
        
        CGImageDestinationAddImage(destination, cgImage, nil)
        
        if (CGImageDestinationFinalize(destination)) {
            
            PHPhotoLibrary.shared().performChanges({
                
                let create : PHAssetCreationRequest = PHAssetCreationRequest.forAsset()
                
                create.addResource(with:.photo , fileURL: url, options: nil)
                
            }, completionHandler: { (success, error) in
                
                guard let vc = UIApplication.topViewController() else {
                    return
                }
                guard let error = error else {
                    AlertPresenter.showSuccessMessage(at: vc, message: "Image saved \(url.absoluteString)")
                    return
                }
                AlertPresenter.showError(at: vc, error: error.localizedDescription)
                
            })
            
        }
    }
    
}
