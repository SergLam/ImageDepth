//
//  PHContentEditingInput+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/18/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import Photos

extension PHContentEditingInput {
    
    func createDepthImage() -> CIImage {
        guard let url = fullSizeImageURL else { fatalError() }
        return CIImage(contentsOf: url, options: [CIImageOption.auxiliaryDisparity : true])!
    }
    
    func createImageSource() -> CGImageSource {
        guard let url = fullSizeImageURL else { fatalError() }
        return CGImageSourceCreateWithURL(url as CFURL, nil)!
    }
}
