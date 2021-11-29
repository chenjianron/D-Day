//
//  SmallComponentViewController.swift
//  D-Day
//
//  Created by GC on 2021/11/11.
//

import Toolkit

class SmallComponentViewController:UIViewController {
    
    lazy var backgroundBoard:UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.masksToBounds = true
        view.backgroundColor = .white
        return view
    }()
    lazy var titleLabel:UILabel = {
        let label = UILabel()
        label.text = "Step 1"
        label.font = .boldSystemFont(ofSize: 16)
        return label
    }()
    lazy var cancelBtn:UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CloseIcon"), for: .normal)
        button.addTarget(self, action: #selector(cancelButtonDidClick(_:)), for: .touchUpInside)
        return button
    }()
    lazy var collectionView:UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: 335, height: 353)
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(ImageCollectionCell.classForCoder(), forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionCell.self))
        
        return collectionView
    }()
    lazy var pageController:UIPageControl = {
        let pageController = UIPageControl(frame: .zero)
        pageController.numberOfPages = self.imageNameList.count
        pageController.currentPage = 0
        pageController.pageIndicatorTintColor = UIColor(hex: 0xFFF1F7)
        pageController.currentPageIndicatorTintColor = K.Color.ThemeColor
        return pageController
    }()
    
    lazy var imageNameList:[String] = {
        print(Helper.getCurrentLanguage())
        var imageList = [
            "Image-1-Simplified","Image-2-Simplified","Image-3-Simplified","Image-4-Simplified"
        ] // zh-Hans-US
        if Helper.getCurrentLanguage().contains("en"){
            imageList = [
                "Image-1-English","Image-2-English","Image-3-English","Image-4-English"
            ]
        } else if Helper.getCurrentLanguage().contains("ja"){
            imageList = [
                "Image-1-Japanese","Image-2-Japanese","Image-3-Japanese","Image-4-Japanese"
            ]
        } else if Helper.getCurrentLanguage().contains("zh-Hant"){
            imageList = [
                "Image-1","Image-2","Image-3","Image-4"
            ]
        }
        return imageList
    }()
    lazy var titleList:[String] = {
        let titleList = [
            "Step 1","Step 2","Step 3","Step 4"
        ]
        return titleList
    }()
    lazy var contentList:[String] = {
        let contentList = [
                __("在主屏幕上，长按空白区域，直到App开始晃动。轻点左上角的添加按钮。"),__("滚动或搜索来找到「恋爱记录」小组件，轻点小组件，然后向左轻扫查看大小选项。"),__("选择一个小组件，从三种小组件尺寸中进行选取，然后轻点“添加小组件”"),__("长按小组件，选择「编辑小组件」，即可选择想要显示的纪念日，背景可到相应纪念日修改。")
            ]
        return contentList
    }()

//    lazy var promptLable:UILabel = {
//        let label = UILabel()
//        label.font = .systemFont(ofSize: 14)
//        label.textColor = K.Color.AuxiliaryColor
//        return label
//    }()

    
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

// MARK: - CollectionView
extension SmallComponentViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        if imageNameList.count == 0 {
            return 0
        }
        return imageNameList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionCell.self), for: indexPath) as! ImageCollectionCell
//        if (indexPath.row == 0){
//            cell.imageView.image = UIImage(named: imageNameList.last!)
//        } else if (indexPath.row == self.imageNameList.count + 1){
//            cell.imageView.image = UIImage(named: imageNameList.first!)
//        } else {
//            cell.imageView.image = UIImage(named: imageNameList[indexPath.row - 1])
//        }
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(ImageCollectionCell.self), for: indexPath) as! ImageCollectionCell
        cell.imageView.image = UIImage(named: imageNameList[indexPath.row])
        cell.titleLable.text = contentList[indexPath.row]
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if scrollView.contentOffset.x == 0 {
//            scrollView.contentOffset = CGPoint(x: CGFloat(self.imageNameList.count) * 335, y: 0)
//            self.pageController.currentPage = self.imageNameList.count
//        } else if (scrollView.contentOffset.x == CGFloat(self.imageNameList.count + 1) * 335) {
//            scrollView.contentOffset = CGPoint(x: 335, y: 0)
//            self.pageController.currentPage = 0
//        } else {
//            self.pageController.currentPage = Int(scrollView.contentOffset.x / 335) - 1
//        }
        let index = Int(scrollView.contentOffset.x / 335)
        self.pageController.currentPage = index
        titleLabel.text = titleList[index]
    }
    
}

// MARK: - Interaction
extension SmallComponentViewController {
    
    @objc func cancelButtonDidClick(_ sender:UIButton){
        self.dismiss(animated: false, completion: nil)
    }
    
}



// MARK: - UI
extension SmallComponentViewController {
    
    func setUpUI(){
        view.addSubview(backgroundBoard)
        backgroundBoard.addSubview(titleLabel)
        backgroundBoard.addSubview(cancelBtn)
        backgroundBoard.addSubview(collectionView)
        backgroundBoard.addSubview(pageController)
        collectionView.reloadData()
        collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .left, animated: false)
    }
    
    func setUpConstraints(){
        backgroundBoard.snp.makeConstraints{ make in
            
            make.width.equalTo(375)
            make.height.equalTo(483)
            
            if Util.isIPad {
                make.center.equalToSuperview()
            } else {
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview()
            }
            
        }
        titleLabel.snp.makeConstraints{ make in
            make.top.equalToSuperview().offset(19)
            make.left.equalToSuperview().offset(20)
        }
        cancelBtn.snp.makeConstraints{ make in
            make.height.width.equalTo(20)
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }
        collectionView.snp.makeConstraints{ make in
            make.width.equalTo(335)
            make.height.equalTo(353)
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(57)
        }
        pageController.snp.makeConstraints{ make in
            make.width.equalTo(188)
            make.height.equalTo(10)
            make.top.equalTo(collectionView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
    }
    
    func showAnimate() {
        DispatchQueue.main.asyncAfter(deadline: .now()+0.1){
            UIView.animate(withDuration: 0.3) {
                self.view.backgroundColor = UIColor.init(hex: 0x000000, alpha: 0.4)
            }
        }
    }
}
