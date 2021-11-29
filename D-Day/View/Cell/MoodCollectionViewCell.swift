//
//  MoodCollectionViewCell.swift
//  D-Day
//
//  Created by GC on 2021/11/1.
//

import Toolkit

class MoodCollectionViewCell: UICollectionViewCell {
    
    lazy var moodImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderColor = K.Color.ThemeColor.cgColor
        imageView.layer.cornerRadius = 19
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFit
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
extension MoodCollectionViewCell {
    
    func setUpUI(){
        addSubview(moodImageView)
    }
    
    func setUpConstraints(){
        moodImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(38)
            make.center.equalToSuperview()
        }
    }
    
    func setMoodCellBorder(_ value:Bool){
        if value {
            moodImageView.layer.borderWidth = 4
        } else {
            moodImageView.layer.borderWidth = 0
        }
    }
}

