//
//  BannerContainer.swift
//  Ad
//
//  Created by Kevin on 2018/5/23.
//

import UIKit

#if canImport(Toolkit)
import HouseAdLib
#elseif canImport(DCGKit)
import DCGHouseAd
#endif

class BannerContainer: UIView {
    
    var houseImageAd: HADImageBannerAd?
    
    var banner: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            guard let banner = self.banner else {
                return
            }
            
            self.addSubview(banner)
            banner.snp.remakeConstraints { (make) in
                make.edges.equalToSuperview()
            }
        }
    }
    
    weak var rootViewController: UIViewController?
    
    init(banner: UIView?, rootViewController: UIViewController?, houseAdID: String?) {
        super.init(frame: .zero)
        self.setup(banner: banner, rootViewController: rootViewController, houseAdID: houseAdID)
    }
    
    func setup(banner: UIView?, rootViewController: UIViewController?, houseAdID: String?) {
        self.banner = banner
        self.rootViewController = rootViewController
        if let dataKey = houseAdID {
            self.houseImageAd = HADImageBannerAd(dataKey: dataKey)
            self.houseImageAd?.show(in: self)
        }
        
        self.backgroundColor = .clear
        self.clipsToBounds = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
