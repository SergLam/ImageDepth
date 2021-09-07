//
//  PHAsset+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/18/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import Photos
import UIKit

extension PHAsset {
    
    class func fetchAssetsWithDepth() -> [PHAsset] {
        let resultCollections = PHAssetCollection.fetchAssetCollections(
            with: .smartAlbum,
            subtype: .smartAlbumDepthEffect,
            options: nil)
        var assets: [PHAsset] = []
        resultCollections.enumerateObjects({ collection, index, stop in
            let result = PHAsset.fetchAssets(in: collection, options: nil)
            result.enumerateObjects({ asset, index, stop in
                assets.append(asset)
            })
        })
        return assets
    }
    
    func requestColorImage(handler: @escaping (UIImage?) -> Void) {
        PHImageManager.default().requestImage(for: self, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: nil) { (image, info) in
            handler(image)
        }
    }
    
    func hasPortraitMatte() -> Bool {
        var result: Bool = false
        let semaphore = DispatchSemaphore(value: 0)
        requestContentEditingInput(with: nil) { contentEditingInput, info in
            let imageSource = contentEditingInput?.createImageSource()
            result = imageSource?.getMatteData() != nil
            semaphore.signal()
        }
        semaphore.wait()
        return result
    }
}


