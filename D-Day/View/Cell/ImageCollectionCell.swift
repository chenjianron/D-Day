//
//  ImageCollectionCell.swift
//  D-Day
//
//  Created by GC on 2021/11/11.
//

import Toolkit

class ImageCollectionCell: UICollectionViewCell {
    
    lazy var imageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    lazy var titleLable:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        label.textColor = UIColor(hex: 0x666666)
        label.textAlignment = .justified
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    override init(frame: CGRect){
        super.init(frame:frame)
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI
extension ImageCollectionCell {
    
    func setUpUI(){
        addSubview(titleLable)
        addSubview(imageView)
    }
    
    func setUpConstraints(){
        
        titleLable.snp.makeConstraints{ make in
            make.width.equalTo(335)
            make.height.equalTo(60)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        imageView.snp.makeConstraints{ make in
            make.width.equalTo(335)
            make.height.equalTo(277)
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLable.snp.bottom).offset(16)
        }
    }

}
