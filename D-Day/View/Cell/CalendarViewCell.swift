//
//  CalendarViewCell.swift
//  D-Day
//
//  Created by GC on 2021/10/27.
//

import Toolkit
import JTAppleCalendar

class CalendarViewCell:JTACDayCell {
    
    lazy var selectedBackgroundImageView:UIView = {
        let imageView = UIView()
        imageView.backgroundColor = K.Color.ThemeColor
        imageView.layer.cornerRadius = Util.isIPad ? 36 : 20
        return imageView
    }()
    lazy var dayText:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    lazy var hasRecordImageView:UIView = {
        let imageView = UIView()
        imageView.backgroundColor = K.Color.ThemeColor
        imageView.layer.cornerRadius = 3
        return imageView
    }()
    
    override init(frame:CGRect){
        super.init(frame: frame)
        
        contentView.addSubview(selectedBackgroundImageView)
        contentView.addSubview(dayText)
        contentView.addSubview(hasRecordImageView)
        
        dayText.snp.makeConstraints{ make in
            make.center.equalToSuperview()
        }
        selectedBackgroundImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(Util.isIPad ? 72 : 40)
            make.center.equalToSuperview()
        }
        hasRecordImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(6)
            make.bottom.equalToSuperview().offset(Util.isIPad ? -14 : -7)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
