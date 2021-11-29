//
//  FrequentViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/25.
//
import Toolkit

class FrequencySelectViewController:UIViewController {
    
    var completion:((Int,Int)->Void)?
    var selectIndexRow:Int?
    
    let frequencys = RemindManager.default.frequencys
    
    var selectRow:Int = 0
    
    lazy var backgroundBoard:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    lazy var cancelBtn:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var confirmBtn:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "ConfirmIcon"), for: .normal)
        button.addTarget(self, action: #selector(okButtonDidClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var pickerView:UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        return picker
    }()
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view != backgroundBoard {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpConstraints()
        showAnimate()
    }
    
}

// MARK: - Interaction
extension FrequencySelectViewController {
    
    @objc func cancelButtonDidClick(_ sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func okButtonDidClick(_ sender:UIButton){
        completion?(selectRow,selectIndexRow!)
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIPickView
extension FrequencySelectViewController:UIPickerViewDelegate,UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        frequencys.count
    }
    
    func pickerView(_ pickerView: UIPickerView,
      titleForRow row: Int, forComponent component: Int)
      -> String? {
        return frequencys[row]
    }
    
    func pickerView(_ pickerView: UIPickerView,
      didSelectRow row: Int, inComponent component: Int) {
        selectRow = row
    }
}


// MARK: - UI
extension FrequencySelectViewController {
    
    func setUpUI(){
        view.addSubview(backgroundBoard)
        backgroundBoard.addSubview(cancelBtn)
        backgroundBoard.addSubview(confirmBtn)
        backgroundBoard.addSubview(pickerView)
    }
    
    func setUpConstraints(){
        backgroundBoard.snp.makeConstraints{ make in
            make.width.equalTo(330)
            make.height.equalTo(285)
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaTop).offset(200)
        }
        cancelBtn.snp.makeConstraints{ make in
            make.height.width.equalTo(23)
            make.top.equalToSuperview().offset(23)
            make.left.equalToSuperview().offset(23)
        }
        confirmBtn.snp.makeConstraints{ make in
            make.height.width.equalTo(23)
            make.top.equalToSuperview().offset(23)
            make.right.equalToSuperview().offset(-21)
        }
        pickerView.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(36)
            make.centerX.equalToSuperview()
        }
    }
    
    func showAnimate() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.4)
            }
        }
    }
}
