//
//  CompleteRegisterVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import SwiftMessages

class CompleteRegisterVC: UIViewController {

    @IBOutlet weak var imageAvatar: UIImageView!
    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var viewHaveAccount: UIView!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    private var avatar: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
//        self.nav.setLoginInfo(avatar: self.avatar)
    }
    @IBAction func didClickBtnConfirm(_ sender: UIButton) {
        self.nav._delegate?.creartUserData(lastName: self.nav.lastName, firstName: self.nav.firstName, birthday: self.nav.birthday, sex: self.nav.sex, phone: "\(self.nav.code)-\(self.nav.phone)", address: self.nav.address, password: self.nav.password, avatar: self.avatar?.pngData())
    }
    @IBAction func didClickSelectAvatar(_ sender: UIButton) {
        let controller = UIImagePickerController()
        controller.sourceType = .photoLibrary
        controller.delegate = self
        present(controller, animated: true)
    }
}
// MARK: - SetupUI
extension CompleteRegisterVC {
    private func initView() {
        confiImageView()
        self.avatar = self.nav.avatar
        if let avatar = self.avatar {
            self.imageAvatar.image = avatar
        } else {
            self.imageAvatar.image = UIImage(named: ImageInfo.profile)!
        }
        
        self.btnConfirm.layer.cornerRadius = LoginManager.shared.commonCornerRadius

        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func confiImageView() {
        self.imageAvatar.image = UIImage(named: ImageInfo.profile)!
        self.imageAvatar.contentMode = .scaleAspectFill
        self.imageAvatar.layer.borderColor = UIColor.blue.cgColor
        self.imageAvatar.layer.cornerRadius = 96 / 2
        self.imageAvatar.layer.borderWidth = 2
    }
}
extension CompleteRegisterVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            self.imageAvatar.image = image
            self.avatar = image
            
        }
        dismiss(animated: true, completion: nil)
    }
}
