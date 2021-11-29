//
//  SettingsFeaturedAppsView.swift
//  AdLib
//
//  Created by Tina on 2019/8/16.
//

import UIKit
import SwiftyJSON
import StoreKit

#if canImport(Toolkit)
import Toolkit
#elseif canImport(DCGKit)
import DCGKit
#endif

class SettingsFeaturedAppsView: UIView {
    
    let cellIdentifier = "C"
    
    var apps = [JSON]()
    var appsNames: JSON?
    var insets = UIEdgeInsets.zero
    var rowHeight: CGFloat = 64
    var fontSize: CGFloat = 15
    var titleColor = UIColor.black
    var tableBackgroundColor = UIColor.clear
    var iconSize: CGFloat = 40
    var cornerRadius: CGFloat = 0
    
    var imageBorderColor = UIColor.init(hex: 0xE1E1E1)
    
    var estimatedHeight: CGFloat {
        return CGFloat(apps.count) * rowHeight + insets.top + insets.bottom
    }
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(SettingsFeaturedAppCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.separatorStyle = .none
        tableView.backgroundColor = self.tableBackgroundColor
        tableView.estimatedRowHeight = rowHeight
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .clear
        
        DispatchQueue.main.async {
            self.addSubview(self.tableView)
            
            if self.cornerRadius > 0 {
                self.tableView.layer.cornerRadius = self.cornerRadius
            }
            
            self.tableView.snp.makeConstraints { (make) in
                make.edges.equalToSuperview().inset(self.insets)
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource

extension SettingsFeaturedAppsView: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return apps.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! SettingsFeaturedAppCell
        cell.selectionStyle = .none
        
        let app = apps[indexPath.row]
        
        cell.iconImageView.layer.borderColor = imageBorderColor.cgColor
        
        if let iconURLString = app["artworkUrl100"].string, let iconURL = URL(string: iconURLString) {
            cell.iconImageView.sd_setImage(with: iconURL, completed: nil)
        }
        cell.iconImageView.snp.updateConstraints { (make) in
            make.size.equalTo(iconSize)
        }
        
        cell.titleLabel.text = appsNames?[app["trackId"].stringValue].string ?? app["trackName"].string
        cell.titleLabel.font = UIFont.systemFont(ofSize: CGFloat(fontSize), weight: .regular)
        cell.titleLabel.textColor = titleColor
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SettingsFeaturedAppCell
        cell?.contentView.alpha = 0.7
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            cell?.contentView.alpha = 1
        }
        
        let app = apps[indexPath.row]
        let appID = app["trackId"].stringValue
        guard appID.count > 0 else {
            return
        }
        
        AppStore.shared.open(appID: appID, inApp: true)
    }
}
