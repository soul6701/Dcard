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

    @IBOutlet weak var btnConfirm: UIButton!
    @IBOutlet weak var viewHaveAccount: UIView!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    
    }
    @IBAction func didClickBtnConfirm(_ sender: UIButton) {
        if let nav = self.navigationController, let vc = nav.viewControllers.first as? CreateAccountVC {
            vc.lastVC?.viewModel.creartUserData(lastName: self.nav.lastName, firstName: self.nav.firstName, birthday: self.nav.birthday, sex: self.nav.sex, phone: self.nav.phone, address: self.nav.address, password: self.nav.password)
        }
    }
}
// MARK: - SetupUI
extension CompleteRegisterVC {
    private func initView() {
        self.btnConfirm.layer.cornerRadius = LoginManager.shared.commonCornerRadius

        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
