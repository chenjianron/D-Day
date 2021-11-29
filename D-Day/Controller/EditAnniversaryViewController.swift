//
//  EditAnniversaryViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/21.
//

import Toolkit

class EditAnniversaryViewController:UIViewController{

    enum EditType:Int{
        case Date = 0
        case SetTopSwitch = 1
        case RemindSwitch = 2
        case RemindType = 3
        case RemindTime = 4
    }
    struct EditModel {
        let title:String
        let type:EditType
    }
    let CellID = "EditTableViewCell"
    var tableviewViewModel = TableviewViewModel(dataManager: LoveAnniversariesManager.default)
    var bannerView: UIView? {
        return Marketing.shared.bannerView(.EditPageBanner, rootViewController:self)
    }
    var bannerInset: CGFloat {
        if bannerView != nil {
            return Ad.default.adaptiveBannerHeight
        } else {
            return 0
        }
    }
    
    var completion:(()->Void)?
    var addAnniversaryCompletion:((_ anniversary:AnniversaryModel)->Void)?
    var anniversary:AnniversaryModel?
    var newAnniversary:AnniversaryModel?
    var viewControllerName:String?
    
    lazy var leftBarBtn:UIBarButtonItem = {
        let leftBarBtn = UIBarButtonItem(image: #imageLiteral(resourceName: "Back").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(backToPrevious))
        return leftBarBtn
    }()
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = __("名称:")
        label.font = UIFont.systemFont(ofSize: 17)
        label.textColor = .gray
        return label
    }()
    lazy var textField:UITextField = {
        let object = UITextField()
        object.returnKeyType = .done
        object.backgroundColor = UIColor(hex: 0xF8F8F8)
        object.leftViewMode = .always
        object.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        object.layer.cornerRadius = 10
        object.layer.masksToBounds = true
        object.clearButtonMode = .whileEditing
//        object.addTarget(self, action: #selector(textFieldDidEndEditing(_:)), for: .editingDidEndOnExit)
        object.delegate = self
        return object
    }()
    lazy var tableView:UITableView = {
        let object = UITableView(frame: .zero,style: .plain)
        object.backgroundColor = .white
        object.estimatedRowHeight = 48
        object.separatorStyle = .none
        object.dataSource = self
        object.delegate = self
        object.register(AnniversaryEditTableViewCell.classForCoder(), forCellReuseIdentifier: NSStringFromClass(AnniversaryEditTableViewCell.self))
        return object
    }()
    lazy var saveBtn:UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 10
        button.setTitle(__("保存"), for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = K.Color.ThemeColor
        button.titleLabel?.font = .systemFont(ofSize: 16)
        button.addTarget(self, action: #selector(okButtonDidClick), for: .touchUpInside)
        return button
    }()
    
    lazy var dataSource = [EditModel(title: __("日期:"), type: .Date),
                            EditModel(title: __("置顶:"), type: .SetTopSwitch),
                            EditModel(title: __("提醒:"), type: .RemindSwitch)]
    lazy var remindItem = [EditModel(title: __("提醒方式:"), type: .RemindType),
                           EditModel(title: __("提醒时间:"), type: .RemindTime)]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpNewAnniversary()
        setUpUI()
        setupAdBannerView()
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange), name: UITextField.textDidChangeNotification, object: textField)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Statistics.beginLogPageView("编辑页")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Statistics.endLogPageView("编辑页")
    }
}

//MARK: - Private
extension EditAnniversaryViewController {
    
    func setUpNewAnniversary(){
        if anniversary?.remindDate != nil {
            dataSource.insert(contentsOf: remindItem, at: dataSource.count)
        }
        if anniversary != nil {
            newAnniversary =  AnniversaryModel(anniversary!.id, anniversary!.date, anniversary!.title, anniversary!.isSetTop, anniversary!.isRealized, anniversary?.remindDate,anniversary?.remindType,anniversary?.backgroundImage)
        } else {
            newAnniversary = AnniversaryModel(UUID().uuidString, Date(), "", false, false, nil, nil,nil)
        }
    }
}

//MARK: - TableView
extension EditAnniversaryViewController:UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NSStringFromClass(AnniversaryEditTableViewCell.self),for: indexPath) as! AnniversaryEditTableViewCell
        cell.title.text = dataSource[indexPath.row].title
        // 日期
        if dataSource[indexPath.row].type == .Date {
            cell.timeLabel.isHidden = false
            cell.timeLabel.text = newAnniversary?.date.toStringWithFormat("yyyy.MM.dd")
        }
        // 置顶开关及其值
        if dataSource[indexPath.row].type == .SetTopSwitch {
            cell.switchIcon.isHidden = false
            cell.switchIcon.isOn = newAnniversary!.isSetTop
        }
        //时间提醒开关及其值
        if dataSource[indexPath.row].type == .RemindSwitch {
            cell.switchIcon.isHidden = false
            cell.switchIcon.isOn = newAnniversary!.remindDate != nil
        }
        cell.imageIcon.isHidden = dataSource[indexPath.row].type == .SetTopSwitch || dataSource[indexPath.row].type == .RemindSwitch
        //提醒方式
        if dataSource[indexPath.row].type == .RemindType {
            cell.timeLabel.isHidden = false
            cell.timeLabel.text = RemindManager.default.frequencys[newAnniversary!.remindType!]
        }
        //提醒时间
        if dataSource[indexPath.row].type == .RemindTime {
            cell.timeLabel.isHidden = false
            cell.timeLabel.text = newAnniversary!.remindDate!.toString2()
        }
        // 开关点击事件
        if dataSource[indexPath.row].type == .SetTopSwitch{
            cell.switchClickEvent = { [self] isOn in
                Statistics.event(.EditTap, label: "置顶")
                if isOn {
                    newAnniversary!.isSetTop = !newAnniversary!.isSetTop
                } else {
                    newAnniversary!.isSetTop = false
                }
            }
        }
        if dataSource[indexPath.row].type == .RemindSwitch {
            cell.switchClickEvent = { [self] isOn in
                if isOn {
                    Statistics.event(.EditTap, label: "提醒")
                    newAnniversary?.remindDate = RemindManager.default.defaultSelectTime
                    newAnniversary?.remindType = RemindManager.default.defaultFrequencySelectIndex
                    dataSource.insert(remindItem[0], at: dataSource.count)
                    tableView.insertRows(at: [IndexPath(row: dataSource.count - 1, section: 0)], with: .automatic)
                    tableView.scrollToRow(at: IndexPath(row: dataSource.count - 1, section: 0), at: .bottom, animated: true)
                    dataSource.insert(remindItem[1], at: dataSource.count)
                    tableView.insertRows(at: [IndexPath(row: dataSource.count - 1, section: 0)], with: .automatic)
                    tableView.scrollToRow(at: IndexPath(row: dataSource.count - 1, section: 0), at: .bottom, animated: true)
                } else {
                    newAnniversary!.remindDate = nil
                    newAnniversary!.remindType = nil
                    dataSource.removeLast()
                    tableView.deleteRows(at: [IndexPath(row: self.dataSource.count, section: 0)], with: .automatic)
                    dataSource.removeLast()
                    tableView.deleteRows(at: [IndexPath(row: self.dataSource.count, section: 0)], with: .automatic)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            Statistics.event(.EditTap, label: "日期")
            let datePickerViewController = DatePickerViewController()
            datePickerViewController.date = newAnniversary!.date
            datePickerViewController.selectIndexRow = indexPath.row
            datePickerViewController.completion = { [self] selectTime, selectIndexRow in
                newAnniversary!.date = selectTime
                self.tableView.reloadRows(at: [IndexPath(row: selectIndexRow, section: 0)], with: .automatic)
            }
            datePickerViewController.modalPresentationStyle = .custom
            navigationController?.present(datePickerViewController, animated: false, completion: nil)
        case 3:
            Statistics.event(.EditTap, label: "提醒方式")
            let frequencySelectViewController = FrequencySelectViewController()
            frequencySelectViewController.selectIndexRow = indexPath.row
            frequencySelectViewController.completion = { [self] selectRow,selectIndexRow in
                newAnniversary!.remindType = selectRow
                tableView.reloadRows(at: [IndexPath(row:selectIndexRow,section:0)], with: .automatic)
            }
            frequencySelectViewController.modalPresentationStyle = .custom
            navigationController?.present(frequencySelectViewController, animated: false, completion: nil)
        case 4:
            Statistics.event(.EditTap, label: "提醒时间")
            let remindDatePickViewController = RemindDatePickerViewController()
            remindDatePickViewController.selectIndexRow = indexPath.row
            remindDatePickViewController.completion = { [self] selectRemindDate,selectIndexRow in
                newAnniversary!.remindDate = selectRemindDate
                tableView.reloadRows(at: [IndexPath(row:selectIndexRow,section:0)], with: .automatic)
            }
            remindDatePickViewController.modalPresentationStyle = .custom
            navigationController?.present(remindDatePickViewController, animated: false, completion: nil)
        default:
            break
        }
    }
}

//MARK: - Interaction
extension EditAnniversaryViewController {
    
    //编辑或者添加二次权限
    func exitSecond(completion: @escaping()->Void){
        let alert = UIAlertController(title: __("确认退出"), message: __("所设纪念日未保存，确认退出吗？"), preferredStyle: .alert)
        let cancel = UIAlertAction(title: __("取消"), style: .cancel) { (action) in
        }
        let delete = UIAlertAction(title: __("确认"), style: .default, handler: {_ in completion()})
        alert.addAction(cancel)
        alert.addAction(delete)
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func backToPrevious(){
        Statistics.event(.EditTap, label: "返回")
        exitSecond {
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func tap(){
        view.endEditing(true)
    }
    
    @objc func okButtonDidClick(){
        newAnniversary?.title = textField.text!
        if anniversary != nil {
            if anniversary?.remindDate != nil {
                RemindManager.default.removeLocalRemind(anniversary: anniversary!)
            }
            if anniversary?.isSetTop != newAnniversary!.isSetTop {
                tableviewViewModel.setTopAnniversary(anniversary!){ (data) in
                }
            }
            anniversary?.title = newAnniversary!.title
            anniversary?.date = newAnniversary!.date
            anniversary?.remindType = newAnniversary?.remindType
            anniversary?.remindDate = newAnniversary?.remindDate
        } else {
            anniversary = newAnniversary
        }
        // 提醒功能
        if anniversary?.remindDate != nil {
            RemindManager.default.addLocalRemind(anniversary: anniversary!)
        }
        
        if viewControllerName == __("编辑纪念日") {
            let ctx = Ad.default.interstitialSignal(key: K.ParamName.ConfirmAddAnniversaryInterstitial)
            ctx.didEndAction = {  [self] _ in
                navigationController?.popViewController(animated: true)
                completion!()
            }
        } else {
            let ctx = Ad.default.interstitialSignal(key: K.ParamName.ConfirmAddAnniversaryInterstitial)
            ctx.didEndAction = {  [self] _ in
                navigationController?.popViewController(animated: true)
                addAnniversaryCompletion!(anniversary!)
            }
        }
    }
}

//MARK: - TextView
extension EditAnniversaryViewController:UITextFieldDelegate {
    
    @objc func textFieldDidChange(){
        if textField.text?.count == 0 {
            saveBtn.isEnabled = false
            saveBtn.backgroundColor = UIColor(hex: 0xFFD3E6)
        } else {
            saveBtn.isEnabled = true
            saveBtn.backgroundColor = K.Color.ThemeColor
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
}


// MARK: - UI
extension EditAnniversaryViewController {
    
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
    
    func setUpUI(){
        let tap1 = UITapGestureRecognizer(target: self, action:#selector(tap))
        tap1.cancelsTouchesInView = false
        view.addGestureRecognizer(tap1)
        navigationItem.leftBarButtonItem = leftBarBtn
        navigationItem.title = viewControllerName!
        view.backgroundColor = .white
        view.addSubview(titleLabel)
        view.addSubview(textField)
        view.addSubview(tableView)
        view.addSubview(saveBtn)
        setUpTextFieldText()
        setUpConstraints()
    }
    
    func setUpConstraints(){
        
        titleLabel.snp.makeConstraints{ make in
            make.width.equalTo(51)
            make.height.equalTo(24)
            make.left.equalToSuperview().offset(22)
            make.top.equalTo(safeAreaTop).offset(40 + bannerInset)
        }
        textField.snp.makeConstraints{ make in
            make.height.equalTo(48)
            make.top.equalTo(safeAreaTop).offset(28 + bannerInset)
            make.right.equalToSuperview().offset(-24)
            make.left.equalTo(titleLabel.snp.right).offset(4)
        }
        tableView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalToSuperview().multipliedBy(0.4)
            make.top.equalTo(textField.snp.bottom).offset(18)
        }
        saveBtn.snp.makeConstraints{ make in
            make.width.equalTo(331)
            make.height.equalTo(45)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(safeAreaBottom).offset(G.share.h(-145))
        }
    }
    
    func setUpTextFieldText(){
        textField.text = __(newAnniversary?.title ?? "")
        if newAnniversary?.title.count == 0 {
            saveBtn.isEnabled = false
            saveBtn.backgroundColor = UIColor(hex: 0xFFD3E6)
        }
    }
}
