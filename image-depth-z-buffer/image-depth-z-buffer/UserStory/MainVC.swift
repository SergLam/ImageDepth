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
import MobileCoreServices

class MainVC: UIViewController {
    
    private let testImageName1 = "test"
    private let testImageExt1 = "jpg"
    
    private let testImageName2 = "realTest"
    private let testImageExt2 = "jpeg"
    
    private let testImageName3 = "original_image"
    private let testImageExt3 = "jpg"
    
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
    
    func didTapApplyButton() {
        
        let _ = addDepthToImage(imageName: testImageName1, extension: testImageExt1)
        guard let url = Bundle.main.url(forResource: testImageName1, withExtension: testImageExt1) else {
            assertionFailure("Unable to locate image file")
            return
        }
        ImageSaver.saveToPhotosLibrary(url)
    }
    
    func didTapExportButton() {
        
//        let storyboard = UIStoryboard(name: "DepthFromCameraRoll", bundle: nil)
//        guard let controller = storyboard.instantiateInitialViewController() else {fatalError()}
//        controller.title = title
//        navigationController?.pushViewController(controller, animated: true)
        addBlurEffectViaZBuffer()
    }
    
    private func addBlurEffectViaZBuffer() {
        
        guard let mainURL = Bundle.main.url(forResource: "original_image", withExtension: "jpg") else {
            assertionFailure("Unable to locate image file")
            return
        }
        guard let dispURL = Bundle.main.url(forResource: "zbuffer", withExtension: "jpg") else {
            assertionFailure("Unable to locate image file")
            return
        }
        
        let mainImage = CIImage(contentsOf: mainURL)
        let disparityImage = CIImage(contentsOf: dispURL)
        
        let filter = CIFilter(name: "CIMaskedVariableBlur", parameters: [kCIInputImageKey: mainImage])
        filter?.setValue(disparityImage, forKey: "inputMask")
        filter?.setValue(30, forKey: "inputRadius")
        
        guard let resultImage = filter?.outputImage else {
            assertionFailure("Unable to get output image")
            return
        }
        
        let context = CIContext() // Prepare for create CGImage
        guard let cgImage = context.createCGImage(resultImage, from: resultImage.extent) else {
            assertionFailure("Unable to create cg image")
            return
        }
        let uiImage = UIImage(cgImage: cgImage)
        UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
        
    }
    
    private func addDepthToImage(imageName: String, extension: String) -> CGImageDestination? {
        
        guard let image = ImageLoader.loadImageFromBundle(imageName: testImageName1,
                                                          fileExtension: testImageExt1), let cgImage = image.cgImage else {
            assertionFailure("Unable to load image")
            return nil
        }
        
        let pixelBuffer = DepthReader.depthDataMap(imageName: testImageName1, imageExtension: testImageExt1)!
        
        let cfData = CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly)
        let cfDictionary = [kCGImageAuxiliaryDataInfoData: cfData]
        
        guard let cfURL = Bundle.main.url(forResource: testImageName1, withExtension: testImageExt1) as CFURL? else {
            assertionFailure("Unable to locate image file")
            return nil
        }
        
        guard let depthData = DepthReader.depthData(imageName: testImageName1, imageExtension: testImageExt1) else {
            assertionFailure("Unable to get depth data")
            return nil
        }
        
        guard let fileData = ImageLoader.loadDataFromBundle(fileName: testImageName1, fileExtension: testImageExt1) else {
            assertionFailure("Unable to locate file")
            return nil
        }
        
        let bytes = [UInt8](fileData)
        guard let cfData1 = CFDataCreateMutable(kCFAllocatorDefault, bytes.count) else {
            assertionFailure("Unable to create mutable data")
            return nil
        }
        guard let destination = CGImageDestinationCreateWithData(cfData1, kUTTypeJPEG, 1, nil) else {
            assertionFailure("Unable to create image destination \(cfURL)")
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
            ImageSaver.saveToPhotosLibrary(cfURL as URL)
            return destination
        } else {
            return nil
        }
    }
    
    
}

