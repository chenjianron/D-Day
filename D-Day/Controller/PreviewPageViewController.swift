//
//  PreviewPageViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/11.
//

import Toolkit
import SnapKit

class PreviewPageViewController: UIViewController {
    
    lazy var rightBarButtonItem:UIBarButtonItem = {
        return UIBarButtonItem(title: __("跳过"), style: .plain, target: self, action: #selector(rightBarButtonItemClick)) 
    }()
    lazy var prompingLabel:UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = __("选择恋情开始的时间")
        return label
    }()
    lazy var datePicker:UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        if Helper.inChina() {
            picker.locale = Locale(identifier: "zh_TW")
        }
        picker.date = Date()
        picker.maximumDate = Date()
        return picker
    }()
    lazy var okButton:UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.backgroundColor = K.Color.ThemeColor
        button.setTitle(__("确定"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonDidClick), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("初始页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("初始页")
    }
}

// MARK: - Private
extension PreviewPageViewController {
    
    func setupWindow(){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.window?.rootViewController = DDNavigationViewController(rootViewController: MainViewController())
    }
}

// MARK: - Interaction
extension PreviewPageViewController {
    
    @objc func rightBarButtonItemClick(_ sender: UIBarButtonItem){
        HeadInfoManager.default.loveDate = Date()
        setupWindow()
        Statistics.event(.ReviewTap, label: "修改昵称")
    }
    
    @objc func okButtonDidClick(_ sender: UIButton){
        HeadInfoManager.default.loveDate = datePicker.date
        setupWindow()
        Statistics.event(.ReviewTap, label: "确定")
    }
}


// MARK: - UI
extension PreviewPageViewController {
    
    func setUpUI(){
        
        navigationItem.rightBarButtonItem = rightBarButtonItem
        navigationController?.navigationBar.tintColor = .gray
        
        view.addSubview(prompingLabel)
        view.addSubview(datePicker)
        view.addSubview(okButton)
        
        setUpConstrains()
    }
    
    func setUpConstrains(){
        
        prompingLabel.snp.makeConstraints { make in
            make.top.equalTo(safeAreaTop).offset(G.share.h(88))
            make.centerX.equalToSuperview()
        }
        datePicker.snp.makeConstraints { make in
            make.top.equalTo(prompingLabel.snp.bottom).offset(G.share.h(56))
            make.centerX.equalToSuperview()
        }
        okButton.snp.makeConstraints { make in
            make.width.equalTo(297)
            make.height.equalTo(45)
            make.top.equalTo(datePicker.snp.bottom).offset(G.share.h(87))
            make.centerX.equalToSuperview()
        }
        
    }
    
    @objc func applKicationDidBecomeActive(notification: NSNotification){
        if AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsSettingPassword){
            print(Util.topViewController().classForCoder)
            if Util.topViewController().classForCoder != SettingPasswordViewController.classForCoder() {
                let checkPasswordController = SettingPasswordViewController()
                checkPasswordController.isSetting = false
                checkPasswordController.completion = {
                    self.navigationController?.popViewController(animated: true)
                }
                navigationController?.pushViewController(checkPasswordController, animated: false)
            }
        }
    }
}
