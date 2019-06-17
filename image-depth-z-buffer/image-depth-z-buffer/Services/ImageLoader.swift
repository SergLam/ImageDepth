//
//  ImageLoader.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit

class ImageLoader {
    
    static func loadImageFromBundle(imageName: String, fileExtension: String) -> UIImage? {
        
        guard let fileURL = Bundle.main.url(forResource: imageName, withExtension: fileExtension)  else {
            assertionFailure("Unable to locate file")
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            let image = UIImage(data: data)
            return image
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    static func loadDataFromBundle(fileName: String, fileExtension: String) -> Data? {
        
        guard let fileURL = Bundle.main.url(forResource: fileName, withExtension: fileExtension)  else {
            assertionFailure("Unable to locate file")
            return nil
        }
        do {
            let data = try Data(contentsOf: fileURL, options: .mappedIfSafe)
            return data
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
    }
    
    
    
}
