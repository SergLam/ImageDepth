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

class MainVC: UIViewController {

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
    
    func didTapApplyButton() -> CGImageDestination? {
        
        guard let image = ImageLoader.loadImageFromBundle(imageName: "test", fileExtension: "jpg"), let cgImage = image.cgImage else {
            assertionFailure("Unable to load image")
            return nil
        }

//        let pixelBuffer = image.pixelBufferFromImage()
        let pixelBuffer = DepthReader.depthDataMap(imageName: "test", imageExtension: "jpg")!
        
        let cfData = CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let cfDictionary = [kCGImageAuxiliaryDataInfoData: cfData]
        
        guard let cfURL = Bundle.main.url(forResource: "test", withExtension: "jpg") as CFURL? else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
        do {
            guard let depthData = image.depthData() else {
                assertionFailure("Unable to get depth data")
                return nil
            }
            
            guard let destination = CGImageDestinationCreateWithURL(cfURL, kCGImageAuxiliaryDataInfoData, 1, nil) else {
                assertionFailure("Unable to create image destination")
                return nil
            }
            
            // Add an image to the destination.
            CGImageDestinationAddImage(destination, cgImage, cfDictionary as CFDictionary)
            
            // Use AVDepthData to get the auxiliary data dictionary.
            var auxDataType :NSString?
            let auxData = depthData.dictionaryRepresentation(forAuxiliaryDataType: &auxDataType)
            
            // Add auxiliary data to the image destination.
            CGImageDestinationAddAuxiliaryDataInfo(destination, auxDataType!, auxData! as CFDictionary)
            
            if CGImageDestinationFinalize(destination) {
                debugPrint(destination)
                return destination
            } else {
                return nil
            }
        } catch {
            assertionFailure(error.localizedDescription)
            return nil
        }
        
      
        
//        guard let depthData = DepthReader.imageToDepthData(imageName: "zbuffer", imageExtension: "jpg") else {
//            assertionFailure("Unable to get image depth data")
//            return
//        }
//        debugPrint(depthData)

//        depthDataMap.normalize()
//
//        let ciImage = CIImage(cvPixelBuffer: depthDataMap)
//        let depthDataMapImage = UIImage(ciImage: ciImage)
//        contentView.updateDepthImage(with: depthDataMapImage)
    }
    
    func didTapExportButton() {
        
    }
    
    
}

