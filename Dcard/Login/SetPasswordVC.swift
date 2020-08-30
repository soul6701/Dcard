//
//  SetPassword.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class SetPasswordVC: UIViewController {

    @IBOutlet weak var lbHint: UILabel!
    @IBOutlet weak var tfPassword: UITextField!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var viewHaveAccount: UIView!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    private var password = ""
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        subscribe()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nav.setLoginInfo(password: self.password)
    }
    @IBAction func didClickBtnNext(_ sender: UIButton) {
        toNextPage()
    }
}
// MARK: - SetupUI
extension SetPasswordVC {
    private func initView() {
        self.password = self.nav.password
        self.btnNext.isHidden = self.password.isEmpty
        self.btnNext.layer.cornerRadius = LoginManager.shared.commonCornerRadius
        
        self.tfPassword.text = self.password
        self.tfPassword.delegate = self
        
        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    @objc private func toNextPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "CompleteRegisterVC") as? CompleteRegisterVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - SubscribeRX
extension SetPasswordVC {
    private func subscribe() {
        self.tfPassword.rx.controlEvent(.editingDidBegin).asObservable().subscribe(onNext: { (_) in
            self.lbHint.isHidden = false
            self.lbHint.isHidden = false
            self.btnNext.isHidden = true
            UIView.animate(withDuration: 0.3, animations: {
                self.btnNext.alpha = 0
            })
        }).disposed(by: self.disposeBag)
        self.tfPassword.rx.controlEvent(.editingDidEnd).asObservable().subscribe(onNext: { (_) in
            let text = self.tfPassword.text ?? ""
            self.lbHint.isHidden = !text.isEmpty
            self.btnNext.isHidden = text.isEmpty
            UIView.animate(withDuration: 0.3) {
                self.btnNext.alpha = text.isEmpty ? 0 : 1
                self.btnNext.center.y -= 30
            }
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - UITextFieldDelegate
extension SetPasswordVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.password = textField.text ?? ""
    }
}
