//
//  DDayHeadView.swift
//  D-Day
//
//  Created by GC on 2021/10/13.
//

import UIKit
import Toolkit
import TZImagePickerController

class DDayHeadView: UIView {
    
    enum Head:Int {
        case Man = 138
        case Woman = 168
    }
    
    lazy var selectHeadTag:Head? = nil
    lazy var manHeadView:HeadView = {
        let headView = HeadView()
        headView.layer.borderWidth = 3
        headView.layer.borderColor = UIColor(hex: 0xFFD5EA).cgColor
        headView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headViewDidTap(_:))))
        headView.layer.masksToBounds = true
        headView.tag = Head.Man.rawValue
        return headView
    }()
    lazy var connectImageView:UIImageView = {
       let imageView = UIImageView(image: #imageLiteral(resourceName: "Index-Connect-Icon"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    lazy var womenHeadView:HeadView = {
        let headView = HeadView()
        headView.layer.borderWidth = 3
        headView.layer.borderColor = UIColor(hex: 0xFFD5EA).cgColor
        headView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(headViewDidTap(_:))))
        headView.layer.masksToBounds = true
        headView.tag = Head.Woman.rawValue
        return headView
    }()
    
    override init(frame: CGRect){
        super.init(frame:frame)
        setUpUI()
        setUpConstraints()
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        loadData()
    }
    
    override func layoutSubviews(){
        super.layoutSubviews()
        manHeadView.layer.cornerRadius = manHeadView.width * 0.5
        womenHeadView.layer.cornerRadius = womenHeadView.width * 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - Interaction
extension DDayHeadView {
    @objc func headViewDidTap(_ sender:UITapGestureRecognizer) {
//        Helper.accessPhoto {
//            self.selectHeadTag = Head(rawValue: sender.view!.tag)
//            let imagePicker = UIImagePickerController()
//            imagePicker.delegate = self
//            imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
//            imagePicker.isToolbarHidden = false
//            Util.topViewController().present(imagePicker, animated: true, completion: nil)
//        }
        Helper.accessPhoto {
            self.selectHeadTag = Head(rawValue: sender.view!.tag)
            let viewController = TZImagePickerController(maxImagesCount: 8,
                                                         columnNumber: 3,
                                                         delegate: self,
                                                         pushPhotoPickerVc: true)!
            viewController.maxImagesCount = 1
            viewController.allowTakePicture = false
            viewController.allowPickingVideo = false
            viewController.isSelectOriginalPhoto = true
            viewController.allowPreview = true
            viewController.alwaysEnableDoneBtn = true
            viewController.allowCrop = true
            viewController.circleCropRadius = Int(G.share.w(180))
            viewController.needCircleCrop = true
            viewController.scaleAspectFillCrop = true
            viewController.showSelectBtn = false
            viewController.oKButtonTitleColorNormal = K.Color.ThemeColor
            viewController.navigationBar.isTranslucent = true
            viewController.iconThemeColor = K.Color.ThemeColor
            viewController.modalPresentationStyle = .fullScreen
            Util.topViewController().present(viewController, animated: true, completion: nil)
        }
    }
}

// MARK: TZImagePickerController
extension DDayHeadView: TZImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: TZImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool) {
        picker.view.isUserInteractionEnabled = false
//        let block = {
//            picker.dismiss(animated: true, completion: {
//                guard let selectHeadTag = self.selectHeadTag else { return }
//                var headView:HeadView
//
//                if selectHeadTag == .Man {
//                    headView = self.manHeadView
//                    HeadInfoManager.default.manHead = photos[0]
//                } else {
//                    headView = self.womenHeadView
//                    HeadInfoManager.default.womenHead = photos[0]
//                }
//
//                headView.headView.image = photos[0]
//            })
//        }
        var headView:HeadView
        
        if selectHeadTag == .Man {
            headView = self.manHeadView
            HeadInfoManager.default.manHead = photos[0]
        } else {
            headView = self.womenHeadView
            HeadInfoManager.default.womenHead = photos[0]
        }
        
        headView.headView.image = photos[0]
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: block)
    }
}


// MARK: UIImagePickerController
//extension DDayHeadView:UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//
//        picker.view.isUserInteractionEnabled = false
//        let block = {
//            picker.dismiss(animated: true, completion: {
//                guard let selectHeadTag = self.selectHeadTag else { return }
//
//                var headView:HeadView
//                var image:UIImage
//
//                image = info[UIImagePickerController.InfoKey(rawValue: UIImagePickerController.InfoKey.originalImage.rawValue)] as! UIImage
//                if selectHeadTag == .Man {
//                    headView = self.manHeadView
//                    HeadInfoManager.default.manHead = image
//                } else {
//                    headView = self.womenHeadView
//                    HeadInfoManager.default.womenHead = image
//                }
//                headView.headView.image = image
//            })
//        }
//
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: block)
//    }
//}

// MARK: - Private
extension DDayHeadView {
    fileprivate func loadData(){
        let manHead = HeadInfoManager.default.manHead
        manHeadView.headView.image = manHead ?? #imageLiteral(resourceName: "Index-ManHead-Default")
        let womenHead = HeadInfoManager.default.womenHead
        womenHeadView.headView.image = womenHead ?? #imageLiteral(resourceName: "Index-WomenHead-Default")
    }
}

// MARK: - UI
extension DDayHeadView {
    
    func setUpUI(){
        addSubview(manHeadView)
        addSubview(connectImageView)
        addSubview(womenHeadView)
    }
    
    func setUpConstraints(){
        
        connectImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(29)
            make.height.equalTo(10)
        }
        manHeadView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(connectImageView.snp.left).offset(-11)
            make.width.equalTo(Util.isIPad ? 75 : 55)
            make.height.equalTo(Util.isIPad ? 75 : 55)
        }
        womenHeadView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(connectImageView.snp.right).offset(11)
            make.width.equalTo(Util.isIPad ? 75 : 55)
            make.height.equalTo(Util.isIPad ? 75 : 55)
        }
    }
}
