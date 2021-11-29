//
//  StatesButton.swift
//  Cloud-Music-Tube
//
//  Created by Tracy on 20/06/2017.
//  Copyright © 2017 Tina. All rights reserved.
//

import UIKit

public class StatesButton<T: Equatable>: UIButton {

    public var currentState: T? = nil {
        didSet {
            self.updateUI()
        }
    }
    
    public var changesStateAutomatically = true
    
    private var stateInfos = [StateInfo]()
    
    class StateInfo {
        var state: T
        var image: UIImage?
        var title: String?
        var titleColor: UIColor?
        var backgroundColor: UIColor?
        
        init(state: T, image: UIImage? = nil, title: String? = nil, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
            self.state = state
            self.image = image
            self.title = title
            self.titleColor = titleColor
            self.backgroundColor = backgroundColor
        }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    public func register(state: T, image: UIImage? = nil, title: String? = nil, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        let info = StateInfo(state: state, image: image, title: title, titleColor: titleColor, backgroundColor: backgroundColor)
        self.stateInfos.append(info)
        
        if self.stateInfos.count == 1 {
            self.currentState = state
        }
    }
    
    public func update(state: T, image: UIImage? = nil, title: String? = nil, titleColor: UIColor? = nil, backgroundColor: UIColor? = nil) {
        for info in self.stateInfos {
            guard info.state == state else {
                continue
            }
            
            if let image = image {
                info.image = image
            }
            if let title = title {
                info.title = title
            }
            if let titleColor = titleColor {
                info.titleColor = titleColor
            }
            if let backgroundColor = backgroundColor {
                info.backgroundColor = backgroundColor
            }
            
            break
        }
        
        if self.currentState == state {
            self.updateUI()
        }
    }
    
    // MARK: - Action
    @objc func tapped(sender: UIButton) {
        if let index = self.currentStateIndex() {
            if self.changesStateAutomatically {
                let nextIndex = (index + 1) % self.stateInfos.count
                let nextInfo = self.stateInfos[nextIndex]
                self.currentState = nextInfo.state
            }
        }
    }
    
    // MARK: - Private
    private func updateUI() {
        guard let index = self.currentStateIndex() else {
            return
        }
        
        let info = self.stateInfos[index]
        if let image = info.image {
            self.setImage(image, for: .normal)
        }
        if let title = info.title {
            self.setTitle(title, for: .normal)
        }
        if let titleColor = info.titleColor {
            self.setTitleColor(titleColor, for: .normal)
        }
        if let backgroundColor = info.backgroundColor {
            self.backgroundColor = backgroundColor
        }
    }
    
    private func currentStateIndex() -> Int? {
        return self.stateInfos.firstIndex { (info) -> Bool in
            return info.state == self.currentState
        }
    }
    
    private func setup() {
        self.addTarget(self, action: #selector(tapped(sender:)), for: .touchUpInside)
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
