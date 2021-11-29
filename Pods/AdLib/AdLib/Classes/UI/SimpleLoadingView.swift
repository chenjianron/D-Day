//
//  LoadingView.swift
//  TubeMusicX
//
//  Created by lcf on 20/09/2017.
//  Copyright © 2017 SOFTN. All rights reserved.
//

import UIKit
import SnapKit

public class SimpleLoadingView: UIView {
    
    public lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    public lazy var logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 21.0
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    public lazy var loadingLabel: UILabel = {
        let label = UILabel()
        label.text = "   " + "Loading..."
        label.textAlignment = .center
        label.textColor = UIColor.init(hex: 0x333333)
        label.font = UIFont.systemFont(ofSize: 23)
        return label
    }()
    
    public convenience init(logo: UIImage?) {
        self.init(frame: .zero)
        self.logoImageView.image = logo
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setupUI()
        self.setupConstraints()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupUI() {
        self.backgroundColor = .white
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.logoImageView)
        self.addSubview(self.loadingLabel)
    }
    
    func setupConstraints() {
        
        self.backgroundImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        self.logoImageView.snp.makeConstraints { (make) in
            let width = min(UIScreen.main.bounds.size.width * 0.2, 120)
            make.width.height.equalTo(width)
            make.centerX.equalToSuperview()
            make.top.equalTo(self.snp.bottom).multipliedBy(0.3)
        }
        
        self.loadingLabel.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(30)
            make.top.equalTo(self.logoImageView.snp.bottom).offset(15)
        }
    }
}
