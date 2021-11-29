//
//  TextFieldCollectionViewCell.swift
//  D-Day
//
//  Created by GC on 2021/11/8.
//

import Toolkit

class TextFieldCollectionViewCell: UICollectionViewCell {
    
    lazy var textFeild:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xFFF1F7)
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        return view
    }()
    lazy var numberPlaceholder:UIView = {
        let imageView = UIView()
        imageView.backgroundColor = K.Color.ThemeColor
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    override init(frame: CGRect){
        super.init(frame:frame)
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - UI
extension TextFieldCollectionViewCell {
    
    func setUpUI(){
        addSubview(textFeild)
        addSubview(numberPlaceholder)
    }
    
    func setUpConstraints(){
        textFeild.snp.makeConstraints{ make in
            make.width.equalTo(40)
            make.height.equalTo(48)
            make.center.equalToSuperview()
        }
        numberPlaceholder.snp.makeConstraints{ make in
            make.width.height.equalTo(12)
            make.center.equalToSuperview()
        }
    }
    
    func setMoodCellBorder(_ value:Bool){
        
    }
}
