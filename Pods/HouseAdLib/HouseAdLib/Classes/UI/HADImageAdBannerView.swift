//
//  HADImageAdView.swift
//  Ad
//
//  Created by Kevin on 2019/6/20.
//

import UIKit
import SwiftyJSON
import SDWebImage

class HADImageAdBannerView: UIView {
    
    var adTappedAction: ((HADImageAdBannerView) -> Void)?
    
    var currentAdItem: HADImageBannerAd.AdItem? {
        didSet {
            self.setup()
        }
    }

    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var testLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .white
        label.isHidden = true
        label.textAlignment = .center
        label.text = "Test"
        return label
    }()
    
    init() {
        super.init(frame: .zero)
        self.addSubviews(imageView, testLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        testLabel.snp.makeConstraints { (make) in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(testLabel.snp.height)
        }
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(tapped))
        self.addGestureRecognizer(tapGR)
        
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Action

extension HADImageAdBannerView {
    @objc func tapped() {
        if let link = currentAdItem?.link?.toURL() {
            UIApplication.shared.openURL(link)
            self.adTappedAction?(self)
        }
    }
}

// MARK: - Private

extension HADImageAdBannerView {
    func setup() {
        self.testLabel.isHidden = (currentAdItem?.isTestAd != true)
        
        if let url = self.currentAdItem?.image?.toURL(), let _ = self.currentAdItem?.link?.toURL() {
            self.imageView.sd_setImage(with: url)
            self.isUserInteractionEnabled = true
        }
        else {
            self.imageView.image = nil
            self.isUserInteractionEnabled = false
        }
    }
}
