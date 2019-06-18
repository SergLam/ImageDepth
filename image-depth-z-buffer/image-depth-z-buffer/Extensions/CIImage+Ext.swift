//
//  CIImage+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit
import CoreImage

extension CIImage {
    
    convenience init?(image: UIImage?) {
        
        guard let image = image else {
            return nil
        }
        
        self.init(image: image)
    }
    
    convenience init?(cvPixelBuffer: CVPixelBuffer?) {
        
        guard let cvPixelBuffer = cvPixelBuffer else {
            return nil
        }
        
        self.init(cvPixelBuffer: cvPixelBuffer)
    }
    
    convenience init?(cgImage: CGImage?) {
        
        guard let cgImage = cgImage else {
            return nil
        }
        
        self.init(cgImage: cgImage)
    }
    
    func resizeToSameSize(as anotherImage: CIImage) -> CIImage {
        let size1 = extent.size
        let size2 = anotherImage.extent.size
        let transform = CGAffineTransform(scaleX: size2.width / size1.width, y: size2.height / size1.height)
        return transformed(by: transform)
    }
    
    func createCGImage() -> CGImage {
        let context = CIContext(options: nil)
        guard let cgImage = context.createCGImage(self, from: extent) else {
            fatalError()
        }
        return cgImage
    }
    
}
