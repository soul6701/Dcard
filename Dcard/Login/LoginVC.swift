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

protocol LoginVCDelegate {
    func expectAccount(lastName: String, firstName: String)
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?)
    func requirePassword(uid: String, phone: String?, address: String?)
}
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
    
    
    private var nav: LoginNAV!
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
//        confiViewModel()
//        subsribeViewModel()
        if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as? HomeVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverToKeyboard()
        ToolbarView.shared.show(false)
        LoadingView.reset()
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "完成"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
        removerObserverFromKeyboard()
    }
    @IBAction func didClickForgetPassword(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "ForgetPasswordVC") as? ForgetPasswordVC {
            vc.setDelegate(delegate: self)
            present(vc, animated: true)
        }
    }
    @IBAction func didClickBtnSignIn(_ sender: UIButton) {
        let (_result, lastName, firstName, password) = self.expect()
        if _result {
            self.viewModel.login(lastName: lastName, firstName: firstName, password: password)
        }
    }
    @IBAction func didClcickBtnCreateNewAccount(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "CreateAccountVC") as? CreateAccountVC {
            nav = LoginNAV(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            nav.setDelegate(delegate: self)
            nav.setNavigationBarHidden(true, animated: false)
            self.present(nav, animated: true)
        }
    }
    @IBAction func didClickClear(_ sender: UIButton) {
        self.viewModel.deleteUserData()
        UserDefaultsKeys.shared.removeKeysByString(prefix: "Login")
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
        
        self.tfPassword.delegate = self
        self.tfAccount.delegate = self
    }
    private func drawView() {
        self.tfAccount.borderStyle = .none
        self.tfPassword.borderStyle = .none
        
        self.centerLine = UIView(frame: CGRect(x: 0, y: Int(self.viewForTf.bounds.height / 2 - 0.5), width: Int(self.view.bounds.width - 40), height: 1))
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
    private func expect() -> (Bool, String, String, String) {
        var lastName: String
        var firstName: String
        guard let account = self.tfAccount.text else {
            return (false, "", "", "")
        }
        let regex = try! NSRegularExpression(pattern: "^[A-z0-9]+_[A-z0-9]+$", options: .caseInsensitive)
        guard !(regex.matches(in: account, options: [], range: NSRange(location: 0, length: account.count)).isEmpty), let password = self.tfPassword.text, !account.isEmpty && !password.isEmpty else {
            LoginManager.shared.showAlertView(errorMessage: "請填寫完整/格式錯誤", handler: nil)
            reset(tf: [self.tfAccount, self.tfPassword])
            return (false, "", "", "")
        }
        lastName = String(account.split(separator: "_")[0])
        firstName = String(account.split(separator: "_")[1])
        
        return (true, lastName, firstName, password)
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
        
        self.viewModel.loginSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            switch result {
            case .success:
                LoginManager.shared.showOKView(mode: .login) {
                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as? HomeVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                        UserDefaultsKeys.shared.setValue([self.tfAccount.text!: Date()], forKey: Login_account)
                        print("🐶🐶🐶🐶🐶\(UserDefaultsKeys.account)🐶🐶🐶🐶🐶")
                    }
                }
            case .error(let error):
                LoginManager.shared.showAlertView(errorMessage: error.rawValue, handler: nil)
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.deleteUserDataSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            switch result {
            case .success:
                LoginManager.shared.showOKView(mode: .delete, handler: nil)
            case .error(let error):
                LoginManager.shared.showAlertView(errorMessage: error, handler: nil)
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.expectAccountSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            guard let vc = self.nav.viewControllers.first(where: { (vc) -> Bool in
                return vc.isKind(of: CreateAccountVC.self)
            }) as? CreateAccountVC else {
                return
            }
            if result {
                vc.toNextPage()
            } else {
                LoginManager.shared.showAlertView(errorMessage: "姓氏/名字已被使用，請重新輸入", handler: nil)
                vc.clear()
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.requirePasswordSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            switch result {
                case .success(let password):
                    LoginManager.shared.showOKView(mode: .required) {
                        self.dismiss(animated: true, completion: nil)
                    }
                    self.tfPassword.text = password
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
// MARK: - UITextFieldDelegate
extension LoginVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let password = self.tfPassword.text, let account = self.tfAccount.text, !password.isEmpty && !account.isEmpty {
            let (_result, lastName, firstName, password) = self.expect()
            if _result {
                self.viewModel.login(lastName: lastName, firstName: firstName, password: password)
            }
        }
        return true
    }
}
extension LoginVC: LoginVCDelegate {
    func expectAccount(lastName: String, firstName: String) {
        self.viewModel.expectAccount(lastName: lastName, firstName: firstName)
    }
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) {
        self.viewModel.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatar: avatar)
    }
    func requirePassword(uid: String, phone: String?, address: String?) {
        self.viewModel.requirePassword(uid: uid, phone: phone, address: address)
    }
}
