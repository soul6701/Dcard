//
//  LoginVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/23.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import IQKeyboardManagerSwift
import Firebase
import SwiftMessages

class LoginVC: UIViewController {

    @IBOutlet weak var stackViewforTf: UIStackView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var heightImage: NSLayoutConstraint!
    @IBOutlet weak var btnSignIn: UIButton!
    @IBOutlet weak var btnCreateNewAccount: UIButton!
    @IBOutlet weak var viewForTf: UIView!
    @IBOutlet weak var tfAccount: UITextField!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet var viewWidth: [NSLayoutConstraint]!
    
    private var _centerLine: UIView?
    private var centerLine: UIView!
    private var oldHeight: CGFloat!
    private var newHeight: CGFloat!
    private var disposeBag = DisposeBag()
    var viewModel: LoginVMInterface!
    
    private var window: UIWindow {
        return UIApplication.shared.windows.first!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subsribeViewModel()
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverToKeyboard()
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
        UserDefaultsKeys.removeKeysByString(prefix: "Login")
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removerObserverFromKeyboard()
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    @IBAction func didClickBtnSignIn(_ sender: UIButton) {
        var lastName: String
        var firstName: String
        guard let account = self.tfAccount.text else {
            return
        }
        let regex = try! NSRegularExpression(pattern: "^[A-z0-9]+_[A-z0-9]+$", options: .caseInsensitive)
        guard !(regex.matches(in: account, options: [], range: NSRange(location: 0, length: account.count)).isEmpty), let password = self.tfPassword.text, !account.isEmpty && !password.isEmpty else {
            LoginManager.shared.showAlertView(errorMessage: "請填寫完整/格式錯誤", handler: nil)
            reset(tf: [self.tfAccount, self.tfPassword])
            return
        }
        lastName = String(account.split(separator: "_")[0])
        firstName = String(account.split(separator: "_")[1])
        
        self.viewModel.login(lastName: lastName, firstName: firstName, password: password)
    }
    @IBAction func didClcickBtnCreateNewAccount(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "CreateAccountVC") as? CreateAccountVC {
            vc.lastVC = self
            let nav = LoginNAV(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.setNavigationBarHidden(true, animated: false)
            self.present(nav, animated: true)
        }
    }
}
// MARK: - SetupUI
extension LoginVC {
    private func initView() {
        drawView()
        confiButton()
        self.viewWidth.forEach { (height) in
            height.constant = LoginManager.shared.commonBorderWidth
        }
        self.newHeight = self.heightImage.constant - 100
        self.oldHeight = self.heightImage.constant
    }
    private func drawView() {
        self.tfAccount.borderStyle = .none
        self.tfPassword.borderStyle = .none
        
        self.centerLine = UIView(frame: CGRect(x: 0, y: Int(self.viewForTf.bounds.height / 2 - 0.5), width: Int(self.viewForTf.bounds.width), height: 1))
        self.centerLine!.backgroundColor = .lightGray
        self.viewForTf.addSubview(self.centerLine!)
        self.viewForTf.layer.borderColor = LoginManager.shared.commonBorderColor
        self.viewForTf.layer.borderWidth = LoginManager.shared.commonBorderWidth
        self.viewForTf.layer.cornerRadius = LoginManager.shared.commonCornerRadius
    }
    private func confiButton() {
        self.btnSignIn.layer.cornerRadius = LoginManager.shared.commonCornerRadius
        self.btnCreateNewAccount.layer.cornerRadius = LoginManager.shared.commonCornerRadius
    }
}
// MARK: - Handler
extension LoginVC {
    private func reset(tf: [UITextField]) {
        tf.forEach { (tf) in
            tf.text = ""
        }
    }
}
// MARK: - ConfigureViewModel
extension LoginVC {
    private func confiViewModel() {
        self.viewModel = LoginVM()
    }
    private func subsribeViewModel() {
        self.viewModel.creartUserDataSubject
            .observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
                if result {
                    LoginManager.shared.showOKView(mode: .create) {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }, onError: { (error) in
                LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
            }).disposed(by: self.disposeBag)
        
//        self.viewModel.readFromUserDataSubject.subscribe(onNext: { (user) in
//            if let user = user {
//                self.tfAccount.text = "\(user.lastName)_\(user.firstName)"
//                self.tfPassword.text = user.password
//            } else {
//                LoginManager.shared.showAlertView(errorMessage: "", handler: nil)
//            }
//        }, onError: { (error) in
//            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
//        }).disposed(by: self.disposeBag)
        self.viewModel.loginSubject.subscribe(onNext: { (result) in
            switch result {
            case .success:
                LoginManager.shared.showOKView(mode: .login) {
                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as? HomeVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                    }
                }
            case .error(let error):
                LoginManager.shared.showAlertView(errorMessage: error.rawValue, handler: nil)
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - Keyboard
extension LoginVC {
    private func addObserverToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removerObserverFromKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func showKeyboard(_ noti: NSNotification) {
        self.heightImage.constant = self.newHeight
        self.bottomSpace.constant = -100
        self.imageTitle.image = UIImage(named: ImageInfo._login)
        self.view.layoutIfNeeded()
    }
    @objc private func hideKeyboard(_ noti: NSNotification) {
        self.heightImage.constant = self.oldHeight
        self.bottomSpace.constant = 0
        self.imageTitle.image = UIImage(named: ImageInfo.login)
        self.view.layoutIfNeeded()
    }
}
