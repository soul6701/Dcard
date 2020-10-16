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

enum SettingAccountMode {
    case setAddress
    case resetPassword
    case resetAddress
    case editCard
    
    var rowList: [[String]] {
        switch self {
        case .setAddress:
            return [[""], [""]]
        case .resetPassword:
            return [["原有密碼"], ["新密碼", "確認新密碼"], ["儲存"]]
        case .resetAddress:
            return [["目前信箱"], ["新信箱", "確認信箱"], ["輸入密碼"], ["儲存"]]
        case .editCard:
            return [["開始填寫 ID 與卡稱吧!", "ID", "卡稱", "我知道 ID 日後不能更改，且若與其他平台使用相同ID 可能會揭露真實身份"]]
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
        case .editCard:
            return [""]
        }
    }
}
class SettingAccountVC: UIViewController {
    lazy private var btnSave: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(save))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()
    lazy private var btnHint: UIButton = {
        let button = UIButton(type: .infoLight)
        button.addTarget(self, action: #selector(alert), for: .touchUpInside)
        return button
    }()
    lazy private var btnClose: UIButton = {
        let button = UIButton(type: .close)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        return button
    }()
    lazy private var tfEmailList: [UITextField] = {
        let placeholderRowOne = self.mode == .resetAddress ? "請輸入欲修改的信箱" : "請輸入新密碼"
        let placeholderRowTwo = self.mode == .resetAddress ? "再次輸入新信箱" : "再次輸入新密碼"
        let width = self.mode == .resetAddress ? 200 : 150
        var list = [UITextField]()
        (0...1).forEach { (i) in
            let tf = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
            tf.placeholder = i == 0 ? placeholderRowOne : placeholderRowTwo
            tf.clearButtonMode = .whileEditing
            tf.isSecureTextEntry = self.mode == .resetPassword
            list.append(tf)
        }
        return list
    }()
    lazy private var tfPassword: UITextField = {
        let placeholder = self.mode == .resetAddress ? "請輸入密碼" : "請輸入目前密碼"
        let width = self.mode == .resetAddress ? 200 : 150
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        tf.placeholder = placeholder
        tf.isSecureTextEntry = true
        tf.clearButtonMode = .whileEditing
        return tf
    }()
    lazy private var tfCard: [UITextField] = {
        let placeholderRowOne = "請輸入ID"
        let placeholderRowTwo = "請輸入卡稱"
        let width = 200
        var list = [UITextField]()
        let tf = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
        (0...1).forEach { (i) in
            let tf = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
            tf.placeholder = i == 0 ? placeholderRowOne : placeholderRowTwo
            tf.clearButtonMode = .whileEditing
            if i == 0 {
                let imageView = UIImageView(image: UIImage(systemName: "pencil")!)
                imageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                imageView.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                imageView.contentMode = .scaleAspectFit
                tf.rightViewMode = .always
                tf.rightView = imageView
            }
            list.append(tf)
        }
        return list
    }()
    lazy private var viewOK: UIView = {
        let view = customView()
        view.viewBorderWidth = 1
        view.viewBorderColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
        let tap = UITapGestureRecognizer(target: self, action: #selector(confirm))
        view.addGestureRecognizer(tap)
        return view
    }()
    private var mode: SettingAccountMode = .setAddress
    private var oldAddress = ""
    private var newAddress = ""
    private var oldPassword = ""
    private var newPassword = ""
    private var cardName = ""
    private var cardID = ""
    private var navigationItemTitle = ""
    private var sectionList = [String?]()
    private var rowList = [[String]]()
    private var hintString = "" {
        didSet {
            self.tableView.reloadData()
        }
    }
    private let disposeBag = DisposeBag()
    
    private var cardNameOK = false
    private var hintOpend = false
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
        self.cardName = user.card.name
        self.cardID = user.card.id
        self.tableView.reloadData()
    }
    
    func setContent(mode: SettingAccountMode, title: String) {
        self.mode = mode
        self.navigationItemTitle = title
    }
}
// MARK: - SetupUI
extension SettingAccountVC {
    private func initView() {
        self.sectionList = mode.sectionList
        self.rowList = mode.rowList
        
        confiTableView()
        confiNav()
        
        if self.mode == .editCard {
            self.tfCard[1].becomeFirstResponder()
        }
    }
    private func confiTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "RightDetailCell")
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        self.tableView.showsVerticalScrollIndicator = false
    }
    private func confiNav() {
        self.navigationItem.title = self.navigationItemTitle
        if self.mode != .setAddress && self.mode != .editCard {
            self.navigationItem.rightBarButtonItem = self.btnSave
        }
        if self.mode == .editCard {
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView: self.btnHint), animated: true)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: self.btnClose), animated: true)
        }
    }
}
// MARK: - Private Func
extension SettingAccountVC {
    @objc private func save() {
        var valid = false
        self.hintString = ""
        if self.mode == .resetAddress {
            self.newAddress = self.tfEmailList[0].text ?? ""
            valid = expectEmailFormat(self.newAddress)
        }
        if self.mode == .resetPassword {
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
            let formatErrorString = self.mode == .resetAddress ? "信箱格式錯誤" : "密碼格式錯誤"
            let notSameString = self.mode == .resetAddress ? "信箱不一致" : "密碼不一致"
            if !valid || !isSame {
                self.hintString = !valid ? formatErrorString : notSameString
            }
            return
        }
        self.viewModel.resetAddressPassword(newAddress: self.newAddress, newPassword: self.newPassword)
    }
    @objc private func alert() {
        
        if !self.hintOpend {
            let vc = UIViewController()
            vc.modalPresentationStyle = .popover
            vc.popoverPresentationController?.sourceView = self.btnHint
            present(vc, animated: true) {
                vc.view.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
            }
        } else {
            
        }
        self.hintOpend = !self.hintOpend
    }
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func confirm() {
        self.cardNameOK = !self.cardNameOK
        if self.cardNameOK {
            let view = UIView()
            view.backgroundColor = .link
            self.viewOK.addSubview(view)
            view.snp.makeConstraints { (maker) in
                maker.top.leading.equalToSuperview().offset(4)
                maker.bottom.trailing.equalToSuperview().offset(-4)
            }
        } else {
            self.viewOK.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
        }
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
            self.tableView.reloadRows(at: [IndexPath(row: 0, section: self.mode == .resetAddress ? 3 : 2)], with: .automatic)
        }.disposed(by: self.disposeBag)
    }
}
// MARK: - UITableViewDelegate
extension SettingAccountVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.mode.sectionList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mode.rowList[section].count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if self.mode == .setAddress {
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
        } else if self.mode == .resetAddress {
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
        } else if self.mode == .resetPassword {
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            let rowData = self.rowList[section][row]
            let lb = UILabel()
            lb.translatesAutoresizingMaskIntoConstraints = false
            lb.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            lb.text = rowData
            lb.numberOfLines = 0
            lb.textAlignment = .center
            cell.selectionStyle = .none
            switch row {
            case 0:
                cell.addSubview(lb)
                cell.accessoryView = nil
                lb.snp.makeConstraints { (maker) in
                    maker.centerX.equalToSuperview()
                    maker.width.equalTo(self.view.snp.width)
                    maker.top.equalToSuperview()
                    maker.bottom.equalToSuperview().offset(-20)
                }
            case 1, 2:
                let tf = self.tfCard[row - 1]
                self.tfCard[row - 1].text = row - 1 == 0 ? self.cardID : self.cardName
                cell.textLabel?.text = rowData
                cell.textLabel?.textColor = .black
                cell.accessoryView = tf
            default:
                cell.addSubview(lb)
                cell.accessoryView = nil

                lb.snp.makeConstraints { (maker) in
                    maker.centerX.equalToSuperview()
                    maker.width.equalTo(self.view.snp.width).dividedBy(1.5)
                    maker.top.equalToSuperview()
                    maker.bottom.equalToSuperview()
                }
                
                cell.addSubview(self.viewOK)
                self.viewOK.snp.makeConstraints { (maker) in
                    maker.centerY.equalToSuperview()
                    maker.trailing.equalTo(lb.snp.leading).offset(-10)
                    maker.width.height.equalTo(20)
                }
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        return self.mode == .editCard && (row == 0 || row == 3) ? 100 : UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard self.mode != .editCard else { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
        view?.detailTextLabel?.text = showHint ? self.hintString : nil
        view?.textLabel?.text = self.sectionList[section] ?? ""
        return view
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
        if let headerView = view as? UITableViewHeaderFooterView, showHint {
            headerView.detailTextLabel?.textColor = .red
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.mode != .editCard else { return CGFloat.leastNonzeroMagnitude }
        let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
        return showHint ? 60 : 40
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard self.mode != .editCard else { return nil }
        let text = self.mode == .resetAddress ? """
        新增常用信箱的好處：
        1. 登入ChaiCard時可以使用常用信箱，不怕忘記
        2. 不需要擔心學校信箱畢業後被停用收回
        3. 能在常用信箱收到ChaiCard的通知信
        """ :
        "密碼需為6個以上的英文或數字"
        return self.mode == .setAddress && section == 0 ? "這是您目前可以用來登入ChaiCard的信箱" :
            (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1 ? text : nil)
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.mode != .editCard else { return }
        let section = indexPath.section
        let row = indexPath.row

        if section == 3 && row == 0 && self.mode == .resetAddress {
            save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if section == 2 && row == 0 && self.mode == .resetPassword {
            save()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
        if section == 1 && row == 0  && self.mode == .setAddress {
            let vc = SettingAccountVC()
            vc.setContent(mode: .resetAddress, title: "修改常用信箱")
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
