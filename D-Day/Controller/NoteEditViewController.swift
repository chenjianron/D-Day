//
//  NoteEditViewController.swift
//  D-Day
//
//  Created by GC on 2021/10/29.
//
import Toolkit

class NoteEditViewController:UIViewController{
    
    var completion:((_ selectMoodIndex:Int,_ contentText:String)->Void)?
    var dateString:String?
    
    var selectIndex:Int = 0
    
    lazy var backgroundBoard:UIView = {
        let view = UIView()
        if #available(iOS 11.0, *) {
            view.layer.maskedCorners = CACornerMask(rawValue: CACornerMask.layerMinXMinYCorner.rawValue | CACornerMask.layerMaxXMinYCorner.rawValue)
        } else {
            // Fallback on earlier versions
        }
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
        button.setImage(#imageLiteral(resourceName: "ConfirmBtn-Dis"), for: .normal)
        button.addTarget(self, action: #selector(okButtonDidClick(_:)), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    lazy var textLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        return label
    }()
    lazy var collectionViewLayout:UICollectionViewFlowLayout = {
        let object = UICollectionViewFlowLayout()
        object.sectionInset = UIEdgeInsets(top:0,left: 0,bottom: 0,right: 0)
        object.scrollDirection = .vertical
        object.minimumLineSpacing = 6
        object.minimumInteritemSpacing = 5
        object.itemSize = CGSize(width: G.share.w(50), height: G.share.h(50))
        return object
    }()
    lazy var collectionView:UICollectionView = {
        let collection = UICollectionView(frame: .zero,collectionViewLayout: self.collectionViewLayout)
        collection.showsHorizontalScrollIndicator = false
        collection.showsVerticalScrollIndicator = false
        collection.delegate = self
        collection.dataSource = self
        collection.backgroundColor = .white
        collection.register(MoodCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(MoodCollectionViewCell.self))
        return collection
    }()
    lazy var scrollView:UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = UIColor(hex: 0xF8F8F8)
        view.showsVerticalScrollIndicator = false
        view.isScrollEnabled = true
        return view
    }()
    lazy var textField:UITextView = {
        let textField = UITextView()
        textField.font = .systemFont(ofSize: 15)
        textField.tintColor = K.Color.ThemeColor
        textField.backgroundColor = UIColor(hex: 0xF8F8F8)
        textField.keyboardType = .default
        textField.returnKeyType = .go
        textField.delegate = self
        return textField
    }()
    lazy var hintLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        label.text = __("记录点什么···")
        return label
    }()
    
    lazy var moodImages:[String] = {
        return ["Mood-1.pdf","Mood-2.pdf","Mood-3.pdf","Mood-4.pdf","Mood-5.pdf"]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        setUpConstraints()
        showAnimate()
        checkTextView()
        textField.becomeFirstResponder()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowHandler(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            if touch.view != backgroundBoard {
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
}

//MARK: - UICollectionViewDelegate UICollectionViewDataSource
extension NoteEditViewController :UICollectionViewDataSource, UICollectionViewDelegate{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return moodImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(MoodCollectionViewCell.self), for: indexPath)
        if let moodCell = cell as? MoodCollectionViewCell {
            moodCell.moodImageView.image = UIImage(named: moodImages[indexPath.row])
            if indexPath.row == selectIndex {
                moodCell.setMoodCellBorder(true)
            } else {
                moodCell.setMoodCellBorder(false)
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath){
        selectIndex = indexPath.row
        collectionView.reloadData()
    }
    
}

// MARK: - Interaction
extension NoteEditViewController{
    
    @objc func cancelButtonDidClick(_ sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
    @objc func okButtonDidClick(_ sender:UIButton){
        let ctx = Ad.default.interstitialSignal(key: K.ParamName.AddNoteInterstitial)
        ctx.didEndAction = {  [self] _ in
            completion?(selectIndex,textField.text)
            view.endEditing(true)
    //        UIApplication.shared.keyWindow?.endEditing(true)
            dismiss(animated: true, completion: nil)
        }
        
    }
    
    @objc func keyboardWillShowHandler(notification: Notification){
        let keyboardInfo = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardHeight = UIScreen.main.bounds.height - keyboardInfo.origin.y
        backgroundBoard.snp.remakeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(G.share.h(335))
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-keyboardHeight)
        }
    }
}

// MARK: - TextView
extension NoteEditViewController:UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        checkTextView()
    }
    
    func checkTextView(){
        if textField.text.count > 0 {
            hintLabel.isHidden = true
            confirmBtn.setImage(#imageLiteral(resourceName: "ConfirmIcon"), for: .normal)
            confirmBtn.isEnabled = true
            
        } else {
            hintLabel.isHidden = false
            confirmBtn.setImage(#imageLiteral(resourceName: "ConfirmBtn-Dis"), for: .normal)
            confirmBtn.isEnabled = false
        }
    }
}

//MARK: - UI
extension NoteEditViewController {
    
    func setUpUI(){
        view.addSubview(backgroundBoard)
        backgroundBoard.addSubview(cancelBtn)
        backgroundBoard.addSubview(confirmBtn)
        backgroundBoard.addSubview(scrollView)
        backgroundBoard.addSubview(textLabel)
        backgroundBoard.addSubview(collectionView)
        scrollView.addSubview(textField)
        textField.addSubview(hintLabel)
    }
    
    func setUpConstraints(){
        backgroundBoard.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.height.equalTo(Util.isIPad ? G.share.h(335) : 335)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        cancelBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(20)
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(22)
        }
        confirmBtn.snp.makeConstraints{ make in
            make.width.height.equalTo(20)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(22)
        }
        textLabel.snp.makeConstraints{ make in
            make.width.equalTo(177)
            make.height.equalTo(Util.isIPad ? G.share.h(24) : 24)
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
        }
        collectionView.snp.makeConstraints{ make in
            make.width.equalToSuperview().multipliedBy(0.8)
            make.height.equalTo(Util.isIPad ? G.share.h(50) : 50)
            make.top.equalTo(textLabel.snp.bottom).offset(Util.isIPad ? G.share.h(36) : 36)
            make.centerX.equalToSuperview()
        }
        scrollView.snp.makeConstraints{ make in
            make.width.equalToSuperview()
            make.top.equalToSuperview().offset(Util.isIPad ? G.share.h(141) : 141)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        textField.snp.makeConstraints{ make in
            make.width.equalToSuperview().offset(-40)
            make.top.equalToSuperview().offset(Util.isIPad ? G.share.h(22) : 22)
            make.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
        hintLabel.snp.makeConstraints{ make in
            make.top.left.equalToSuperview().offset(7)
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
