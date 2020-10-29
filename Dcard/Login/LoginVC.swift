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
    func expectAccount(address: String)
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
    private var viewModel: LoginVMInterface!
    
    private var window: UIWindow {
        return UIApplication.shared.windows.first!
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subsribeViewModel()
        self.viewModel.login(address: "a@a.com", password: "a12345")
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverToKeyboard()
        ToolbarView.shared.show(false)
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
        expect()
    }
    @IBAction func didClcickBtnCreateNewAccount(_ sender: UIButton) {
        if let vc = self.storyboard?.instantiateViewController(identifier: "CreateAccountVC") as? CreateAccountVC {
            nav = LoginNAV(rootViewController: vc)
            nav.setDelegate(delegate: self)
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
    }
}
// MARK: - Private Fun
extension LoginVC {
    private func expect() {
        if let password = self.tfPassword.text, let account = self.tfAccount.text, !password.isEmpty && !account.isEmpty {
            guard !(account.match("^[A-z0-9]+@[A-z0-9]+.com$", options: .caseInsensitive).isEmpty) else {
                LoginManager.shared.showAlertView(errorMessage: "格式錯誤", handler: nil)
                [self.tfAccount, self.tfPassword].forEach { (tf) in
                    tf.text = ""
                }
                return
            }
            self.viewModel.login(address: account, password: password)
        } else {
            LoginManager.shared.showAlertView(errorMessage: "欄位不得為空", handler: nil)
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
        
        self.viewModel.loginSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            switch result {
            case .success:
                LoginManager.shared.showOKView(mode: .login) {
                    if let vc = UIStoryboard(name: "Home", bundle: nil).instantiateInitialViewController() as? HomeVC {
                        self.navigationController?.pushViewController(vc, animated: true)
                        UserDefaultsKeys.shared.setValue([self.tfAccount.text!: Date()], forKey: Login_account)
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
            let vc = self.nav.viewControllers.first(where: { return $0 is SetPhoneAddressVC }) as! SetPhoneAddressVC
            if result {
                vc.toNextPage()
            } else {
                LoginManager.shared.showAlertView(errorMessage: "信箱已被使用，請重新輸入", handler: nil)
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
        expect()
        return true
    }
}
extension LoginVC: LoginVCDelegate {
    func expectAccount(address: String) {
        self.viewModel.expectAccount(address: address)
    }
    func creartUserData(lastName: String, firstName: String, birthday: String, sex: String, phone: String, address: String, password: String, avatar: Data?) {
        self.viewModel.creartUserData(lastName: lastName, firstName: firstName, birthday: birthday, sex: sex, phone: phone, address: address, password: password, avatar: avatar)
    }
    func requirePassword(uid: String, phone: String?, address: String?) {
        self.viewModel.requirePassword(uid: uid, phone: phone, address: address)
    }
}
