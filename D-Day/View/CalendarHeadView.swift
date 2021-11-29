//
//  CalendarHeadView.swift
//  D-Day
//
//  Created by GC on 2021/10/27.
//

import Toolkit

class CalendarHeadView: UIView {
    
    var leftBtnClickComplete:(()->Void)?
    var rightBtnClickComplete:(()->Void)?
    var calendarPickerComplete:(()->Void)?
    
    lazy var toLastMonthBtn:UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.setImage(#imageLiteral(resourceName: "ToLastMonthBtn"), for: .normal)
        btn.backgroundColor = UIColor(hex: 0xFFF1F7)
        btn.addTarget(self, action: #selector(leftBtnClick), for: .touchUpInside)
        return btn
    }()
    lazy var toNextMonthBtn:UIButton = {
        let btn = UIButton()
        btn.layer.cornerRadius = 12
        btn.setImage(#imageLiteral(resourceName: "ToNextMonthBtn"), for: .normal)
        btn.backgroundColor = UIColor(hex: 0xFFF1F7)
        btn.addTarget(self, action: #selector(rightBtnClick), for: .touchUpInside)
        return btn
    }()
    lazy var labelBackground : UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "CanlenderTopBackground-1")
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    lazy var currentMonthLabel : UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.isUserInteractionEnabled = true
        label.font = .systemFont(ofSize: 20)
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(calendarPickerClick)))
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI(){
        addSubview(labelBackground)
        addSubview(toLastMonthBtn)
        addSubview(toNextMonthBtn)
        labelBackground.addSubview(currentMonthLabel)
        setupConstraints()
    }
    
    func setupConstraints(){
        labelBackground.snp.makeConstraints{ make in
            make.width.equalTo(134)
            make.height.equalTo(37)
            make.center.equalToSuperview()
        }
        currentMonthLabel.snp.makeConstraints{ make in
            make.width.equalTo(134)
            make.height.equalTo(37)
            make.center.equalToSuperview()
        }
        toNextMonthBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(26)
            make.left.equalTo(currentMonthLabel.snp.right).offset(18)
            make.centerY.equalToSuperview()
        }
        toLastMonthBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(26)
            make.centerY.equalToSuperview()
            make.right.equalTo(currentMonthLabel.snp.left).offset(-18)
        }
    }
}


// - Interaction
extension CalendarHeadView {
    
    @objc func leftBtnClick(){
        leftBtnClickComplete!()
    }
    
    @objc func rightBtnClick(){
        rightBtnClickComplete!()
    }
    
    @objc func calendarPickerClick(){
        calendarPickerComplete!()
    }
}

