//
//  SpecialSettingTableViewCell.swift
//  D-Day
//
//  Created by GC on 2021/11/4.
//

import UIKit
import Toolkit

class SpecialSettingTableViewCell:UITableViewCell {
    
    var switchClickEvent: ((Bool) -> Void)?
    
    lazy var title:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.text = __("从零开始")
        return label
    }()
    lazy var hintLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.textColor = K.Color.AuxiliaryColor
        label.text = __("开启后，在一起当天为第0天")
        return label
    }()
    lazy var switchIcon:UISwitch = {
        let object = UISwitch()
        object.onTintColor = K.Color.ThemeColor
        object.addTarget(self, action: #selector(switchClickEvent(_:)), for: .touchUpInside)
        return object
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        contentView.addSubview(title)
        contentView.addSubview(switchIcon)
        contentView.addSubview(hintLabel)
        
        title.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(22)
            make.top.equalToSuperview().inset(12)
        }
        hintLabel.snp.makeConstraints{ make in
            make.bottom.equalToSuperview().inset(12)
            make.left.equalToSuperview().offset(22)
        }
        switchIcon.snp.makeConstraints{ make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().inset(22)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func switchClickEvent(_ sender:UISwitch) {
        switchClickEvent?(sender.isOn)
    }
}
