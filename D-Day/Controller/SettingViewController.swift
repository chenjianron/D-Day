//
//  SettingViewController.swift
//  D-Day
//
//  Created by GC on 2021/11/4.
//

import Toolkit
import MessageUI
import SafariServices
import LocalAuthentication

class SettingViewController: UIViewController {
    
    enum TableCellType:Int{
        case Date = 0
        case SetFromZero = 1
        case PasswordSwitch = 2
        case Course = 3
        case Feedback = 4
        case Share = 5
        case Evaluate = 6
        case Policy = 7
        case UserAgreement = 8
        case Face = 9
    }
    struct TableViewCellModel {
        let title:String
        let type: TableCellType
    }
    
    let context = LAContext()
    
    var setFromZeroCompletion:(()->())?
    var identification = isiPhoneX ? "Face ID" : "Touch ID"
    var tableViewCellModels :[[TableViewCellModel]] = [
        [TableViewCellModel(title: __("在一起的日期"), type: .Date),
         TableViewCellModel(title: __("从零开始"), type: .SetFromZero),
         TableViewCellModel(title: __("密码锁"), type: .PasswordSwitch)],
        [TableViewCellModel(title: __("意见反馈"), type: .Feedback),
         TableViewCellModel(title: __("分享给好友"), type: .Share),
         TableViewCellModel(title: __("给个评价"), type: .Evaluate),
         TableViewCellModel(title: __("隐私政策"), type: .Policy),
         TableViewCellModel(title: __("用户协议"), type: .UserAgreement)]
    ]
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.settingBanner, rootViewController:self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    
    
    lazy var tableView: UITableView = {
        let object = UITableView(frame: .zero, style: .grouped)
        object.delegate = self
        object.dataSource = self
        object.separatorStyle = .none
        object.sectionFooterHeight = .zero
        object.register(SettingTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SettingTableViewCell.self))
        object.register(SpecialSettingTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(SpecialSettingTableViewCell.self))
        return object
    }()
    //    lazy var appsView: UIView = SettingsFeaturedApps.createAppsView(width: self.view.width)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpDataSource()
        setupUI()
        showBackItem()
        setupAdBannerView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("设置页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("设置页")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Pro.shared.addLongPressGesture(to: tableView.cellForRow(at: IndexPath(row: 0, section: 0)))
    }
}

// MARK: - private
extension SettingViewController {
    
    func validateBiometrics() {
        let context = LAContext()
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            AppStorageGroupsManager.default.set(true, forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
        } else {
            let code = LAError.Code(rawValue: error!.code)
            switch code! {
            case LAError.Code.biometryLockout:
                break
            case LAError.Code.biometryNotAvailable:
                break
            case .authenticationFailed:
                //                securityView.securityLabel.text = __("设备不支持Touch ID/Face ID")
//                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
//                    timer.invalidate()
//                }
                break
            case .userCancel:
                break
            case .userFallback:
                break
            case .systemCancel:
                break
            case .passcodeNotSet:
                //                securityView.securityLabel.text = __("没有设置设备密码，无法使用指纹（人脸）识别")
//                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
//                    timer.invalidate()
//                }
                break
            case .touchIDNotAvailable:
                //                securityView.securityLabel.text = __("设备不支持Touch ID/Face ID")
//                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
//                    timer.invalidate()
//                }
                break
            case .touchIDNotEnrolled:
                //                securityView.securityLabel.text = __("没有录入指纹/人脸")
                //                Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { timer in
                //                    timer.invalidate()
                //                }
                let alert = UIAlertController(title: __("检测到您未设置") + identification, message: __("请前往「设置 >>") + identification + __("与密码」中设置您的") + identification, preferredStyle: .alert)
                let delete = UIAlertAction(title: __("确认"), style: .default, handler: {_ in })
                alert.addAction(delete)
                self.present(alert, animated: true, completion: nil)
                break
            case .touchIDLockout:
                break
            case .appCancel:
                break
            case .invalidContext:
                break
            case .notInteractive:
                break
            @unknown default:
                break
            }
            print("识别功能不可用")
        }
    }
    
    func selectAnniversaryDate(){
        let datePickerViewController = DatePickerViewController()
        datePickerViewController.settingCompletion = { [self] date in
            HeadInfoManager.default.loveDate = date
            LoveAnniversariesManager.default.reset()
//            navigationController?.popViewController(animated: false)
//            let appDelegate = UIApplication.shared.delegate as! AppDelegate
//            appDelegate.window?.rootViewController = DDNavigationViewController(rootViewController: MainViewController())
            setFromZeroCompletion!()
            tableView.reloadData()
        }
        datePickerViewController.modalPresentationStyle = .custom
        navigationController?.present(datePickerViewController, animated: false, completion: nil)
    }
    
    func course(){
        let smallComponentViewController = SmallComponentViewController()
        smallComponentViewController.modalPresentationStyle = .custom
        navigationController?.present(smallComponentViewController, animated: false, completion: nil)
    }
    
    func feedback(){
        //        Statistics.event(.SettingsTap, label: "意见反馈")
        if MFMailComposeViewController.canSendMail() {
            FeedbackMailMaker.shared.presentMailComposeViewController(from: self, recipient: K.Share.Email)
        } else {
            let alert = UIAlertController(title: __("未设置邮箱账户"), message: __("要发送电子邮件，请设置电子邮件账户"), preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: __("确认"), style: .default, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func share(indexPath:IndexPath){
        //        Statistics.event(.SettingsTap, label: "分享给好友")
                let content = K.Share.normalContent.toURL()
                let activityVC = UIActivityViewController(activityItems: [content as Any], applicationActivities: nil)
                if UIDevice.current.userInterfaceIdiom == .pad {
                    if let popVC = activityVC.popoverPresentationController {
                        if let cell = self.tableView.cellForRow(at: indexPath) as? SettingTableViewCell {
                            popVC.sourceView = cell.title
                        }
                    }
                }
                activityVC.completionWithItemsHandler = { (activityType, completed, returnedItems, error) in
                    if completed {
                        Marketing.shared.didShareRT()
                    }
                }
                present(activityVC, animated: true, completion: nil)
    }
    
    func comment(){
        //        Statistics.event(.SettingsTap, label: "给个评价")
        let urlString = "itms-apps://itunes.apple.com/app/id\(K.IDs.AppID)?action=write-review"
        if let url = URL(string: urlString) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func policy(){
        //        Statistics.event(.SettingsTap, label: "隐私政策")
        guard let url = Util.webURL(urlStr: K.Website.PrivacyPolicy) else { return }
        let vc = SFSafariViewController(url: url)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    func userAgreement(){
        //        Statistics.event(.SettingsTap, label: "用户协议")
        guard let url = Util.webURL(urlStr: K.Website.UserAgreement) else { return }
        let vc = SFSafariViewController(url: url)
        self.present(vc, animated: true, completion: nil)
    }
}

// MARK: - tableView
extension SettingViewController: UITableViewDelegate,UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            switch indexPath.row {
            case 0:
                Statistics.event(.SettingsTap, label: "在一起日期")
                selectAnniversaryDate()
            case (tableViewCellModels[0].count - 1):
                Statistics.event(.SettingsTap, label: "小组件教程")
                if #available(iOS 14.0, *) {
                    course()
                }
            default:
                break
            }
        } else if indexPath.section == 1 {
            switch indexPath.row {
            case 0:
                Statistics.event(.SettingsTap, label: "意见反馈")
                feedback()
            case 1:
                Statistics.event(.SettingsTap, label: "分享给好友")
                share(indexPath: indexPath)
            case 2:
                Statistics.event(.SettingsTap, label: "给个评价")
                comment()
            case 3:
                Statistics.event(.SettingsTap, label: "隐私政策")
                policy()
            case 4:
                Statistics.event(.SettingsTap, label: "用户协议")
                userAgreement()
            default:
                break
            }
        }
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        tableViewCellModels[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return tableViewCellModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell
        if indexPath.section == 0 && indexPath.row == 1 {
            let cell1 = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(SpecialSettingTableViewCell.self),for: indexPath) as! SpecialSettingTableViewCell
            cell1.switchClickEvent = { [self] isOn in
                Statistics.event(.SettingsTap, label: "从零开始")
                if isOn {
                    AppStorageGroupsManager.default.set(true, forKey: K.UserDefaultsKey.IsFromZero)
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController = DDNavigationViewController(rootViewController: MainViewController())
                    setFromZeroCompletion!()
                } else {
                    AppStorageGroupsManager.default.set(false, forKey: K.UserDefaultsKey.IsFromZero)
//                    let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                    appDelegate.window?.rootViewController = DDNavigationViewController(rootViewController: MainViewController())
                    setFromZeroCompletion!()
                }
            }
            if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFromZero){
                cell1.switchIcon.isOn = true
            }
            cell = cell1
        } else {
            let cell2 = tableView.dequeueReusableCell(withIdentifier:NSStringFromClass(SettingTableViewCell.self), for: indexPath) as! SettingTableViewCell
            let tableViewCellModel = tableViewCellModels[indexPath.section][indexPath.row]
            if tableViewCellModel.type == .Date {
                cell2.title.text = tableViewCellModel.title
                cell2.timeLabel.text = HeadInfoManager.default.loveDate.toStringWithFormat("yyyy.MM.dd")
                cell2.timeLabel.isHidden = false
            }
            if tableViewCellModel.type == .PasswordSwitch {
                cell2.switchClickEvent = { [self] isOn in
                    Statistics.event(.SettingsTap, label: "密码锁")
                    if isOn {
                        cell2.switchIcon.isOn = false
                        let settingPassword = SettingPasswordViewController()
                        settingPassword.isSetting = true
                        settingPassword.completion = { [self] in
                            cell2.switchIcon.isOn = true
                            tableViewCellModels[0].insert(TableViewCellModel(title: __("面部/指纹"), type: .Face), at: 3)
                            tableView.reloadData()
                        }
                        navigationController?.pushViewController(settingPassword, animated: false)
                    } else {
                        AppStorageGroupsManager.default.set(false, forKey: K.UserDefaultsKey.IsSettingPassword)
                        AppStorageGroupsManager.default.set(false, forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
                        tableViewCellModels[0].remove(at: 3)
                        tableView.reloadData()
                    }
                }
                cell2.title.text = tableViewCellModel.title
                cell2.switchIcon.isHidden = false
                cell2.imageIcon.isHidden = true
                cell2.timeLabel.isHidden = true
                cell2.switchIcon.isOn = AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsSettingPassword)
            }
            if tableViewCellModel.type == .Face {
                cell2.switchClickEvent = { [self] isOn in
                    if isOn {
                        validateBiometrics()
                        cell2.switchIcon.isOn = AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
                    } else {
                        AppStorageGroupsManager.default.set(false, forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
                    }
                }
                cell2.title.text = tableViewCellModel.title
                cell2.switchIcon.isHidden = false
                cell2.imageIcon.isHidden = true
                cell2.timeLabel.isHidden = true
                cell2.switchIcon.isOn = AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
            }
            if tableViewCellModel.type == .Course || tableViewCellModel.type == .Feedback || tableViewCellModel.type == .Share || tableViewCellModel.type == .Evaluate || tableViewCellModel.type == .Policy || tableViewCellModel.type == .UserAgreement{
                cell2.title.text = tableViewCellModel.title
                cell2.timeLabel.isHidden = true
                cell2.imageIcon.isHidden = false
                cell2.switchIcon.isHidden = true
            }
            cell = cell2
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        if section == 1 {
            let headerView = UIView()
            return headerView
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return 5
        } else {
            return 0
        }
    }
}

//MARK: -
extension SettingViewController{
    
    func notifyUser(_ msg: String, err: String?)  {
        print("msg > \(msg)")
        print("err > \(err!)")
    }
    
    func setUpDataSource(){
        if #available(iOS 14.0, *) {
            tableViewCellModels[0].insert(TableViewCellModel(title: __("小组件教程"), type: .Course), at: 3)
        }
        if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsSettingPassword) {
            tableViewCellModels[0].insert(TableViewCellModel(title: __("面部/指纹"), type: .Face), at: 3)
        }
    }
    
}

// MARK: - UI
extension SettingViewController {
    
    func setupUI(){
        
        navigationItem.title = __("设置")
        view.backgroundColor = .white
        view.addSubview(tableView)
        setupAdBannerView()
        if SettingsFeaturedApps.apps.count > 0 {
            tableView.tableHeaderView = SettingsFeaturedApps.createAppsView(width: self.view.width)
        }
        setupConstraints()
    }
    
    func setupConstraints(){
        
        tableView.snp.makeConstraints{ make in
//            make.height.equalToSuperview().multipliedBy(0.8)
            make.width.equalToSuperview()
            make.top.equalTo(safeAreaTop).offset(0)
            make.bottom.equalTo(safeAreaBottom).offset(-bannerInset)
        }
    }
    
    func setupAdBannerView() {
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.bottom.equalTo(safeAreaBottom)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
        }
    }
    
}

// MARK: - public
extension SettingViewController {
    
    @objc func backToPrevious(){
        Statistics.event(.SettingsTap, label: "返回")
    }
    
}

extension Util {
    
    static func webURL(urlStr: String) -> URL? {
        if var urlComponents = URLComponents(string: urlStr) {
            var queryItems = [URLQueryItem]()
            queryItems.append(URLQueryItem(name: "lang", value: Util.languageCode()))
            queryItems.append(URLQueryItem(name: "version", value: Util.appVersion()))
            urlComponents.queryItems = queryItems
            if let url = urlComponents.url {
                return url
            }
        }
        return nil
    }
    
}
