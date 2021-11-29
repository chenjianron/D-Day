//
//  NoteTableViewCell.swift
//  D-Day
//
//  Created by GC on 2021/11/2.
//

import Toolkit

class NoteTableViewCell: UITableViewCell {
        
    var moodImages:[String] = ["Mood-1.pdf","Mood-2.pdf","Mood-3.pdf","Mood-4.pdf","Mood-5.pdf"]
    
    lazy var moodImageView:UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var contentLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    lazy var iconView:UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "ClickIcon")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var lineView:UIView = {
        let line = UIView()
        line.backgroundColor = UIColor(hex: 0xF1F1F1)
        return line
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setUpUI()
        setUpConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI(){
        contentView.addSubview(moodImageView)
        contentView.addSubview(contentLabel)
        contentView.addSubview(iconView)
        contentView.addSubview(lineView)
    }
    
    func setUpConstraints(){
        moodImageView.snp.makeConstraints{ make in
            make.width.height.equalTo(30)
            make.left.equalToSuperview().offset(22)
            make.centerY.equalToSuperview()
        }
        contentLabel.snp.makeConstraints{ make in
            make.left.equalToSuperview().offset(62)
            make.right.equalToSuperview().offset(-47)
            make.centerY.equalToSuperview()
        }
        iconView.snp.makeConstraints{ make in
            make.width.height.equalTo(14)
            make.right.equalToSuperview().offset(-22)
            make.centerY.equalToSuperview()
        }
        lineView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(1)
            make.bottom.equalToSuperview()
        }
    }
    
    func setData(noteModel:NoteManager.NoteModel){
        moodImageView.image = UIImage(named: moodImages[noteModel.selectMoodIndex])
        contentLabel.text = noteModel.contentText
    }
}
