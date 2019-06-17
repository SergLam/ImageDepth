//
//  URL+Ext.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import Foundation

extension URL {
    
    static func documentsURL(fileName: String, fileExtention: String) -> URL {
       
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileName = "\(fileName).\(fileExtention)"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        return fileURL
    }
    
}
