//
//  AppCell.swift
//  Face
//
//  Created by Kevin on 2019/8/14.
//  Copyright © 2019 Kevin. All rights reserved.
//

import UIKit
import SDWebImage
import SwiftyJSON

class SettingsFeaturedAppCell: UITableViewCell {

    lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 10
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 0.5
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.minimumScaleFactor = 0.7
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        
        self.contentView.addSubviews(iconImageView, titleLabel)
        
        iconImageView.snp.makeConstraints { (make) in
            make.size.equalTo(28)
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconImageView.snp.right).offset(12)
            make.right.equalToSuperview().offset(-20)
            make.centerY.height.equalTo(iconImageView)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
