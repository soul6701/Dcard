//
//  SettingAccountVC.swift
//  Dcard
//
//  Created by admin on 2020/10/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

enum SettingAccountType {
    case setAddress
    case resetPassword
    case resetAddress
    
    var rowList: [[String]] {
        switch self {
        case .setAddress:
            return [[""], [""]]
        case .resetPassword:
            return [["原有密碼"], ["新密碼", "確認新密碼"], ["儲存"]]
        case .resetAddress:
            return [["目前信箱"], ["新信箱", "確認信箱"], ["輸入密碼"], ["儲存"]]
        }
    }
    var sectionList: [String?] {
        switch self {
        case .setAddress:
            return ["目前常用信箱", nil]
        case .resetPassword:
            return ["原有密碼", "新密碼", nil]
        case .resetAddress:
            return ["目前常用信箱", "新常用信箱", "輸入密碼確認身份", nil]
        }
    }
}
class SettingAccountVC: UIViewController {
    private var type: SettingAccountType = .setAddress
    private var oldAddress = ""
    private var newAddress = ""
    private var oldPassword = ""
    private var newPassword = ""
    private var navigationItemTitle = ""
    private var sectionList = [String?]()
    private var rowList = [[String]]()
    private var hintString = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    private let disposeBag = DisposeBag()
    lazy private var btnSave: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(save))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()
    lazy private var tfEmailList: [UITextField] = {
        let placeholderRowOne = self.type == .resetAddress ? "請輸入欲修改的信箱" : "請輸入新密碼"
        let placeholderRowTwo = self.type == .resetAddress ? "再次輸入新信箱" : "再次輸入新密碼"
        let width = self.type == .resetAddress ? 200 : 150
        var list = [UITextField]()
        (0...1).forEach { (i) in
            let textField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
            textField.placeholder = i == 0 ? placeholderRowOne : placeholderRowTwo
            textField.clearButtonMode = .whileEditing
            textField.isSecureTextEntry = self.type == .resetPassword
            list.append(textField)
        }
        return list
    }()
    lazy private var tfPassword: UITextField = {
        let placeholder = self.type == .resetAddress ? "請輸入密碼" : "請輸入目前密碼"
        let width = self.type == .resetAddress ? 200 : 150
        let textField = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        textField.placeholder = placeholder
        textField.isSecureTextEntry = true
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    private var viewModel: LoginVMInterface!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subsribeViewModel()
        subscribe()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let user = ModelSingleton.shared.userConfig.user
        self.oldAddress = user.address
        self.oldPassword = user.password
        self.tableView.reloadData()
    }
    func setContent(type: SettingAccountType, title: String) {
        self.type = type
        self.navigationItemTitle = title
    }
}
// MARK: - SetupUI
extension SettingAccountVC {
    private func initView() {
        self.sectionList = type.sectionList
        self.rowList = type.rowList
        
        confiTableView()
        confiNav()
    }
    private func confiTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "RightDetailCell")
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        self.tableView.showsVerticalScrollIndicator = false
    }
    private func confiNav() {
        self.navigationItem.title = self.navigationItemTitle
        if self.type != .setAddress {
            self.navigationItem.rightBarButtonItem = self.btnSave
        }
    }
}
// MARK: - Private Func
extension SettingAccountVC {
    @objc private func save() {
        var valid = false
        self.hintString = ""
        if self.type == .resetAddress {
            self.newAddress = self.tfEmailList[0].text ?? ""
            valid = expectEmailFormat(self.newAddress)
        }
        if self.type == .resetPassword {
            self.newPassword = self.tfEmailList[0].text ?? ""
            valid = expectPasswordFormat(self.newPassword)
        }
        let isSame = self.tfEmailList[0].text == self.tfEmailList[1].text
        let passwordIsRight = self.tfPassword.text == ModelSingleton.shared.userConfig.user.password
        guard passwordIsRight && valid && isSame else {
            if !passwordIsRight {
                ProfileManager.shared.showAlertView(errorMessage: "密碼錯誤", handler: nil)
                self.tfPassword.text = ""
            }
            let formatErrorString = self.type == .resetAddress ? "信箱格式錯誤" : "密碼格式錯誤"
            let notSameString = self.type == .resetAddress ? "信箱不一致" : "密碼不一致"
            if !valid || !isSame {
                self.hintString = !valid ? formatErrorString : notSameString
            }
            return
        }
        self.viewModel.resetAddressPassword(newAddress: self.newAddress, newPassword: self.newPassword)
    }
    //檢查信箱格式
    private func expectEmailFormat(_ email: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: "^\\w+@\\w+$", options: .caseInsensitive)
        return !regex.matches(in: email, options: [], range: NSRange(location: 0, length: email.count)).isEmpty
    }
    //檢查密碼格式
    private func expectPasswordFormat(_ password: String) -> Bool {
        let numberRegex = try! NSRegularExpression(pattern: "\\d+", options: .caseInsensitive)
        let alpRegex = try! NSRegularExpression(pattern: "[a-zA-Z]+", options: .caseInsensitive)
        let containNumber = !numberRegex.matches(in: password, options: [], range: NSRange(location: 0, length: password.count)).isEmpty
        let containAlp = !alpRegex.matches(in: password, options: [], range: NSRange(location: 0, length: password.count)).isEmpty
        return containNumber && containAlp
    }
}
// MARK: - ConfigureViewModel
extension SettingAccountVC {
    private func confiViewModel() {
        self.viewModel = LoginVM()
    }
    private func subsribeViewModel() {
        self.viewModel.resetAddressPasswordSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result {
                self.navigationController?.popViewController(animated: true)
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - SubscribeRX
extension SettingAccountVC {
    private func subscribe() {
        let newEmailValid = self.tfEmailList[0].rx.text.orEmpty.map{ $0.count > 0}
        let confirmEmailValid = self.tfEmailList[1].rx.text.orEmpty.map{ $0.count > 0}
        let passwordValid = self.tfPassword.rx.text.orEmpty.map{ $0.count > 0}
        
        let valid = Observable.combineLatest(newEmailValid, confirmEmailValid, passwordValid) { $0 && $1 && $2 }.share(replay: 1, scope: .whileConnected)
        valid.subscribe { (result) in
            self.btnSave.isEnabled = (result.element ?? false)
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: self.type == .resetAddress ? 3 : 2)], with: .automatic)
        }.disposed(by: self.disposeBag)
    }
}
// MARK: - UITableViewDelegate
extension SettingAccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.type.sectionList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.type.rowList[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if self.type == .setAddress {
            guard section != self.sectionList.count - 1 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                cell.textLabel?.text = "修改"
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
                cell.textLabel?.textAlignment = .center
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
            cell.textLabel?.text = self.oldAddress
            cell.textLabel?.textColor = .black
            cell.detailTextLabel?.text = self.oldAddress.isEmpty ? "尚未啟用" : "已啟用"
            cell.selectionStyle = .none
            return cell
        } else if self.type == .resetAddress {
            guard section != 0 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                cell.textLabel?.text = self.rowList[section][row]
                cell.detailTextLabel?.text = self.oldAddress
                cell.selectionStyle = .none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            let notLast = section != self.sectionList.count - 1
            cell.textLabel?.text = self.rowList[section][row]
            cell.textLabel?.textAlignment = notLast ? .natural : .center
            cell.textLabel?.textColor = notLast ? .black : (self.btnSave.isEnabled ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .lightGray)
            cell.selectionStyle = notLast ? .none : (self.btnSave.isEnabled ? .default : .none)
            cell.isUserInteractionEnabled = notLast ? true : self.btnSave.isEnabled
            switch section {
            case 1:
                cell.accessoryView = self.tfEmailList[row]
            case 2:
                cell.accessoryView = self.tfPassword
            default:
                cell.accessoryView = nil
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            let notLast = section != self.sectionList.count - 1
            cell.textLabel?.text = self.rowList[section][row]
            cell.textLabel?.textAlignment = notLast ? .natural : .center
            cell.textLabel?.textColor = notLast ? .black : (self.btnSave.isEnabled ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .lightGray)
            cell.selectionStyle = notLast ? .none : (self.btnSave.isEnabled ? .default : .none)
            cell.isUserInteractionEnabled = notLast ? true : self.btnSave.isEnabled
            switch section {
            case 0:
                cell.accessoryView = self.tfPassword
            case 1:
                cell.accessoryView = self.tfEmailList[row]
            default:
                cell.accessoryView = nil
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        let showHint = !self.hintString.isEmpty && (self.type == .resetAddress && section == 1 || self.type == .resetPassword && section == 1)
        view?.detailTextLabel?.text = showHint ? self.hintString : nil
        view?.textLabel?.text = self.sectionList[section] ?? ""
        return view
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let showHint = !self.hintString.isEmpty && (self.type == .resetAddress && section == 1 || self.type == .resetPassword && section == 1)
        if let headerView = view as? UITableViewHeaderFooterView, showHint {
            headerView.detailTextLabel?.textColor = .red
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let showHint = !self.hintString.isEmpty && (self.type == .resetAddress && section == 1 || self.type == .resetPassword && section == 1)
        return showHint ? 60 : 40
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        let text = self.type == .resetAddress ? """
        新增常用信箱的好處：
        1. 登入ChaiCard時可以使用常用信箱，不怕忘記
        2. 不需要擔心學校信箱畢業後被停用收回
        3. 能在常用信箱收到ChaiCard的通知信
        """ :
        "密碼需為6個以上的英文或數字"
        return self.type == .setAddress && section == 0 ? "這是您目前可以用來登入ChaiCard的信箱" :
            (self.type == .resetAddress && section == 1 || self.type == .resetPassword && section == 1 ? text : nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row

        if section == 3 && row == 0 && self.type == .resetAddress {
            save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if section == 2 && row == 0 && self.type == .resetPassword {
            save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if section == 1 && row == 0  && self.type == .setAddress {
            let vc = SettingAccountVC()
            vc.setContent(type: .resetAddress, title: "修改常用信箱")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
