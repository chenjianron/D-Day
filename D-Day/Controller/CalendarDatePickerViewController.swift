//
//  CalendarDatePickerViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/28.
//

import Toolkit

class CalendarDatePickerViewController:UIViewController {
    
    var date:Date?{
        willSet(newValue){
            datePicker.date = newValue!
        }
    }
    var completion:((Date)->Void)?
    
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
    lazy var datePicker:UIDatePicker = {
        let picker = UIDatePicker()
        if Helper.inChina() {
            picker.locale = Locale(identifier: "zh_TW")
        }
        picker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        picker.maximumDate = "2200-12-31".toDate1()
        picker.minimumDate = "1900-01-01".toDate1()
//        if  #available(iOS 13.0, *),!Util.isIPad{
//            picker.subviews.first?.subviews.first?.subviews[2].isHidden = true
//            picker.subviews.first?.subviews.first?.subviews[0].frame.origin.x += 30
//            picker.subviews.first?.subviews.first?.subviews[1].frame.origin.x += 60
//            picker.subviews[0].subviews[1].width = 283
//            picker.subviews[0].subviews[2].width = 283
//            picker.subviews[0].subviews[1].frame.origin.x += 17
//            picker.subviews[0].subviews[2].frame.origin.x += 17
//        }
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
extension CalendarDatePickerViewController {
    
    @objc func cancelButtonDidClick(_ sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func okButtonDidClick(_ sender:UIButton){
        completion?(datePicker.date.toDay())
        dismiss(animated: true, completion: nil)
    }
}



// MARK: - UI
extension CalendarDatePickerViewController {
    
    func setUpUI(){
        view.addSubview(backgroundBoard)
        backgroundBoard.addSubview(cancelBtn)
        backgroundBoard.addSubview(confirmBtn)
        backgroundBoard.addSubview(datePicker)
    }
    
    func setUpConstraints(){
        backgroundBoard.snp.makeConstraints{ make in
            make.width.equalTo(330)
            make.height.equalTo(285)
            make.centerX.equalToSuperview()
            make.top.equalTo(safeAreaTop).offset(G.share.h(200))
        }
        cancelBtn.snp.makeConstraints{ make in
            make.height.width.equalTo(20)
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(23)
        }
        confirmBtn.snp.makeConstraints{ make in
            make.height.width.equalTo(20)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-21)
        }
        datePicker.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(50)
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
