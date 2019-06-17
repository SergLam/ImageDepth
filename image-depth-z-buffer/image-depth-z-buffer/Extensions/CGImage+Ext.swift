//
//  CGImage+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import CoreVideo
import CoreGraphics

extension CGImage {
  
  func pixelBuffer() -> CVPixelBuffer? {
    
    var pxbuffer: CVPixelBuffer?
    
    guard let dataProvider = dataProvider else {
      return nil
    }
    
    let dataFromImageDataProvider = CFDataCreateMutableCopy(kCFAllocatorDefault, 0, dataProvider.data)
    
    CVPixelBufferCreateWithBytes(
      kCFAllocatorDefault,
      width,
      height,
      kCVPixelFormatType_32ARGB,
      CFDataGetMutableBytePtr(dataFromImageDataProvider),
      bytesPerRow,
      nil,
      nil,
      nil,
      &pxbuffer
    )
    
    return pxbuffer
  }
}
