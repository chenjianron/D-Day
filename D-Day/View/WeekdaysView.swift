//
//  WeekdaysView.swift
//  D-Day
//
//  Created by GC on 2021/10/27.
//

import Toolkit

class WeekdaysView: UIView {
    
    lazy var weekdays = [__("日"), __("一"), __("二"), __("三"), __("四"), __("五"), __("六")]
    
    override init(frame: CGRect){
        super.init(frame: frame)
        
        var lastDayLabel:UIView?
        for i in 0..<weekdays.count{
            let label = UILabel()
            label.text = weekdays[i]
            label.textColor = K.Color.SecondLevelColor
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 17)
            addSubview(label)
            label.snp.makeConstraints{ make in
                make.centerY.equalToSuperview()
                if lastDayLabel != nil {
                    make.width.equalTo(Util.isIPad ? G.share.w(51.5) : 51.5)
                    make.left.equalTo(lastDayLabel!.snp.right).offset(0)
                } else {
                    make.width.equalTo(Util.isIPad ? G.share.w(51.5) : 51.5)
                    make.left.equalToSuperview()
                }
            }
            lastDayLabel = label
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
