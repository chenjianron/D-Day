//
//  SettingPasswordViewController.swift
//  D-Day
//
//  Created by GC on 2021/11/5.
//

import Toolkit
import LocalAuthentication
import AudioToolbox

class SettingPasswordViewController:UIViewController{
    
    struct PasswordNumberModel {
        var text:String
        var isSelected:Bool
    }
    
    var completion:(()->())?

    var firstLauchAppCompletion:(()->())?
    var isSetting:Bool?
    
    var isCancel = false
    var password:String = ""
    var firstPassword:String = ""
    let context = LAContext()
    var identification = isiPhoneX ? "Face ID" : "Touch ID"
    var textFieldDataSource = [false,false,false,false]
    var passwordNumberDataSource = [
        PasswordNumberModel(text: "1", isSelected: false),
        PasswordNumberModel(text: "2", isSelected: false),
        PasswordNumberModel(text: "3", isSelected: false),
        PasswordNumberModel(text: "4", isSelected: false),
        PasswordNumberModel(text: "5", isSelected: false),
        PasswordNumberModel(text: "6", isSelected: false),
        PasswordNumberModel(text: "7", isSelected: false),
        PasswordNumberModel(text: "8", isSelected: false),
        PasswordNumberModel(text: "9", isSelected: false),
        PasswordNumberModel(text: "指纹/面部", isSelected: false),
        PasswordNumberModel(text: "0", isSelected: false),
        PasswordNumberModel(text: "cancel", isSelected: false)]
    
    lazy var promptLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    lazy var errorLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 12)
        label.text = __("两次密码不一致，请重新设置！")
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    lazy var collectionViewLayout:UICollectionViewFlowLayout = {
        let object = UICollectionViewFlowLayout()
        object.sectionInset = UIEdgeInsets(top:0, left:0, bottom:0, right: 0)
        object.scrollDirection = .horizontal
        object.minimumLineSpacing = 32
        object.minimumInteritemSpacing = 0
        object.itemSize = CGSize(width: 40, height: 48)
        return object
    }()
    lazy var collectionView:UICollectionView = {
        let collection = UICollectionView(frame: .zero,collectionViewLayout: self.collectionViewLayout)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .white
        collection.tag = 1
        collection.register(TextFieldCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(TextFieldCollectionViewCell.self))
        return collection
    }()
    lazy var collectionViewLayout2:UICollectionViewFlowLayout = {
        let object = UICollectionViewFlowLayout()
        object.sectionInset = UIEdgeInsets(top:0, left:0, bottom:0, right: 0)
        object.scrollDirection = .vertical
        object.minimumLineSpacing = 17
        object.minimumInteritemSpacing = 0
        object.itemSize = CGSize(width: 115, height: 50)
        return object
    }()
    lazy var collectionView2:UICollectionView = {
        let collection = UICollectionView(frame: .zero,collectionViewLayout: self.collectionViewLayout2)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .white
        collection.tag = 2
        collection.register(PasswordCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(PasswordCollectionViewCell.self))
        return collection
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        if isSetting == true {
            showCloseItem()
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = true
            promptLabel.text = __("请输入密码")
        }
        setUpUI()
        setUpConstraints()
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("密码页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("密码页")
    }
    
}

//MARK: - UICollectionViewDelegate UICollectionViewDataSource
extension SettingPasswordViewController: UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var count:Int?
        
        if collectionView.tag == 1 {
            count = 4
        }
        
        if collectionView.tag == 2 {
            count = 12
        }
        return count!
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell:UICollectionViewCell?
        
        if collectionView.tag == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(TextFieldCollectionViewCell.self), for: indexPath)
            if let textFieldCell = cell as? TextFieldCollectionViewCell {
                textFieldCell.numberPlaceholder.isHidden = !textFieldDataSource[indexPath.row]
            }
        }
        
        if collectionView.tag == 2 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PasswordCollectionViewCell.self), for: indexPath)
            if let textFieldCell = cell as? PasswordCollectionViewCell {
                textFieldCell.passwordNumber.text = passwordNumberDataSource[indexPath.row].text
                if passwordNumberDataSource[indexPath.row].isSelected == true {
                    textFieldCell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFF1F7).cgColor
                } else {
                    textFieldCell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFFFFF).cgColor
                }
                if indexPath.row == 9 && isSetting == true {
                    textFieldCell.image.image = isiPhoneX ? #imageLiteral(resourceName: "face") : #imageLiteral(resourceName: "figger")
                    textFieldCell.isHidden = true
                }
                if indexPath.row == 9 && isSetting == false {
                    if !Util.isIPad{
                        textFieldCell.image.image = isiPhoneX ? #imageLiteral(resourceName: "face") : #imageLiteral(resourceName: "figger")
                    } else {
                        textFieldCell.image.image = #imageLiteral(resourceName: "figger")
                    }
                    textFieldCell.image.isHidden = isCancel
                    textFieldCell.passwordNumber.isHidden = true
                    textFieldCell.isHidden = !AppStorageGroupsManager.default.bool(forKey: K.UserDefaultsKey.IsFaceIDorTouchID)
                }
                if indexPath.row == 11 {
                    textFieldCell.passwordNumber.isHidden = true
                    textFieldCell.image.isHidden = false
                    textFieldCell.image.image = #imageLiteral(resourceName: "Password-Back").withRenderingMode(.alwaysOriginal)
                }
            }
        }
        return cell!
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 2 && isSetting == true {
            if indexPath.row != 11 && indexPath.row != 9 {
                Statistics.event(.PasswordTap, label: "数字键")
                AudioServicesPlaySystemSound(1123)
                let cell = collectionView.cellForItem(at: indexPath) as! PasswordCollectionViewCell
                cell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFF1F7).cgColor
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                    cell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFFFFF).cgColor
                })
                
                if indexPath.row >= 0 && indexPath.row <= 8 {
                    if firstPassword.count == 4 && password.count == 4{
                    } else {
                        password += String(indexPath.row + 1)
                    }
                } else {
                    password += "0"
                }
                if password.count == 1 {
                    errorLabel.isHidden = true
                    textFieldDataSource[0] = true
                } else if password.count == 2 {
                    textFieldDataSource[1] = true
                } else if password.count == 3 {
                    textFieldDataSource[2] = true
                } else if password.count == 4 && firstPassword.count == 0 {
                    firstPassword = password
                    password = ""
                    textFieldDataSource[3] = true
                    Timer.scheduledTimer(withTimeInterval: 0.01, repeats: false, block: { [self] _ in
                        promptLabel.text = __("确认密码")
                        textFieldDataSource = [false,false,false,false]
                        self.collectionView.reloadData()
                    })
                } else if password.count == 4 && firstPassword.count == 4 {
                    textFieldDataSource[3] = true
//                    self.collectionView.reloadData()
                    Timer.scheduledTimer(withTimeInterval: 0.02, repeats: false, block: { [self] _ in
                        print(password + "  " + firstPassword)
                        if firstPassword != password {
                            //建立的SystemSoundID对象
                            let soundID = SystemSoundID(kSystemSoundID_Vibrate)
                            //振动
                            AudioServicesPlaySystemSound(soundID)
                            firstPassword = ""
                            password = ""
                            promptLabel.text = __("设置密码")
                            errorLabel.isHidden = false
                            textFieldDataSource = [false,false,false,false]
                        } else {
                            AppStorageGroupsManager.default.set(true, forKey: K.UserDefaultsKey.IsSettingPassword)
                            AppStorageGroupsManager.default.setValue(password, forKey: K.UserDefaultsKey.Password)
                            if completion == nil {
                                firstLauchAppCompletion!()
                            } else {
                                completion!()
                            }
                            navigationController?.popViewController(animated: false)
                        }
                        self.collectionView.reloadData()
                    })
                }
                self.collectionView.reloadData()
            }
            
            if indexPath.row == 11 {
                Statistics.event(.PasswordTap, label: "删除")
                AudioServicesPlaySystemSound(1155)
                if password.count != 0 {
                    if password.count == 1 {
                        textFieldDataSource[0] = false
                    } else if password.count == 2 {
                        textFieldDataSource[1] = false
                    } else if password.count == 3 {
                        textFieldDataSource[2] = false
                    } else if password.count == 4 {
                        textFieldDataSource[3] = false
                    }
                    password.removeLast()
                    self.collectionView.reloadData()
                }
            }
        }
        
        if collectionView.tag == 2 && isSetting == false {
            
            if indexPath.row != 11 && indexPath.row != 9 {
                Statistics.event(.PasswordTap, label: "数字键")
                AudioServicesPlaySystemSound(1123)
                let cell = collectionView.cellForItem(at: indexPath) as! PasswordCollectionViewCell
                cell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFF1F7).cgColor
                Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { _ in
                    cell.passwordNumber.layer.backgroundColor = UIColor(hex: 0xFFFFFF).cgColor
                })
                
                if indexPath.row >= 0 && indexPath.row <= 8 {
                    if password.count != 4{
                        password += String(indexPath.row + 1)
                    }
                } else {
                    password += "0"
                }
                
                if password.count == 1 {
                    errorLabel.isHidden = true
                    textFieldDataSource[0] = true
                } else if password.count == 2 {
                    textFieldDataSource[1] = true
                } else if password.count == 3 {
                    textFieldDataSource[2] = true
                } else if password.count == 4  {
                    textFieldDataSource[3] = true
                    Timer.scheduledTimer(withTimeInterval: 0.2, repeats: false, block: { [self]_ in
                        if AppStorageGroupsManager.default.value(forKey: K.UserDefaultsKey.Password) as! String == password {
                            if completion == nil {
                                firstLauchAppCompletion!()
                            } else {
                                completion!()
                            }
                        } else {
                            textFieldDataSource = [false,false,false,false]
                            //建立的SystemSoundID对象
                            let soundID = SystemSoundID(kSystemSoundID_Vibrate)
                            //振动
                            AudioServicesPlaySystemSound(soundID)
                            //                        let generator = UIImpactFeedbackGenerator(style: .heavy)
                            //                        generator.impactOccurred()
                            password = ""
                            self.collectionView.reloadData()
                        }
                    })
                }
                self.collectionView.reloadData()
            }
            
            if indexPath.row == 11 {
                Statistics.event(.PasswordTap, label: "删除")
                AudioServicesPlaySystemSound(1155)
                if password.count != 0 {
                    if password.count == 1 {
                        textFieldDataSource[0] = false
                    } else if password.count == 2 {
                        textFieldDataSource[1] = false
                    } else if password.count == 3 {
                        textFieldDataSource[2] = false
                    } else if password.count == 4 {
                        textFieldDataSource[3] = false
                    }
                    password.removeLast()
                    self.collectionView.reloadData()
                }
            }
            if indexPath.row == 9 {
                Statistics.event(.PasswordTap, label: "面部/指纹")
                AudioServicesPlaySystemSound(1156)
                validateBiometrics()
            }
        }
    }
}

//MARK: - Interaction
extension SettingPasswordViewController {
    @objc override func closeItemDidClick(_ sender: UIBarButtonItem) {
        Statistics.event(.PasswordTap, label: "关闭")
        self.navigationController?.popViewController(animated: false)
    }
}

// MARK: - Private
extension SettingPasswordViewController {
    
    @objc func recover(sender:Timer){
        let indexPath = sender.userInfo as! IndexPath
        passwordNumberDataSource[indexPath.row].isSelected = false
        collectionView2.reloadItems(at: [indexPath])
    }
    
    func notifyUser(_ msg: String, err: String?)  {
        print("msg > \(msg)")
        print("err > \(String(describing: err))")
    }
    
    func unlockLocalAuth() {
        let passwordContent = LAContext()
        var error: NSError?
        if passwordContent.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error){
            passwordContent.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: __("需要您的密码，才能启用 Touch ID")) { [self] (success, err) in
                if success {
                    print("密码解锁成功")
                }else{
                    isCancel = true
                    DispatchQueue.main.async {
                        collectionView2.reloadItems(at: [IndexPath(row: 9, section: 0)])
                    }
                }
            }
        }else{
            
        }
    }
    
    func validateBiometrics() {
        var error: NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: __("进行验证")) { [self] (success, error) in
                if success {
                    DispatchQueue.main.async {
                        AppStorageGroupsManager.default.set(true, forKey: K.UserDefaultsKey.IsConfirmID)
                        if completion == nil {
                            firstLauchAppCompletion!()
                        } else {
                            completion!()
                        }
                    }
                } else {
                    
                }
            }
            //            authorizeBiometrics(context)
        } else {
            let code = LAError.Code(rawValue: error!.code)
            switch code! {
            case .biometryLockout:
                unlockLocalAuth()
                break
            case .biometryNotAvailable:
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
}


// MARK: -UI
extension SettingPasswordViewController{
    
    func setUpUI(){
        
        if isSetting == true {
            promptLabel.text = __("设置密码")
        }
        view.backgroundColor = .white
        view.addSubview(promptLabel)
        view.addSubview(collectionView)
        view.addSubview(collectionView2)
        view.addSubview(errorLabel)
    }
    
    func setUpConstraints(){
        
        promptLabel.snp.makeConstraints{ make in
            make.top.equalTo(safeAreaTop).offset(G.share.h(86))
            make.centerX.equalToSuperview()
        }
        collectionView.snp.makeConstraints{ make in
            make.top.equalTo(promptLabel.snp.bottom).offset(G.share.h(48))
            make.height.equalTo(48)
            make.width.equalTo(256)
            make.centerX.equalToSuperview()
        }
        collectionView2.snp.makeConstraints{ make in
            make.top.equalTo(collectionView.snp.bottom).offset(G.share.h(148))
            make.height.equalTo(260)
            make.width.equalTo(375)
            make.centerX.equalToSuperview()
        }
        errorLabel.snp.makeConstraints{ make in
            make.top.equalTo(collectionView.snp.bottom).offset(29)
            make.centerX.equalToSuperview()
        }
        
    }
}
