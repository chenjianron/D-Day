//
//  AnniversaryEditTableViewCell.swift
//  D-Day
//
//  Created by GC on 2021/10/21.
//

import Toolkit

class AnniversaryEditTableViewCell:UITableViewCell {
    
    var switchClickEvent: ((Bool) -> Void)?
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textColor = .gray
        return label
    }()
    lazy var switchIcon:UISwitch = {
        let object = UISwitch()
        object.onTintColor = K.Color.ThemeColor
        object.isHidden = true
        object.addTarget(self, action: #selector(switchClickEvent(_:)), for: .touchUpInside)
        return object
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .right
        label.textColor = .black
        label.isHidden = true
        return label
    }()
    lazy var imageIcon:UIImageView = {
       let image = UIImageView()
        image.image = #imageLiteral(resourceName: "ClickIcon")
        image.isHidden = true
       return image
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(title)
        contentView.addSubview(imageIcon)
        contentView.addSubview(switchIcon)
        contentView.addSubview(timeLabel)
        
        title.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(20)
            make.bottom.top.equalToSuperview().inset(12)
        }
        timeLabel.snp.makeConstraints{ make in
            make.width.equalTo(G.share.w(180))
            make.top.bottom.equalToSuperview().inset(12)
            make.right.equalToSuperview().offset(-36.5)
        }
        switchIcon.snp.makeConstraints{ make in
            make.top.bottom.equalToSuperview().inset(10)
            make.right.equalToSuperview().inset(22)
        }
        imageIcon.snp.makeConstraints{ make in
            make.right.equalToSuperview().offset(-22)
            make.bottom.top.equalToSuperview().inset(17)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchClickEvent(_ sender:UISwitch) {
        switchClickEvent?(sender.isOn)
    }
}
