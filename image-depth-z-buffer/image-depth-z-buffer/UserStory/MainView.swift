//
//  MainView.swift
//  image-depth-z-buffer
//
//  Created by Serg Liamthev on 6/17/19.
//  Copyright © 2019 serglam. All rights reserved.
//

import UIKit
import SnapKit

protocol MainViewDelegate: class {
    
    func didTapApplyButton() -> CGImageDestination?
    func didTapExportButton()
}

class MainView: UIView {
    
    weak var delegate: MainViewDelegate?
    
    private let imageSize = UIScreen.main.bounds.width / 3
    
    private let originalImageView = UIImageView()
    private let zBufferImageView = UIImageView()
    private let resultImageView = UIImageView()
    
    private let applyButton = UIButton()
    private let exportButton = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupLayout()
    }
    
    private func setupLayout() {
        backgroundColor = .white
        
        addSubview(originalImageView)
        
        originalImageView.snp.makeConstraints { (make) in
            make.top.equalTo(safeAreaLayoutGuide.snp.top).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        
        addSubview(zBufferImageView)
        
        zBufferImageView.snp.makeConstraints { (make) in
            make.top.equalTo(originalImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        
        addSubview(resultImageView)
        resultImageView.backgroundColor = .black
        resultImageView.snp.makeConstraints { (make) in
            make.top.equalTo(zBufferImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(imageSize)
        }
        
        addSubview(applyButton)
        applyButton.backgroundColor = .gray
        applyButton.setTitle("Auxiliary Depth Data", for: .normal)
        applyButton.snp.makeConstraints { (make) in
            make.top.equalTo(resultImageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        applyButton.addTarget(self, action: #selector(tapConvertButton(_:)), for: .touchUpInside)
        
        addSubview(exportButton)
        exportButton.backgroundColor = .blue
        exportButton.setTitle("Export image to Gallery", for: .normal)
        exportButton.snp.makeConstraints { (make) in
            make.top.equalTo(applyButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        exportButton.addTarget(self, action: #selector(tapExportButton(_:)), for: .touchUpInside)
        
    }
    
    @objc func tapConvertButton(_ button: UIButton) {
        
        delegate?.didTapApplyButton()
    }
    
    @objc func tapExportButton(_ button: UIButton) {
        
        delegate?.didTapExportButton()
    }
    
    func loadInitialData() {
        
        originalImageView.image = ImageLoader.loadImageFromBundle(imageName: "original_image", fileExtension: "jpg")
        zBufferImageView.image = ImageLoader.loadImageFromBundle(imageName: "zbuffer", fileExtension: "jpg")
    }
    
    func updateDepthImage(with image: UIImage) {
        
        zBufferImageView.image = image
    }
    
}
