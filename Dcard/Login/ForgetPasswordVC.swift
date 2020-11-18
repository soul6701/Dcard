//
//  ForgetPasswordVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/31.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import DropDown
import RxCocoa
import RxSwift

class ForgetPasswordVC: UIViewController {

    @IBOutlet weak var tfPhoneAddress: UITextField!
    @IBOutlet weak var tfAccount: UITextField!
    @IBOutlet weak var btnSend: UIButton!
    
    private lazy var accountList: DropDown = {
        let view = DropDown()
        view.anchorView = self.tfAccount
        view.dataSource = UserDefaultsKeys.account.keys.map({ (string) -> String in
            return string
        })
        view.selectionAction = { (index, string) in
            self.tfAccount.text = string
        }
        return view
    }()
    private var delegate: LoginVCDelegate?
    private var disposebag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        subscribe()
    }
    @IBAction func didClickSend(_ sender: UIButton) {
        guard let account = self.tfAccount.text, let phoneAddress = self.tfPhoneAddress.text, !account.isEmpty && !phoneAddress.isEmpty else {
            AlertManager.shared.showAlertView(errorMessage: "欄位不得為空", handler: nil)
            return
        }
        let isPhone = phoneAddress.contains("@")
        self.delegate?.requirePassword(uid: self.tfAccount.text!, phone: isPhone ? nil : phoneAddress, address: isPhone ? phoneAddress : nil)
    }
    func setDelegate(delegate: LoginVCDelegate) {
        self.delegate = delegate
    }
}
// MARK: - SetupUI
extension ForgetPasswordVC {
    private func initView() {
        self.tfAccount.tintColor = .clear
        self.tfAccount.inputView = UIView(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    }
}
// MARK: - SubscribeRX
extension ForgetPasswordVC {
    private func subscribe() {
        self.tfAccount.rx.controlEvent([.editingDidBegin]).subscribe(onNext: { (_) in
            if !self.accountList.dataSource.isEmpty {
                self.accountList.show()
            } else {
                AlertManager.shared.showAlertView(errorMessage: "近期無任何登入紀錄", handler: nil)
            }
            
        }).disposed(by: self.disposebag)
    }
}

