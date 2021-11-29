//
//  CalendarNoteHeader.swift
//  D-Day
//
//  Created by GC on 2021/10/29.
//
import Toolkit

class CalendarNoteHeader: UIView {
    
    var addBtnClickComplete:(()->Void)?
    
    lazy var imageView:UIImageView = {
        let image = UIImageView()
        image.image = #imageLiteral(resourceName: "NoteIcon")
        return image
    }()
    lazy var timeLabel:UILabel = {
        let label = UILabel()
        label.textColor = K.Color.SecondLevelColor
        return label
    }()
    lazy var addBtn:UIButton = {
        let btn = UIButton()
        btn.setImage(#imageLiteral(resourceName: "AddNoteBtn"), for: .normal)
        btn.addTarget(self, action: #selector(addNote), for: .touchUpInside)
        return btn
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func addNote(){
        addBtnClickComplete?()
    }
    
    func setUpUI(){
        addSubview(imageView)
        addSubview(timeLabel)
        addSubview(addBtn)
    }
    
    func setUpConstraints(){
        imageView.snp.makeConstraints{ make in
            make.width.equalTo(30)
            make.height.equalTo(22)
            make.top.equalToSuperview().offset(22.5)
            make.left.equalToSuperview().offset(22.5)
        }
        timeLabel.snp.makeConstraints{ make in
            make.width.equalTo(220)
            make.left.equalTo(imageView.snp.right).offset(4.4)
            make.top.equalToSuperview().offset(23)
        }
        addBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(26)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(23)
        }
    }
}
