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

class ImageSaver {
    
    static func saveToPhotosLibrary(_ imageURL: URL) {
        
        DispatchQueue.main.async {
            
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.creationRequestForAssetFromImage(atFileURL: imageURL)
                
            }, completionHandler: { (success, error) in
                
                guard let vc = UIApplication.topViewController() else {
                    return
                }
                guard let error = error else {
                    AlertPresenter.showSuccessMessage(at: vc, message: "Image saved \(imageURL.lastPathComponent)")
                    return
                }
                AlertPresenter.showError(at: vc, error: error.localizedDescription)
            })
        }
        
    }
    
}
