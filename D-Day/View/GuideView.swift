//
//  GuideView.swift
//  D-Day
//
//  Created by GC on 2021/11/21.
//

import Toolkit

class GuideView: UIView {
    
    lazy var containerView : UIView = {
        let view = UIView()
        return view;
    }()
    lazy var manHeadView:HeadView = {
        let headView = HeadView()
        headView.layer.borderWidth = 3
        headView.layer.borderColor = UIColor(hex: 0xFFD5EA).cgColor
        headView.layer.cornerRadius = Util.isIPad ? 75 / 2 : 55 / 2
        headView.headView.image = #imageLiteral(resourceName: "Index-ManHead-Default")
        headView.layer.masksToBounds = true
        return headView
    }()
    lazy var imageView:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "NoteIcon")
        return image
    }()
//    lazy var labelView : UIView = {
//        let view = UIView()
//        view.backgroundColor = .white
//        view.layer.cornerRadius = 10
//        return view
//    }()
    lazy var label : UILabel = {
        let label = UILabel()
        label.text = __("点击头像可选择头像")
        label.backgroundColor = .white
        label.layer.cornerRadius = 10
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        backgroundColor = UIColor(hex: 0x000000, alpha: 0.4)
        addSubview(containerView)
        containerView.addSubview(manHeadView)
        addSubview(label)
        addSubview(imageView)
        
        containerView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
//            make.top.equalTo(safeAreaTop).offset(Util.isIPad ? G.share.h(19) + bannerInset + 36 : G.share.h(19) + bannerInset + G.share.h(26))
            make.width.equalTo(G.share.w(335)).multipliedBy(0.6)
            make.height.equalTo(G.share.h(186)).multipliedBy(0.33)
        }
        manHeadView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.centerX.equalToSuperview().offset(-25.5)
            make.width.equalTo(Util.isIPad ? 75 : 55)
            make.height.equalTo(Util.isIPad ? 75 : 55)
        }
        label.snp.makeConstraints{ make in
            make.top.equalTo(manHeadView.snp.bottom).offset(G.share.h(29))
        }
        
    }
}

