//
//  CreateAccountVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift

class CreateAccountVC: UIViewController {

    @IBOutlet weak var tfFirstName: UITextField!
    @IBOutlet weak var tfLastName: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var lbHint: UILabel!
    @IBOutlet weak var viewHaveAccount: UIView!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    private var lastName = ""
    private var firstName = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.lastName = self.nav.lastName
        self.firstName = self.nav.firstName
        initView()
        subscribe()
        IQKeyboardManager.shared.toolbarDoneBarButtonItemText = "繼續"
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nav.setLoginInfo(lastname: self.lastName)
        self.nav.setLoginInfo(firstName: self.firstName)
    }
    @IBAction func didClcikBtnNext(_ sender: UIButton) {
        self.nav._delegate?.expectAccount(lastName: self.lastName, firstName: self.firstName)
    }
    func toNextPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetBirthDayVC") as? SetBirthDayVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    func clear() {
        self.tfLastName.text = ""
        self.tfFirstName.text = ""
    }
}
// MARK: - SetupUI
extension CreateAccountVC {
    private func initView() {
        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        cinfiButton()
        confiTextfield()
    }
    private func cinfiButton() {
        self.btnNext.layer.cornerRadius = LoginManager.shared.commonCornerRadius
        self.btnNext.isHidden = true
    }
    private func confiTextfield() {
        self.tfLastName.text = self.lastName
        self.tfFirstName.text = self.firstName
        self.tfLastName.delegate = self
        self.tfFirstName.delegate = self
    }
    @objc private func back() {
        LoginManager.shared.showConfirmView(self)
    }
}
// MARK: - SubscribeRX
extension CreateAccountVC {
    private func subscribe() {
        subscribe(tf: self.tfLastName)
        subscribe(tf: self.tfFirstName)
    }
    private func subscribe(tf: UITextField) {
        tf.rx.controlEvent([.editingDidBegin]).asObservable().subscribe(onNext: { (_) in
            self.btnNext.isHidden = true
            self.lbHint.isHidden = false
        }).disposed(by: self.disposeBag)

        tf.rx.controlEvent([.editingDidEnd]).asObservable().subscribe(onNext: { (_) in
            if let firstNametext = self.tfFirstName.text, let lastNametext = self.tfLastName.text, !firstNametext.isEmpty && !lastNametext.isEmpty {
                self.btnNext.isHidden = false
                self.lbHint.isHidden = true
            }
        }).disposed(by: self.disposeBag)
    }
}

extension CreateAccountVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
        case tfFirstName:
            self.firstName = textField.text ?? ""
        default:
            self.lastName = textField.text ?? ""
        }
    }
}
