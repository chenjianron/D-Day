//
//  MainViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/11.
//

import Toolkit

enum headType {
    case man
    case women
}

class MainViewController: UIViewController {
    
    var loveDayTableViewCellIdentifier = "loveDayTableViewCellIdentifier"
    var dataSource = [AnniversaryModel]()
    var tableviewViewModel = TableviewViewModel(dataManager: LoveAnniversariesManager.default)
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.homeBanner, rootViewController:self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    
    lazy var backgroundView : UIView = {
        let view = UIView()
        view.frame = view.frame
        view.backgroundColor = UIColor(hex: 0x000000, alpha: 0.4)
        let tap1 = UITapGestureRecognizer(target: self, action:#selector(tap))
        tap1.cancelsTouchesInView = false
        view.addGestureRecognizer(tap1)
        return view;
    }()
    lazy var containerView : UIView = {
        let view = UIView()
        return view;
    }()
    lazy var manHeadViewBackground: UIView = {
        let view = UIView()
        view.backgroundColor = K.Color.ThemeColor
        view.layer.cornerRadius = Util.isIPad ? 85 / 2 : 65 / 2
        return view
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
        image.image = #imageLiteral(resourceName: "Heart")
        return image
    }()
    lazy var label : UILabel = {
        let label = UILabel()
        label.text = __("点击头像可更换")
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = UIColor(hex: 0xFFFFFF)
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.textColor = K.Color.ThemeColor
        return label
    }()
    lazy var backgroundImage : UIImageView = {
        let imageView = UIImageView.init(image: #imageLiteral(resourceName: "background"))
        imageView.autoresizingMask = .flexibleWidth
        imageView.frame = view.frame
        return imageView
    }()
    lazy var settingBtn:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Index-Icon-Setting"), for: .normal)
        button.addTarget(self, action: #selector(settingButtonClick), for: .touchUpInside)
        return button
    }()
    lazy var settingButton:UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(customView: settingBtn)
        return buttonItem
    }()
    lazy var calendarBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(calendarButtonClick(_:)), for: .touchUpInside)
        button.setImage(#imageLiteral(resourceName: "Index-Icon-Calendar"), for: .normal)
        return button
    }()
    lazy var calendarButton:UIBarButtonItem = {
        let buttonItem = UIBarButtonItem(customView: calendarBtn)
        return buttonItem
    }()
    lazy var topBackgroundBoard:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = K.Color.ThemeColor
        return view
    }()
    lazy var headsView:DDayHeadView = {
        let view = DDayHeadView()
        return view
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.white
        return label
    }()
    lazy var firstTimeLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 11)
        label.textColor = UIColor.white
        return label
    }()
    lazy var tableView:UITableView = {
        let object = UITableView(frame: .zero,style:.plain)
        object.delegate = self
        object.dataSource = self
        object.separatorStyle = .none
        object.backgroundColor = .clear
        object.register(LoveDayTableViewCell.classForCoder(), forCellReuseIdentifier: loveDayTableViewCellIdentifier)
        object.showsVerticalScrollIndicator = false
        return object
    }()
    lazy var emptyImage:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "EmptyAnniversaryHint")
        image.isHidden = true
        return image
    }()
    lazy var addBtn:UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: 0xFF7DB4, alpha: 0.9)
        button.setImage(#imageLiteral(resourceName: "AddButton"), for: .normal)
        button.layer.cornerRadius = 36
        button.addTarget(self, action: #selector(addAnniversary), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(applKicationDidBecomeActive), name: UIApplication.willEnterForegroundNotification, object: nil)
        loadData()
        setupUI()
        setupConstraints()
        setupAdBannerView()
        setGuideView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("首页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("首页")
    }
}

// MARK: - Private
extension MainViewController {
    
    //删除二次权限
    func deleteSecond(completion: @escaping()->Void){
        let alert = UIAlertController(title: __("删除"), message: __("删除后无法找回\n确认删除该纪念日"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: __("取消"), style: .cancel) { (action) in
        }
        let delete = UIAlertAction(title: __("删除"), style: .destructive, handler: {_ in completion()})
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    func loadData(){
        firstTimeLabel.text = __("起始于：") + HeadInfoManager.default.loveDate.toStringWithFormat("yyyy-MM-dd EEEE")
        let IsFromZero:Int
        if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFromZero) {
            IsFromZero = 0
        } else {
            IsFromZero = 1
        }
        let str1 = (HeadInfoManager.default.loveDate.numberOfDays(to: Date()) + IsFromZero).description
        let len1 = str1.count
        let str2 = String(format: __("我们已相爱 %d 天"), arguments: [(HeadInfoManager.default.loveDate.numberOfDays(to: Date()) + IsFromZero)])
        let str3 = NSMutableAttributedString(string: str2)
        print(Helper.getCurrentLanguage())
        if Helper.getCurrentLanguage().contains("en"){
            str3.setAttributes([.font:UIFont(name: "Helvetica", size: 46)!], range: NSRange(location: str3.length - 5 - len1, length: len1))
        } else if Helper.getCurrentLanguage().contains("ja"){
            str3.setAttributes([.font:UIFont(name: "Helvetica", size: 46)!], range: NSRange(location: 5, length: len1))
        } else {
            str3.setAttributes([.font:UIFont(name: "Helvetica", size: 46)!], range: NSRange(location: 6, length: len1))
        }
        timeLabel.attributedText = str3
        tableviewViewModel.loadData{ [self] (data) in
            dataSource = data
            emptyImage.isHidden = dataSource.count == 0 ? false : true
        }
    }
    
//    func setSildeButton(_ sub:UIView, _ row:Int){
//        sub.backgroundColor = .clear
//        if let topBtn:UIButton = sub.subviews[0] as? UIButton {
//            let button = UIButton()
//            button.backgroundColor = UIColor(hex: 0x2E364E)
//            if dataSource[row].isSetTop == true {
//                button.setImage(#imageLiteral(resourceName: "Cancel-SetTop"), for: .normal)
//            } else {
//                button.setImage(#imageLiteral(resourceName: "SetTop"), for: .normal)
//            }
//
//            button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 26, bottom: 25, right: 26 + topBtn.width)
//            topBtn.addSubview(button)
//            button.snp.makeConstraints{ make in
//                make.width.equalTo(topBtn.width * 2)
//                make.top.bottom.equalToSuperview().inset(7)
//            }
//        }
//        if  let editBtn:UIButton = sub.subviews[1] as? UIButton {
//            let button = UIButton()
//            button.setImage(#imageLiteral(resourceName: "Edit"), for: .normal)
//            button.backgroundColor = UIColor(hex: 0xFFB730)
//            button.imageEdgeInsets = UIEdgeInsets(top: 25, left: 26, bottom: 25, right: 26 + editBtn.width)
//            button.removeFromSuperview()
//            editBtn.addSubview(button)
//            button.snp.makeConstraints{ make in
//                make.width.equalTo(editBtn.width * 2)
//                make.top.bottom.equalToSuperview().inset(7)
//            }
//        }
//        if let deleteBtn:UIButton = sub.subviews[2] as? UIButton {
//            let button = UIButton()
//            button.setImage(#imageLiteral(resourceName: "Delete"), for: .normal)
//            button.backgroundColor = UIColor(hex: 0xFF5E5E)
//            button.removeFromSuperview()
//            deleteBtn.addSubview(button)
//            button.snp.makeConstraints{ make in
//                make.width.equalToSuperview()
//                make.top.bottom.equalToSuperview().inset(7)
//            }
//        }
//    }
}

// MARK: - Interaction
extension MainViewController {
    
    @objc func tap(){
        settingBtn.isEnabled = true
        calendarBtn.isEnabled = true
        backgroundView.isHidden = true
    }
    
    @objc func applKicationDidBecomeActive(notification: NSNotification){
        if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsSettingPassword){
            if Util.topViewController().classForCoder != SettingPasswordViewController.classForCoder() {
                let checkPasswordController = SettingPasswordViewController()
                checkPasswordController.isSetting = false
                checkPasswordController.completion = {
                    self.navigationController?.popViewController(animated: true)
                }
                navigationController?.topViewController?.dismiss(animated: false, completion: nil)
                navigationController?.pushViewController(checkPasswordController, animated: false)
                print(Util.topViewController().classForCoder)
            }
        }
    }
    
    @objc func settingButtonClick(_ sender: UIBarButtonItem){
        let settingViewController = SettingViewController()
        settingViewController.setFromZeroCompletion = { [self] in
            loadData()
            tableView.reloadData()
        }
        navigationController?.pushViewController(settingViewController,animated: false)
        Statistics.event(.HomePageTap, label: "设置页")
    }
    
    @objc func calendarButtonClick(_ sender: UIBarButtonItem){
        let calendarViewController = CalendarViewController()
        navigationController?.pushViewController(calendarViewController,animated: false)
        Statistics.event(.HomePageTap, label: "日历页")
    }
    
    @objc func addAnniversary(_ sender:UIButton){
        Statistics.event(.HomePageTap, label: "添加页")
        let addAnniversaryViewController = EditAnniversaryViewController()
        addAnniversaryViewController.viewControllerName = __("添加纪念日")
        addAnniversaryViewController.addAnniversaryCompletion = { [self] anniversary in
            tableviewViewModel.addLoveAniversaryItem(anniversary, completion: { [self] data in
                if emptyImage.isHidden == false {
                    emptyImage.isHidden = true
                }
                dataSource = data
                tableView.reloadData()
                Marketing.shared.didAddAnniversarySuccessRT()
            })
        }
        navigationController?.pushViewController(addAnniversaryViewController, animated: false)
    }
}

//MARK: - TableView
extension MainViewController: UITableViewDelegate,UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = LoveDayTableViewCell(style: .default, reuseIdentifier: loveDayTableViewCellIdentifier)
//        let cell: LoveDayTableViewCell = tableView.dequeueReusableCell(withIdentifier: loveDayTableViewCellIdentifier,for: indexPath) as! LoveDayTableViewCell
        cell.selectionStyle = .none
        cell.setData(dataSource[indexPath.section])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 14
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView(frame: CGRect(x: 0, y: 0, width: ScreenWidth - (Util.isIPad ? 80 : G.share.w(40)), height: 14))
    }
    
//    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath){
//        addBtn.isHidden = true
//        if #available(iOS 13.0, *) {
//            for subView in tableView.subviews {
//                if NSStringFromClass(subView.classForCoder) == "_UITableViewCellSwipeContainerView"{
//                    for sub in subView.subviews {
//                        if NSStringFromClass(sub.classForCoder) == "UISwipeActionPullView" {
//                            setSildeButton(sub,indexPath.row)
//                        }
//                    }
//                }
//            }
//        }
//        else if #available(iOS 11, *) {
//            for subView in tableView.subviews {
//                if NSStringFromClass(subView.classForCoder) == "UISwipeActionPullView" {
//                    setSildeButton(subView,indexPath.row)
//                }
//            }
//        }
//    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        addBtn.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        addBtn.isHidden = false
    }
    
    @available(iOS 11.0, *)
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let setTopButton = UIContextualAction(style: UIContextualAction.Style.normal, title: nil, handler: { [self] _,_,_  in
            Statistics.event(.HomePageTap, label: "置顶")
            tableviewViewModel.setTopAnniversary(dataSource[indexPath.section]){ [self] (data) in
                dataSource = data
                tableView.reloadData()
            }
        })
        if dataSource[indexPath.section].isSetTop == true {
            setTopButton.image = #imageLiteral(resourceName: "Cancel-SetTop")
        } else {
            setTopButton.image = #imageLiteral(resourceName: "SetTop")
        }
        setTopButton.backgroundColor = UIColor(hex: 0x2E364E, alpha: 1)
        let editButton = UIContextualAction(style: UIContextualAction.Style.normal, title: nil, handler: { [self] _,_,_ in
            Statistics.event(.HomePageTap, label: "编辑")
            let editAnniversaryViewController = EditAnniversaryViewController()
            editAnniversaryViewController.completion = {
                tableviewViewModel.editLoveAniversaryItem(dataSource[indexPath.section], completion: {[self] (data) in
                    dataSource = data
                    tableView.reloadData()
                })
            }
            editAnniversaryViewController.anniversary = dataSource[indexPath.section]
            editAnniversaryViewController.viewControllerName = __("编辑纪念日")
            navigationController?.pushViewController(editAnniversaryViewController, animated: false)
        })
        editButton.image = #imageLiteral(resourceName: "Edit")
        editButton.backgroundColor = UIColor(hex: 0xFFB730,alpha: 1)
        let deleteButton = UIContextualAction(style: UIContextualAction.Style.normal, title:nil, handler: {[self]  _,_,_ in
            Statistics.event(.HomePageTap, label: "删除")
            deleteSecond {
                tableviewViewModel.removeLoveAniversaryItem(dataSource[indexPath.section], completion: {[self] (data) in
                    dataSource = data
                    tableView.reloadData()
                    emptyImage.isHidden = dataSource.count == 0 ? false : true
                })
                Ad.default.interstitialSignal(key: K.ParamName.DeleteAnniversaryInterstitial)
            }
        })
        deleteButton.image = #imageLiteral(resourceName: "Delete")
        deleteButton.backgroundColor = UIColor(hex: 0xFF5E5E, alpha: 1)
        let configuration =  UISwipeActionsConfiguration(actions: [deleteButton,editButton,setTopButton])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
}

// MARK: - UI
extension MainViewController {
    
    func setupAdBannerView() {
        if let bannerView = self.bannerView {
            view.addSubview(bannerView)
            bannerView.snp.makeConstraints { make in
                make.top.equalTo(safeAreaTop)
                make.left.right.equalToSuperview()
                make.height.equalTo(Ad.default.adaptiveBannerHeight)
            }
        }
    }
    
    func setGuideView(){
        if !AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFirstLaunch) {
            settingBtn.isEnabled = false
            calendarBtn.isEnabled = false
            view.addSubview(backgroundView)
            backgroundView.addSubview(containerView)
            containerView.addSubview(manHeadViewBackground)
            containerView.addSubview(manHeadView)
            backgroundView.addSubview(label)
            backgroundView.addSubview(imageView)
            backgroundView.snp.makeConstraints{ make in
                make.width.equalToSuperview()
                make.height.equalToSuperview()
            }
            manHeadViewBackground.snp.makeConstraints{ make in
                make.centerY.equalToSuperview()
                make.right.equalTo(containerView.snp.centerX).offset(-20.5)
                make.width.equalTo(Util.isIPad ? 85 : 65)
                make.height.equalTo(Util.isIPad ? 85 : 65)
            }
            containerView.snp.makeConstraints{ make in
                make.centerX.equalTo(topBackgroundBoard)
                make.top.equalTo(topBackgroundBoard).offset(Util.isIPad ? 36 : G.share.h(26))
                make.width.equalTo(topBackgroundBoard).multipliedBy(0.6)
                make.height.equalTo(topBackgroundBoard).multipliedBy(0.33)
            }
            manHeadView.snp.makeConstraints{ make in
                make.centerY.equalToSuperview()
                make.right.equalTo(containerView.snp.centerX).offset(-25.5)
                make.width.equalTo(Util.isIPad ? 75 : 55)
                make.height.equalTo(Util.isIPad ? 75 : 55)
            }
            label.snp.makeConstraints{ make in
                make.top.equalTo(manHeadView.snp.bottom).offset(G.share.h(29))
                make.width.equalTo(182)
                make.height.equalTo(54)
//                make.left.equalTo(topBackgroundBoard.snp.left).offset(G.share.w(21))
                make.centerX.equalTo(manHeadView)
            }
            imageView.snp.makeConstraints{ make in
                make.width.equalTo(36)
                make.height.equalTo(28)
                make.bottom.equalTo(label).offset(-40)
                make.left.equalTo(label).offset(12)
            }
            
            AppStorageGroupsManager.default.setValue(true, forKey: K.UserDefaultsKey.IsFirstLaunch)
        }
    }
    
    func setupUI(){
        let spaceItem = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
                spaceItem.width = 30
        self.navigationItem.rightBarButtonItems = [settingButton, spaceItem, calendarButton]
        view.addSubview(backgroundImage)
        view.addSubview(topBackgroundBoard)
        view.addSubview(tableView)
        view.addSubview(emptyImage)
        view.addSubview(addBtn)
        topBackgroundBoard.addSubview(headsView)
        topBackgroundBoard.addSubview(timeLabel)
        topBackgroundBoard.addSubview(firstTimeLabel)
        
    }
    
    func setupConstraints(){
        topBackgroundBoard.snp.makeConstraints{ make in
            make.width.equalTo(G.share.w(335))
            make.height.equalTo(G.share.h(186))
            make.top.equalTo(safeAreaTop).offset(G.share.h(19) + bannerInset)
            make.centerX.equalToSuperview()
        } 
        headsView.snp.makeConstraints{ make in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(Util.isIPad ? 36 : G.share.h(26))
            make.width.equalToSuperview().multipliedBy(0.6)
            make.height.equalToSuperview().multipliedBy(0.33)
        }
        timeLabel.snp.makeConstraints { make in
            make.top.equalTo(headsView.snp.bottom).offset(Util.isIPad ? 3 : G.share.h(7))
            make.centerX.equalToSuperview()
        }
        firstTimeLabel.snp.makeConstraints { make in
            make.top.equalTo(timeLabel.snp.bottom).offset(Util.isIPad ? 23 : G.share.h(6))
            make.centerX.equalToSuperview()
        }
        tableView.snp.makeConstraints{ make in
            make.width.equalToSuperview().offset(-(Util.isIPad ? 80 : G.share.w(40)))
            make.bottom.equalToSuperview()
            make.top.equalTo(topBackgroundBoard.snp.bottom).offset(Util.isIPad ? 20 : 24)
            make.centerX.equalToSuperview()
        }
        emptyImage.snp.makeConstraints{ make in
            make.width.height.equalTo(198)
            make.top.equalTo(topBackgroundBoard.snp.bottom).offset(92.1)
            make.centerX.equalToSuperview()
        }
        addBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(72)
            make.right.equalTo(Util.isIPad ? -29 : -G.share.w(20))
            make.bottom.equalTo(Util.isIPad ? -87 : -G.share.h(48))
        }
    }
}
