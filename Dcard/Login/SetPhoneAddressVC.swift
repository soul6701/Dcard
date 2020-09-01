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
    @IBOutlet weak var tfPhone: UITextField!
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
                if let text = self.tfPhone.text {
                    if self.mode == .phone {
                        self.address = text
                    } else {
                        self.phone = text
                    }
                }
            }) { (_) in
                UIView.animate(withDuration: 0.3) {
                    self.stackView.alpha = 1
                    self.lbTitle.text = self.mode == .phone ? "你的手機號碼為何" : "你的電子郵件地址為何"
                    self.lbHint.text = self.mode == .phone ? "當你登入或需要重設密碼時，將需使用這個電話號碼。" : "當你登入或需要重設密碼時，將需使用這個電子郵件。"
                    self.btnChange.setTitle(self.mode == .phone ? "使用電子郵件地址" : "使用手機號碼", for: .normal)
                    self.tfPhone.leftView = self.mode == .phone ? self.leftview : nil
                    self.tfPhone.placeholder = self.mode == .phone ? "輸入手機號碼" : "輸入電子郵件"
                    self.tfPhone.keyboardType = self.mode == .phone ? .numberPad : .default
                    
                    if self.phone == "" && self.mode == .phone {
                        self.tfPhone.text = self.phone
                    } else if self.address == "" && self.mode == .address {
                        self.tfPhone.text = self.address
                    } else {
                        self.tfPhone.text = self.mode == .phone ? self.phone : self.address
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
    @IBAction func didClickBtnChange(_ sender: UIButton) {
        self.mode = self.mode == .phone ? .address : .phone
    }
    @IBAction func didClickBtnNext(_ sender: UIButton) {
        toNextPage()
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
        self.btnNext.layer.cornerRadius = LoginManager.shared.commonCornerRadius
        
        self.btnChange.setTitle("使用電子郵件地址", for: .normal)
        self.btnChange.layer.borderColor = LoginManager.shared.commonBorderColor
        self.btnChange.layer.borderWidth = LoginManager.shared.commonBorderWidth
        self.btnChange.layer.cornerRadius = LoginManager.shared.commonCornerRadius
    }
    private func confiLeftViewForTfAddress() {
        self.leftview = UIView()
        leftview.widthAnchor.constraint(equalToConstant: self.tfPhone.bounds.width / 3).isActive = true
        
        self.lbCountryAlias.textAlignment = .center
        self.lbCountryAlias.text = self.alias
        
        leftview.addSubview(self.lbCountryAlias)
        self.lbCountryAlias.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.lbCountryAlias.adjustsFontSizeToFitWidth = true
        
        let _view = UIView()
        let imageView = UIImageView(image: UIImage(named: ImageInfo.arrow_open))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        _view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalTo: _view.widthAnchor, multiplier: 0.3).isActive = true
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: 1).isActive = true
        imageView.centerYAnchor.constraint(equalTo: _view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: _view.centerXAnchor).isActive = true
        
        
        self.lbCountryCode.textAlignment = .center
        self.lbCountryCode.text = self.code

        let stackView = UIStackView(arrangedSubviews: [self.lbCountryAlias, _view, self.lbCountryCode])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        self.leftview.addSubview(stackView)
        
        stackView.leadingAnchor.constraint(equalTo: self.leftview.leadingAnchor, constant: 20).isActive = true
        stackView.heightAnchor.constraint(equalTo: self.leftview.heightAnchor).isActive = true
        stackView.trailingAnchor.constraint(equalTo: self.leftview.trailingAnchor, constant: -5).isActive = true
        stackView.centerYAnchor.constraint(equalTo: self.leftview.centerYAnchor).isActive = true
        let ges = UITapGestureRecognizer(target: self, action: #selector(open))
        self.leftview.addGestureRecognizer(ges)
    }
    private func confiTextfield() {
        self.tfPhone.placeholder = "輸入手機號碼"
        self.tfPhone.text = self.phone
        self.tfPhone.keyboardType = .numberPad
        self.tfPhone.leftView = self.leftview
        self.tfPhone.leftViewMode = .always
        self.tfPhone.addRightButtonOnKeyboardWithText("繼續", target: self, action: #selector(toNextPage))
    }
    @objc private func open() {
        let vc = SelectCountryVC()
        vc.setDelegate(delegate: self)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true)
    }
    @objc private func toNextPage() {
        if let vc = self.storyboard?.instantiateViewController(withIdentifier: "SetPasswordVC") as? SetPasswordVC {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
// MARK: - SubscribeRX
extension SetPhoneAddressVC {
    private func subscribe() {
        self.tfPhone.rx.controlEvent(.editingDidBegin).asObservable().subscribe(onNext: { (_) in
            self.btnChange.isHidden = true
            self.btnNext.isHidden = true
            self.lbHint.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.btnNext.alpha = 0
            })
        }).disposed(by: self.disposeBag)
        self.tfPhone.rx.controlEvent(.editingDidEnd).asObservable().subscribe(onNext: { (_) in
            let text = self.tfPhone.text ?? ""
            self.btnChange.isHidden = false
            self.lbHint.isHidden = !text.isEmpty
            self.btnNext.isHidden = text.isEmpty
            UIView.animate(withDuration: 0.3) {
                self.btnNext.alpha = text.isEmpty ? 0 : 1
                self.btnNext.center.y -= 30
            }
            if self.mode == .phone {
                self.phone = text
            } else {
                self.address = text
            }
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
