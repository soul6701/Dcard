//
//  SetSexVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import MBRadioCheckboxButton
import RxCocoa
import RxSwift

class SetSexVC: UIViewController {

    @IBOutlet var viewSex: [UIView]!
    @IBOutlet var btnSex: [RadioButton]!
    @IBOutlet weak var viewHaveAccount: UIView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var height: NSLayoutConstraint!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var viewShow: UIView!
    @IBOutlet weak var viewNotShow: UIView!
    @IBOutlet weak var tfSex: UITextField!
    
    private var nav: LoginNAV {
        return self.navigationController as! LoginNAV
    }
    private var isOpening = false {
        didSet {
            self.height.constant = isOpening ? 170 : 70
            self.viewShow.isHidden = !isOpening
            self.viewNotShow.isHidden = isOpening
            if isOpening {
                self.btnNext.isHidden = self.btnSelect.title(for: .normal) == "選擇人稱代名詞"
            } else {
                self.btnNext.isHidden = false
            }
            self.view.layoutIfNeeded()
        }
    }
    private var lists = ["男性", "女性"]
    
    private var sex: String = ""
    private var sexOption: Int = 0
    private var sexName: String = ""
    private var sexNameOption: String = ""
    private var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sex = self.nav.sex
        self.sexOption = self.nav.sexOption
        self.sexName = self.nav.sexName
        self.sexNameOption = self.nav.sexNameOption
        initView()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.nav.setLoginInfo(sex: self.sexOption == 2 ? self.sexNameOption : lists[self.sexOption])
        self.nav.setLoginInfo(sexOption: self.sexOption)
        self.nav.setLoginInfo(sexName: self.sexName)
        self.nav.setLoginInfo(sexNameOption: self.sexNameOption)
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @IBAction func didClickBtnNext(_ sender: UIButton) {
        LoginManager.shared.toNextPage(self.navigationController!, next: .SetPhoneAddressVC)
    }
    @IBAction func didClickBtnSelect(_ sender: UIButton) {
        if let view = UINib(nibName: "SelectPronView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SelectPronView {
            view.setDelegate(self)
            self.view.setFixedView(view)
            view.show()
        }
    }
}
// MARK: - SetupUI
extension SetSexVC {
    private func initView() {
        self.viewShow.isHidden = true
        self.viewNotShow.isHidden = false
        self.height.constant = 70
        
        confiTextfield()
        confiButton()
        LoginManager.shared.addTapGesture(to: self.viewHaveAccount, disposeBag: self.disposeBag)
        LoginManager.shared.addSwipeGesture(to: self.view, disposeBag: self.disposeBag) {
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func confiGesture() {
        self.viewSex.filter( {return $0 != self.viewSex[3]} ).forEach { (view) in
            let ges = UITapGestureRecognizer(target: self, action: #selector(handler(_:)))
            view.addGestureRecognizer(ges)
        }
    }
    private func confiTextfield() {
        self.tfSex.delegate = self
        self.tfSex.text = self.sexNameOption
    }
    private func confiButton() {
        
        confiGesture()
        
        if let i = lists.firstIndex(of: self.sex) {
            self.sexOption = i
            self.btnSex[i].isOn = true
        } else if self.sex == "" {
            self.sexOption = 0
            self.btnSex[0].isOn = true
        } else {
            self.sexOption = 2
            self.btnSex[2].isOn = true
            self.btnSex[3].isOn = true
        }
        self.btnSex.forEach { (btn) in
            btn.isEnabled = false
        }
        self.btnSelect.setTitle(self.sexName.isEmpty ? "選擇人稱代名詞" : self.sexName, for: .normal)
    }
    @objc private func handler(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, let index = viewSex.firstIndex(of: view) else {
            return
        }
        self.btnSex.forEach { (btn) in
            btn.isOn = false
        }
        switch index {
        case ..<2:
            self.btnSex[index].isOn = true
        default:
            self.btnSex[2].isOn = true
            self.btnSex[3].isOn = true
        }
        self.sexOption = index
        self.isOpening = index == 2
    }
}
extension SetSexVC: SelectPronViewDelegate {
    func setValue(pron: String) {
        self.btnSelect.setTitle("\(pron) v", for: .normal)
        self.sexName = pron
        self.btnNext.isHidden = false
    }
}
extension SetSexVC: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.sexNameOption = textField.text ?? ""
    }
}
