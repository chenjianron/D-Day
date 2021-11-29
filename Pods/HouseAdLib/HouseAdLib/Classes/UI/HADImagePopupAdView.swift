//
//  HADImagePopupAdViewController.swift
//  AdLib
//
//  Created by Kevin on 2019/12/12.
//

import UIKit
import SwiftyJSON
import SDWebImage
import SnapKit

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

class HADImagePopupAdView: UIView {

    var adTappedAction: ((HADImagePopupAdView) -> Void)?
    
    var adItem: HADImagePopupAd.AdItem
    
    init(adItem: HADImagePopupAd.AdItem) {
        self.adItem = adItem
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = false
        imageView.layer.cornerRadius = 4
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(adTapped))
        imageView.addGestureRecognizer(tapGR)
        
        return imageView
    }()
    
    var buttonLabel: UILabel?

    lazy var cancelButton: UIButton = {
        let button = UIButton()
        let closeIcon = UIImage.init(named: "HADClose", in: Bundle(for: HADImagePopupAdView.self), compatibleWith: nil)
        button.setImage(closeIcon, for: .normal)
        button.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        button.alpha = 0.9
        return button
    }()
    
    lazy var blurView: UIView = {
        let effect = UIBlurEffect(style: .dark)
        let effectView = UIVisualEffectView(effect: effect)
        return effectView
    }()
}

// MARK: - Action

extension HADImagePopupAdView {
    @objc func adTapped() {
        if let url = adItem.link?.toURL() {
            UIApplication.shared.openURL(url)
            self.adTappedAction?(self)
        }
    }
    
    @objc func cancel() {
        self.removeFromSuperview()
    }
}


// MARK: - Private

extension HADImagePopupAdView {
    func setupUI() {
        self.backgroundColor = .clear
        self.addSubview(blurView)
        self.addSubview(imageView)
        self.addSubview(cancelButton)
        
        if let imageURL = self.adItem.image?.toURL() {
            self.imageView.sd_setImage(with: imageURL) { (image, _, _, _) in
                if image != nil {
                    self.imageView.isUserInteractionEnabled = true
                    self.setupConstraints()
                }
            }
        }
        
        buttonLabel = UILabel()
        buttonLabel?.textAlignment = .center
        buttonLabel?.font = UIFont.systemFont(ofSize: 14)
        buttonLabel?.adjustsFontSizeToFitWidth = true
        buttonLabel?.text = adItem.btnText
        buttonLabel?.textColor = adItem.btnTextColor
        buttonLabel?.backgroundColor = adItem.btnColor
        buttonLabel?.layer.cornerRadius = 4
        buttonLabel?.layer.masksToBounds = true
        self.addSubview(buttonLabel!)
        
        self.setupConstraints()
    }
    
    func setupConstraints() {
        self.blurView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.imageView.snp.remakeConstraints { (make) in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.center.equalToSuperview()
            make.height.equalTo(imageView.snp.width).dividedBy(imageRatio)
        }
        
        self.cancelButton.snp.makeConstraints { (make) in
            make.width.equalTo(40)
            make.height.equalTo(40)
            make.centerX.equalTo(self.imageView)
            make.centerY.equalTo(self.imageView.snp.bottom).offset(30)
        }
        
        self.buttonLabel?.snp.remakeConstraints({ (make) in
            make.width.equalTo(self.imageView).multipliedBy(0.8)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(self.imageView).offset(-20)
        })
    }
    
    var imageRatio: CGFloat {
        var ratio: CGFloat = 1
        if let image = self.imageView.image {
            let width = image.size.width
            let height = image.size.height
            if width > 0 && height > 0 {
                ratio = width / height
            }
        }
        
        return ratio
    }
}

