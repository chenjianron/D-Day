//
//  PasswordCollectionViewCell.swift
//  D-Day
//
//  Created by GC on 2021/11/8.
//
import Toolkit

class PasswordCollectionViewCell: UICollectionViewCell {
    
    lazy var passwordNumber:UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 22
        label.layer.masksToBounds = true
        label.font = .systemFont(ofSize: 24)
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        return label
    }()
    lazy var image:UIImageView = {
        let image = UIImageView()
        image.isUserInteractionEnabled = true
        image.contentMode = .scaleAspectFit
        image.isHidden = true
        return image
    }()
//    lazy var button : UIButton = {
//        let btn = UIButton()
//        return btn;
//    }()
    
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
extension PasswordCollectionViewCell {
    
    func setUpUI(){
        addSubview(passwordNumber)
        addSubview(image)
    }
    
    func setUpConstraints(){
        passwordNumber.snp.makeConstraints{ make in
            make.width.height.equalTo(44)
            make.center.equalToSuperview()
        }
        image.snp.makeConstraints{ make in
            make.width.equalTo(26)
            make.height.equalTo(20)
            make.center.equalToSuperview()
        }
    }
}
