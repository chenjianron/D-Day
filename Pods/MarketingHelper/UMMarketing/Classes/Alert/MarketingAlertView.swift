//
//  MarketingAlert.swift
//  MarketingHelper
//
//  Created by Endless Summer on 2020/9/18.
//

import Foundation
import SDWebImage
import SnapKit

class MarketingAlertView: UIView {
    
    lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        return button
    }()
    
    private lazy var imageView: UIImageView = {
        let view = UIImageView(frame: .zero)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        view.textAlignment = .center
        view.numberOfLines = 0
        return view
    }()
    
    private lazy var messageLabel: UILabel = {
        let view = UILabel(frame: .zero)
        view.numberOfLines = 0
        return view
    }()
    
    lazy var actionButton: UIButton = {
        let button = UIButton(type: .custom)
        button.layer.masksToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
        setupData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateModel(_ model: MarketingAlertModel) {
        imageView.sd_setImage(with: model.imageURL, placeholderImage: nil)
        
        closeButton.setImage(closeImage(color: model.closeButtonColor), for: .normal)
        
        titleLabel.textColor = model.titleColor
        titleLabel.text = model.title
        
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        style.lineSpacing = 14
        
        messageLabel.attributedText = NSAttributedString(string: model.message,
                                                         attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .regular),
                                                                      NSAttributedString.Key.foregroundColor: UIColor.init(hex: 0x333333),
                                                                      NSAttributedString.Key.paragraphStyle: style])
        
        let attributedString = NSAttributedString(string: model.buttonTitle,
                                                  attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .regular),
                                                               NSAttributedString.Key.foregroundColor: model.buttonColor])
        
        actionButton.setAttributedTitle(attributedString, for: .normal)
        
        actionButton.setBackgroundImage(UIImage(color: model.buttonBackgroundColor), for: .normal)
        
        imageView.snp.remakeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(model.imageRatio)
        }
        
        actionButton.layer.cornerRadius = CGFloat(model.buttonCornerRadius)
    }
}

private extension MarketingAlertView {
    func setupUI() {
        let view = self
        view.backgroundColor = UIColor.white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 10
        
        addSubviews(imageView, closeButton, titleLabel, messageLabel, actionButton)
        
        imageView.snp.makeConstraints { (make) in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(imageView.snp.width).multipliedBy(0.628)
        }
        
        closeButton.snp.makeConstraints { (make) in
            make.right.top.equalToSuperview()
            make.width.height.equalTo(22 + 14*2)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(16)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.left.right.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp.bottom).offset(14)
        }
        
        actionButton.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview().inset(30)
            make.top.equalTo(messageLabel.snp.bottom).offset(30)
            make.height.equalTo(42)
            make.bottom.equalToSuperview().inset(30)
        }
    }
    
    func setupData() {
        
    }
    
    private func closeImage(color: UIColor) -> UIImage? {
        let rect = CGRect(origin: .zero, size: .init(width: 12, height: 12))
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0)
        
        let strokeColor2 = color
        
        let stroke1Path = UIBezierPath()
        stroke1Path.move(to: CGPoint(x: 1, y: 1))
        stroke1Path.addLine(to: CGPoint(x: 11, y: 11))
        strokeColor2.setStroke()
        stroke1Path.lineWidth = 2
        stroke1Path.miterLimit = 4
        stroke1Path.stroke()

        let stroke3Path = UIBezierPath()
        stroke3Path.move(to: CGPoint(x: 1, y: 11))
        stroke3Path.addLine(to: CGPoint(x: 11, y: 1))
        strokeColor2.setStroke()
        stroke3Path.lineWidth = 2
        stroke3Path.miterLimit = 4
        stroke3Path.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image?.scaled(to: rect.size, scale: 0)
        
    }

}
