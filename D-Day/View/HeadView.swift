//
//  HeadView.swift
//  D-Day
//
//  Created by GC on 2021/10/11.
//

import Toolkit

class HeadView: UIView {
    
    lazy var headView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        
        addSubview(headView)
        
        headView.snp.makeConstraints{ make in
            make.width.height.equalToSuperview()
            make.center.equalToSuperview()
        }
    }
}
