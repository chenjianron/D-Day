//
//  NoteClickActionViewController.swift
//  D-Day
//
//  Created by GC on 2021/11/3.
//

import Toolkit

class NoteClickActionViewController : UIViewController{
    
    var editCompletion:((_ selectedMoodImageIndex:Int,_ contentText:String)->Void)?
    var deleteCompletion:(()->Void)?
    var selectedIndex:Int?
    
    lazy var backgroundBoard : UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    lazy var edtiBtn:UIButton = {
        let button = UIButton()
        button.setTitle(__("编辑"), for: .normal)
        button.backgroundColor = UIColor(hex: 0xFFB730)
        button.addTarget(self, action: #selector(editButtonDidClick), for: .touchUpInside)
        return button
    }()
    lazy var deleteBtn:UIButton = {
        let button = UIButton()
        button.setTitle(__("删除"), for: .normal)
        button.backgroundColor = K.Color.ThemeColor
        button.addTarget(self, action: #selector(deleteButtonDidClick), for: .touchUpInside)
        return button
    }()
    lazy var moodImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.showsVerticalScrollIndicator = true
        return view
    }()
    lazy var contentLabel :UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpConstraints()
        showAnimate()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view != backgroundBoard {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

//MARK: - Interaction
extension NoteClickActionViewController {
    
    @objc func editButtonDidClick(){
        editCompletion!(selectedIndex!, contentLabel.text!)
        dismiss(animated: true, completion: nil)
    }
    
    @objc func deleteButtonDidClick(){
        deleteCompletion!()
//        dismiss(animated: true, completion: nil)
    }
}

// MARK: - UI
extension NoteClickActionViewController {
    
    func setUpUI(){
        view.addSubview(backgroundBoard)
        backgroundBoard.addSubview(edtiBtn)
        backgroundBoard.addSubview(deleteBtn)
        backgroundBoard.addSubview(moodImageView)
        backgroundBoard.addSubview(scrollView)
        scrollView.addSubview(contentLabel)
    }
    
    func setUpConstraints(){
        backgroundBoard.snp.makeConstraints{ make in
            make.width.equalTo(330)
            make.height.equalTo(375)
            make.center.equalToSuperview()
        }
        moodImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(82)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(20)
        }
        scrollView.snp.makeConstraints{ make in
            make.width.equalTo(290)
            make.height.equalTo(185)
            make.centerX.equalToSuperview()
            make.top.equalTo(moodImageView.snp.bottom).offset(18)
        }
        contentLabel.snp.makeConstraints{ make in
            make.width.equalTo(286)
            make.top.bottom.equalToSuperview()
//            make.center.equalToSuperview()
        }
        edtiBtn.snp.makeConstraints{ make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(48)
            make.bottom.left.equalToSuperview()
        }
        deleteBtn.snp.makeConstraints{ make in
            make.width.equalToSuperview().multipliedBy(0.5)
            make.height.equalTo(48)
            make.right.bottom.equalToSuperview()
        }
    }
    func showAnimate(){
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.4)
            }
        }
    }
}
