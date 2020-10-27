//
//  SetPhoneAddressVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum SetPhoneAddressVCMode {
    case phone
    case address
}

class SetPhoneAddressVC: UIViewController {
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var viewHaveAccount: UIView!
    @IBOutlet weak var btnChange: UIButton!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var tfPhoneAddress: UITextField!
    @IBOutlet weak var lbHint: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var disposeBag = DisposeBag()
    private var phone = ""
    private var address = ""
    private var code = ""
    private var alias = ""
    private var mode: SetPhoneAddressVCMode = .phone {
        didSet {
            UIView.animate(withDuration: 0.3, animations: {
                self.stackView.alpha = 0
            }) { (_) in
                UIView.animate(withDuration: 0.3) {
                    self.stackView.alpha = 1
                    self.lbTitle.text = self.mode == .phone ? "你的手機號碼為何" : "你的電子郵件地址為何"
                    self.lbHint.text = self.mode == .phone ? "當你登入或需要重設密碼時，將需使用這個電話號碼。" : "當你登入或需要重設密碼時，將需使用這個電子郵件。"
                    self.btnChange.setTitle(self.mode == .phone ? "使用電子郵件地址" : "使用手機號碼", for: .normal)
                    self.tfPhoneAddress.leftView = self.mode == .phone ? self.leftview : nil
                    self.tfPhoneAddress.placeholder = self.mode == .phone ? "輸入手機號碼" : "輸入電子郵件"
                    self.tfPhoneAddress.keyboardType = self.mode == .phone ? .numberPad : .default
                    
                    if self.mode == .phone {
                        self.tfPhoneAddress.text = self.phone
                    } else {
                        self.tfPhoneAddress.text = self.address
                    }
                }
            }
        }
    }
    private var leftview: UIView!
    private let lbCountryAlias = UILabel()
    private let lbCountryCode = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.phone = self.nav.phone
        self.address = self.nav.address
        self.code = self.nav.code
        self.alias = self.nav.alias
        
        initView()
        subscribe()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.nav.setLoginInfo(phone: self.phone)
        self.nav.setLoginInfo(address: self.address)
        self.nav.setLoginInfo(alias: self.alias)
        self.nav.setLoginInfo(code: self.code)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func didClickBtnChange(_ sender: UIButton) {
        self.mode = self.mode == .phone ? .address : .phone
    }
    @IBAction func didClickBtnNext(_ sender: UIButton) {
        expect()
    }
    func toNextPage() {
        LoginManager.shared.toNextPage(.SetPasswordVC)
    }
    func clear() {
        if mode == .address {
            self.tfPhoneAddress.text = ""
            self.address = ""
        }
    }
}
// MARK: - SetupUI
extension SetPhoneAddressVC {
    private func initView() {
        confiLabel()
        confiButton()
        confiLeftViewForTfAddress()
        confiTextfield()
        
        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func confiLabel() {
        self.lbTitle.text = "你的手機號碼為何"
        self.lbHint.text = "當你登入或需要重設密碼時，將需使用這個電話號碼。"
    }
    private func confiButton() {
        self.btnNext.isHidden = self.phone.isEmpty
        
        self.btnChange.setTitle("使用電子郵件地址", for: .normal)
    }
    private func confiLeftViewForTfAddress() {
        self.leftview = UIView()
        leftview.widthAnchor.constraint(equalToConstant: self.tfPhoneAddress.bounds.width / 3).isActive = true
        
        self.lbCountryAlias.textAlignment = .center
        self.lbCountryAlias.text = self.alias
        
        let openIconView = UIView()
        let imageView = UIImageView(image: UIImage(named: ImageInfo.arrow_open))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        openIconView.addSubview(imageView)
        imageView.snp.makeConstraints { (maker) in
            maker.width.equalToSuperview().multipliedBy(0.3)
            maker.height.equalTo(imageView.snp.width)
            maker.centerY.centerX.equalToSuperview()
        }
        self.lbCountryCode.textAlignment = .center
        self.lbCountryCode.text = self.code

        let stackView = UIStackView(arrangedSubviews: [self.lbCountryAlias, openIconView, self.lbCountryCode])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        self.leftview.addSubview(stackView)
        stackView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(20)
            maker.height.equalToSuperview()
            maker.trailing.equalToSuperview().offset(-5)
            maker.centerX.equalToSuperview()
        }
        let ges = UITapGestureRecognizer(target: self, action: #selector(open))
        self.leftview.addGestureRecognizer(ges)
    }
    private func confiTextfield() {
        self.tfPhoneAddress.delegate = self
        self.tfPhoneAddress.placeholder = "輸入手機號碼"
        self.tfPhoneAddress.text = self.phone
        self.tfPhoneAddress.keyboardType = .numberPad
        self.tfPhoneAddress.leftView = self.leftview
        self.tfPhoneAddress.leftViewMode = .always
        self.tfPhoneAddress.addRightButtonOnKeyboardWithText("繼續", target: self, action: #selector(expect))
    }
    @objc private func open() {
        let vc = SelectCountryVC()
        vc.setDelegate(self)
        vc.setHideStatusBar(true)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true)
    }
    @objc private func expect() {
        let text = self.tfPhoneAddress.text ?? ""
        if mode == .phone {
            self.phone = text
        } else {
            self.address = text
        }
        guard !self.phone.isEmpty && !self.address.isEmpty else {
            LoginManager.shared.showAlertView(errorMessage: (self.phone.isEmpty ? "手機" : "信箱") + "不得為空", handler: nil)
            return
        }
        let addressPattern = "^[A-z0-9]+@[A-z0-9]+.com$"
        let phonePattern = "[0-9]"
        let phoneIsValid = self.mode == .phone ? text.match(phonePattern, options: .caseInsensitive).count == 10 : self.phone.match(phonePattern, options: .caseInsensitive).count == 10
        let addressIsValid = self.mode == .phone ? !self.address.match(addressPattern, options: .caseInsensitive).isEmpty : !text.match(addressPattern, options: .caseInsensitive).isEmpty
        guard phoneIsValid && addressIsValid else {
            if !addressIsValid {
                self.address = ""
            }
            if !phoneIsValid {
                self.phone = ""
            }
            self.tfPhoneAddress.text = ""
            hide()
            LoginManager.shared.showAlertView(errorMessage: "請填寫完整/格式錯誤", handler: nil)
            return
        }
        self.nav._delegate?.expectAccount(address: self.mode == .phone ? self.address : text)
    }
    private func hide() {
        let hideBtnNext = self.address.isEmpty || self.phone.isEmpty
        self.btnChange.isHidden = false
        self.lbHint.isHidden = !hideBtnNext
        self.btnNext.isHidden = hideBtnNext
        UIView.animate(withDuration: 0.3) {
            self.btnNext.alpha = hideBtnNext ? 0 : 1
            self.btnNext.center.y -= 30
        }
    }
}
// MARK: - SubscribeRX
extension SetPhoneAddressVC {
    private func subscribe() {
        self.tfPhoneAddress.rx.controlEvent(.editingDidBegin).asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { (_) in
            self.btnChange.isHidden = true
            self.btnNext.isHidden = true
            self.lbHint.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.btnNext.alpha = 0
            })
        }).disposed(by: self.disposeBag)
        self.tfPhoneAddress.rx.controlEvent(.editingDidEnd).asObservable().observeOn(MainScheduler.instance).subscribe(onNext: { (_) in
            let text = self.tfPhoneAddress.text ?? ""
            if self.mode == .phone {
                self.phone = text
            } else {
                self.address = text
            }
            self.hide()
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - SelectCountryVCDelegate
extension SetPhoneAddressVC: SelectCountryVCDelegate {
    func didSelectCountry(country: Country) {
        self.lbCountryAlias.text = country.alias
        self.lbCountryCode.text = country.code
        self.code = country.code
        self.alias = country.alias
    }
}
extension SetPhoneAddressVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if mode == .phone {
            guard let textFieldText = textField.text,
                let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                    return false
            }
            let substringToReplace = textFieldText[rangeOfTextToReplace]
            let count = textFieldText.count - substringToReplace.count + string.count
            return count <= 10
        } else {
            return true
        }
    }
}
