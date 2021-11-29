//
//  LoveDayTableViewCell.swift
//  D-Day
//
//  Created by GC on 2021/10/18.
//

import UIKit
import Toolkit

class LoveDayTableViewCell:UITableViewCell {
    
    lazy var containerView :UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    lazy var loveDayTitle:UILabel =  {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.lineBreakMode = .byTruncatingTail
       return label
    }()
    lazy var loveDayTime:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = K.Color.AuxiliaryColor
       return label
    }()
    lazy var loveDaysFromNow:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        return label
    }()
    lazy var setTopImageView:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "SetTopCell")
        image.isHidden = true
        return image
    }()
    
    override init(style:UITableViewCell.CellStyle,reuseIdentifier:String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.layer.masksToBounds = true
        contentView.layer.cornerRadius = 10
        self.setUpUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI(){
        
        backgroundColor = .clear
        clipsToBounds = true
        layer.cornerRadius = 10
        contentView.addSubview(containerView)
        containerView.addSubview(loveDayTitle)
        containerView.addSubview(loveDayTime)
        containerView.addSubview(loveDaysFromNow)
        containerView.addSubview(setTopImageView)
        
        containerView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalToSuperview()
            make.center.equalToSuperview()
        }
        loveDayTitle.snp.makeConstraints{ make in
            make.width.lessThanOrEqualTo(200)
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview().offset(Util.isIPad ? 21 : G.share.w(15))
        }
        loveDayTime.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().offset(-14)
            make.left.equalToSuperview().offset(Util.isIPad ? 20 : G.share.w(14))
        }
        loveDaysFromNow.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(24)
            make.right.equalToSuperview().offset(Util.isIPad ? -20 : -G.share.w(15))
        }
        setTopImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(12)
            make.left.equalTo(loveDayTitle.snp.right).offset(6)
            make.centerY.equalTo(loveDayTitle.snp.centerY)
        }
    }
    
    func setData(_ anniversaryModel:AnniversaryModel){
        let IsDecreaseOne :Int
        if anniversaryModel.presetAnniversaryModel?.days != 0 && AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFromZero) {
                IsDecreaseOne = -1
        } else {
            IsDecreaseOne = 0
        }
        let dayNumber = Date().numberOfDays(to: anniversaryModel.date) + IsDecreaseOne
        loveDayTitle.text = __(anniversaryModel.title)
        loveDayTime.text = anniversaryModel.date.toStringWithFormat("yyyy.MM.dd")
        let str1 = dayNumber.description
        let len1 = str1.count
        if dayNumber == 0 {
            loveDaysFromNow.text = __("今天")
            loveDaysFromNow.font = UIFont.boldSystemFont(ofSize: 18)
            loveDaysFromNow.textColor = K.Color.ThemeColor
        } else if dayNumber < 0 {
            let str2 = String(format: __("已过 %d 天"), arguments: [abs(dayNumber)])
            let str3 = NSMutableAttributedString(string: str2)
            if(Helper.getCurrentLanguage().contains("en")){
                str3.setAttributes([.font:UIFont(name: "Helvetica", size: 18)!], range: NSRange(location: 0, length: len1))
            } else if Helper.getCurrentLanguage().contains("ja"){
                str3.setAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 0, length: len1))
            } else {
                str3.setAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 3, length: len1))
            }
            loveDaysFromNow.attributedText = str3
            containerView.backgroundColor = UIColor(hex: 0xFFFFFF,alpha: 0.3)
            loveDaysFromNow.textColor = UIColor(hex: 0x8E8E8E,alpha: 1)
            loveDayTitle.textColor = UIColor(hex: 0x8E8E8E,alpha: 1)
            loveDayTime.textColor = UIColor(hex: 0x8E8E8E,alpha: 1)
        } else {
            let str2 = String(format: __("%d 天"), arguments: [dayNumber])
            let str3 = NSMutableAttributedString(string: str2)
            str3.setAttributes([.font: UIFont.boldSystemFont(ofSize: 18)], range: NSRange(location: 0, length: len1))
            containerView.backgroundColor = .white
            loveDaysFromNow.textColor = .black
            loveDayTitle.textColor = .black
            loveDayTime.textColor = .black
            loveDaysFromNow.attributedText = str3
        }
        if anniversaryModel.isSetTop {
            containerView.backgroundColor = K.Color.ThemeColor
            loveDayTitle.textColor = .white
            loveDayTime.textColor = .white
            loveDaysFromNow.textColor = .white
            setTopImageView.isHidden = false
        } else {
            if dayNumber < 0 {
                containerView.backgroundColor = UIColor(hex: 0xFFFFFF,alpha: 0.3)
            } else {
                containerView.backgroundColor = .white
            }
            if dayNumber == 0 {
                loveDaysFromNow.textColor = K.Color.ThemeColor
            } else {
                loveDaysFromNow.textColor = .black
            }
            loveDayTitle.textColor = .black
            loveDayTime.textColor = .black
            
            setTopImageView.isHidden = true
        }
    }
}
