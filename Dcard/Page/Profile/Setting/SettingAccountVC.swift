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
import IQKeyboardManagerSwift

enum SettingAccountMode {
    case setAddress
    case resetPassword
    case resetAddress
    case editCard
    case enterNewID
    case createCard
    
    var rowList: [[String]] {
        switch self {
        case .setAddress:
            return [[""], [""]]
        case .resetPassword:
            return [["原有密碼"], ["新密碼", "確認新密碼"], ["儲存"]]
        case .resetAddress:
            return [["目前信箱"], ["新信箱", "確認信箱"], ["輸入密碼"], ["儲存"]]
        case .editCard:
            return [["ID", "卡稱"]]
        case .enterNewID:
            return [["ID"]]
        case .createCard:
            return [["頭像", "ID", "卡稱", "國家", "學校", "系所", "感情狀態", "我的文章", "自我介紹"]]
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
            return ["開始填寫 ID 與卡稱吧!"]
        case .enterNewID:
            return ["其他會員將會用此ID來辨認你，若與其他平台(Email、Line、手機號碼、Instagram、Facebook帳號等)重複，將有可能被揭露真實身份，請謹慎思考"]
        case .createCard:
            return ["必填資料"]
        }
    }
}
class SettingAccountVC: UIViewController {
    lazy private var btnSave: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "儲存", style: .plain, target: self, action: #selector(self.save))
        barButtonItem.isEnabled = false
        return barButtonItem
    }()
    lazy private var btnHint: UIButton = {
        let button = UIButton(type: .infoLight)
        button.addTarget(self, action: #selector(self.alert), for: .touchUpInside)
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
        let placeholder = ["請輸入ID", "請輸入卡稱", "請輸入國家", "請輸入學校", "請輸入系所", "請輸入感情狀態", "我的文章", "請輸入自我介紹"]
        
        let width = 200
        var list = [UITextField]()
        let total = self.mode != .createCard ? 1 : 7
        (0...total).forEach { (i) in
            let tf = UITextField(frame: CGRect(x: 0, y: 0, width: width, height: 44))
            tf.delegate = self
            tf.placeholder = placeholder[i]
            tf.clearButtonMode = .whileEditing
            if i == 0 && self.mode != .createCard {
                if self.mode == .editCard {
                    let button = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
                    button.setImage(UIImage(systemName: "pencil"), for: .normal)
                    button.tintColor = #colorLiteral(red: 0.370555222, green: 0.3705646992, blue: 0.3705595732, alpha: 1)
                    button.addTarget(self, action: #selector(showCardIDPage), for: .touchUpInside)
                    tf.rightViewMode = .always
                    tf.rightView = button
                    tf.textColor = .systemGray3
                } else {
                    tf.textColor = .darkText
                }
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
    lazy private var hintVC: UIViewController = {
        let vc = UIViewController()
        guard let view = vc.view else { return vc }
        view.layer.cornerRadius = 15
        view.backgroundColor = .white
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "規則", attributes: [.font: UIFont.boldSystemFont(ofSize: 16)])
        view.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalToSuperview().offset(5)
            maker.height.equalTo(40)
            maker.width.equalToSuperview()
        }
        let button = UIButton(type: .custom)
        button.backgroundColor = .link
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("好", for: .normal)
        button.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        view.addSubview(button)
        button.snp.makeConstraints { (maker) in
            maker.width.equalToSuperview().dividedBy(2)
            maker.centerX.equalToSuperview()
            maker.height.equalTo(30)
            maker.bottom.equalToSuperview().offset(-5)
        }
        let textView = UITextView()
        textView.contentInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 10)
        textView.backgroundColor = .clear
        textView.attributedText = NSAttributedString(string: """
ID 規則
1. 不可與他人重複
2. 首字為英文字母
3. 只可以用小寫字母、數字、半形底線、點
4. 不可含dcard字串
5.長度不可超過15個字元

卡稱規則
1. 卡稱不可超過12個字元
2. 不可包含 dcard、Dcard、狄卡字串
""", attributes: [.font: UIFont.systemFont(ofSize: 16, weight: .light)])
        textView.isEditable = false
        textView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(textView)
        textView.snp.makeConstraints { (maker) in
            maker.centerX.equalToSuperview()
            maker.top.equalTo(label.snp.bottom)
            maker.width.equalTo(label.snp.width)
            maker.bottom.equalTo(button.snp.top).offset(-5)
        }
        return vc
    }()
    
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private var card: Card {
        return ModelSingleton.shared.userCard
    }
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
    private var cardNameOK = false {
        didSet {
            cardNameOKSubject.on(.next(self.cardNameOK))
        }
    }
    private let cardNameOKSubject = BehaviorSubject<Bool>(value: false)
    private var hintOpend = false
    private var viewModelUser: LoginVMInterface!
    private var viewModelCard: CardVMInterface!
    
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
        self.tableView.reloadData()
        if self.mode == .editCard || self.mode == .enterNewID {
            IQKeyboardManager.shared.enableAutoToolbar = false
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
            confiDoneButton()
            self.tfCard[self.mode != .enterNewID ? 0 : 1].becomeFirstResponder()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if self.mode == .editCard || self.mode == .enterNewID {
            IQKeyboardManager.shared.enableAutoToolbar = true
            IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        }
    }
    func setContent(mode: SettingAccountMode, title: String) {
        self.mode = mode
        self.navigationItemTitle = title
    }
}
// MARK: - SetupUI
extension SettingAccountVC {
    private func initView() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        ToolbarView.shared.show(false)
        self.sectionList = mode.sectionList
        self.rowList = mode.rowList
        
        self.oldAddress = self.user.address
        self.oldPassword = self.user.password
        self.cardName = self.card.name
        self.cardID = self.card.id
        
        confiTableView()
        confiNav()
    }
    private func confiTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "RightDetailCell")
        self.tableView.register(UITableViewHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: "HeaderView")
        self.tableView.showsVerticalScrollIndicator = self.mode == .editCard || self.mode == .enterNewID
    }
    private func confiNav() {
        self.navigationItem.title = self.navigationItemTitle
        if self.mode == .resetAddress || self.mode == .resetPassword  || self.mode == .createCard {
            self.navigationItem.rightBarButtonItem = self.btnSave
        }
        if self.mode == .editCard || self.mode == .enterNewID {
            self.navigationItem.setRightBarButton(UIBarButtonItem(customView: self.btnHint), animated: true)
            guard self.mode == .editCard else { return }
            let btn = UIButton()
            btn.setImage(UIImage(systemName: "xmark"), for: .normal)
            btn.addTarget(self, action: #selector(self.close), for: .touchUpInside)
            self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: btn), animated: false)
        }
    }
    private func confiDoneButton() {
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        let btnDone = UIBarButtonItem(title: "完成", style: .done, target: self, action: #selector(updateCard))
        let letfLexibeSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let rightLexibeSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([letfLexibeSpace, btnDone, rightLexibeSpace], animated: true)
        
        if self.mode == .editCard {
            let nameValid = self.tfCard[1].rx.text.orEmpty.map{ $0 != self.cardName && $0.count > 0 }
            let allVilid = Observable.combineLatest(nameValid, self.cardNameOKSubject) {$0 && $1}.share(replay: 1, scope: .whileConnected)
            allVilid.bind(to: btnDone.rx.isEnabled).disposed(by: self.disposeBag)
            self.tfCard[1].inputAccessoryView = toolBar
        } else {
            let idValid = self.tfCard[0].rx.text.orEmpty.map{ $0 != self.cardID && $0.count > 0 }
            idValid.bind(to: btnDone.rx.isEnabled).disposed(by: self.disposeBag)
            self.tfCard[0].inputAccessoryView = toolBar
        }
    }
}
// MARK: - Private Handler
extension SettingAccountVC {
    //重設帳號資訊
    @objc private func save() {
        guard self.mode != .createCard else {
            let initCard = ModelSingleton.shared.userCard
            self.viewModelCard.createCard(card: Card(uid: ModelSingleton.shared.userConfig.user.uid, id: self.tfCard[0].text ?? "", name: self.tfCard[1].text ?? "", photo: ModelSingleton.shared.userConfig.user.avatar, sex: ModelSingleton.shared.userConfig.user.sex, introduce: self.tfCard[7].text ?? "", country: self.tfCard[2].text ?? "", school: self.tfCard[3].text ?? "", department: self.tfCard[4].text ?? "", article: self.tfCard[6].text ?? "", birthday: ModelSingleton.shared.userConfig.user.birthday, love: self.tfCard[5].text ?? "", fans: initCard.fans, followCard: initCard.followCard, friendCard: initCard.friendCard, beKeeped: initCard.beKeeped, beReplyed: initCard.fans, getHeart: initCard.getHeart, mood: initCard.mood))
            return
        }
        guard self.mode != .editCard && self.mode != .enterNewID else {
            WaitingView.shared.show(true)
            if self.mode == .editCard {
                self.viewModelCard.updateCardInfo(card: [.name: self.tfCard[1].text ?? ""])
            } else {
                self.viewModelCard.updateCardInfo(card: [.id: self.tfCard[0].text ?? ""])
            }
            return
        }
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
                AlertManager.shared.showAlertView(errorMessage: "密碼錯誤", handler: nil)
                self.tfPassword.text = ""
            }
            let formatErrorString = self.mode == .resetAddress ? "信箱格式錯誤" : "密碼格式錯誤"
            let notSameString = self.mode == .resetAddress ? "信箱不一致" : "密碼不一致"
            if !valid || !isSame {
                self.hintString = !valid ? formatErrorString : notSameString
            }
            return
        }
        WaitingView.shared.show(true)
        self.viewModelUser.updateUserInfo(user: [.address: self.newAddress, .password: self.newPassword])
    }
    //跳出ID規則視窗
    @objc private func alert() {
        self.hintVC.modalPresentationStyle = .popover
        self.hintVC.preferredContentSize = CGSize(width: self.view.bounds.width - 40, height: self.view.bounds.height / 2)
        self.hintVC.popoverPresentationController?.delegate = self
        self.hintVC.popoverPresentationController?.sourceView = self.btnHint
        present(self.hintVC, animated: true, completion: nil)
    }
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    @objc private func updateCard() {
        self.view.endEditing(true)
        save()
    }
    //卡稱是否確認修正
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
    //是否前往編輯卡稱ID頁面
    @objc private func showCardIDPage() {
        let alert = UIAlertController(title: "注意", message: "你只有一次修改ID的機會，且這個ID是會對其他使用者顯示的，請謹慎選擇。", preferredStyle: .alert)
        let laterAction = UIAlertAction(title: "之後再說", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction(title: "前往修改", style: .default) { (action) in
            let vc = SettingAccountVC()
            vc.setContent(mode: .enterNewID, title: "輸入新的 ID")
            self.navigationController?.pushViewController(vc, animated: true)
        }
        alert.addAction(laterAction)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    //檢查信箱格式
    private func expectEmailFormat(_ email: String) -> Bool {
        return !email.match("^\\w+@\\w+$", options: .caseInsensitive).isEmpty
    }
    //檢查密碼格式
    private func expectPasswordFormat(_ password: String) -> Bool {
        let containNumber = !password.match("\\d+", options: .caseInsensitive).isEmpty
        let containAlp = !password.match("[a-zA-Z]+", options: .caseInsensitive).isEmpty
        return containNumber && containAlp
    }
}
// MARK: - ConfigureViewModel
extension SettingAccountVC {
    private func confiViewModel() {
        self.viewModelUser = LoginVM()
        self.viewModelCard = CardVM()
    }
    private func subsribeViewModel() {
        self.viewModelUser.updateUserInfoSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            WaitingView.shared.show(false)
            if result.data {
//                if self.mode == .editCard || self.mode == .enterNewID || self.mode == .resetPassword {
//                    let alert = UIAlertController(title: "修改完成", message: "編輯" + (self.mode == .editCard ? "卡稱" : self.mode == .resetPassword ? "密碼" : "ID") + "成功！\n稍等一下才會同步完畢唷！", preferredStyle: .alert)
//                    let cancelAction = UIAlertAction(title: "好", style: .default) { (action) in
//                        if self.mode == .resetPassword {
//                            self.navigationController?.popViewController(animated: true)
//                        } else {
//                            self.dismiss(animated: true, completion: nil)
//                        }
//                    }
//                    alert.addAction(cancelAction)
//                    self.present(alert, animated: true, completion: nil)
//                } else {
//                    self.navigationController?.popViewController(animated: true)
//                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModelCard.updateCardInfoSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                WaitingView.shared.show(false)
                if self.mode == .editCard || self.mode == .enterNewID || self.mode == .resetPassword {
                    let alert = UIAlertController(title: "修改完成", message: "編輯" + (self.mode == .editCard ? "卡稱" : self.mode == .resetPassword ? "密碼" : "ID") + "成功！\n稍等一下才會同步完畢唷！", preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "好", style: .default) { (action) in
                        if self.mode == .resetPassword {
                            self.navigationController?.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModelCard.createCardSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                self.navigationController?.popViewController(animated: false, completion: {
                    ProfileManager.shared.toNextPage(next: .myCard)
                })
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - SubscribeRX
extension SettingAccountVC {
    private func subscribe() {
        if self.mode == .resetAddress || self.mode == .resetPassword {
            let newEmailValid = self.tfEmailList[0].rx.text.orEmpty.map{ $0.count > 0}
            let confirmEmailValid = self.tfEmailList[1].rx.text.orEmpty.map{ $0.count > 0}
            let passwordValid = self.tfPassword.rx.text.orEmpty.map{ $0.count > 0}
            
            let valid = Observable.combineLatest(newEmailValid, confirmEmailValid, passwordValid) { $0 && $1 && $2 }.share(replay: 1, scope: .whileConnected)
            valid.subscribe { (result) in
                self.btnSave.isEnabled = (result.element ?? false)
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: self.mode == .resetAddress ? 3 : 2)], with: .automatic)
            }.disposed(by: self.disposeBag)
        }
        if self.mode == .createCard {
            let validArray: [Observable<Bool>] = self.tfCard.map { (tf) -> Observable<Bool> in
                return tf.rx.text.orEmpty.map { $0.count > 0}
            }
            let valid = Observable.combineLatest(validArray).map { return $0.filter { !$0 }.isEmpty }
            valid.bind(to: self.btnSave.rx.isEnabled).disposed(by: self.disposeBag)
        }
    }
}
extension SettingAccountVC: UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return !(self.mode == .editCard && textField === self.tfCard[0])
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
        let rowData = self.rowList[section][row]
        
        if self.mode == .setAddress {
            guard section != self.sectionList.count - 1 else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                cell.textLabel?.text = "修改"
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
                cell.textLabel?.textAlignment = .center
                cell.selectionStyle = .none
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
                cell.textLabel?.text = rowData
                cell.detailTextLabel?.text = self.oldAddress
                cell.selectionStyle = .none
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            let notLast = section != self.sectionList.count - 1
            cell.textLabel?.text = rowData
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
            cell.textLabel?.text = rowData
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
            cell.selectionStyle = .none
            if row != 0 && self.mode == .createCard || self.mode != .createCard {
                let tf = self.tfCard[self.mode == .createCard ? row - 1 : row]
                if self.mode != .createCard {
                    tf.text = row == 0 ? self.cardID : self.cardName
                }
                cell.accessoryView = tf
            }
            cell.textLabel?.text = rowData
            cell.textLabel?.textColor = .black
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderView")
        let sectionTitle = self.sectionList[section] ?? ""
        if self.mode != .editCard && self.mode != .enterNewID {
            view?.contentView.subviews.forEach({ (view) in
                view.removeFromSuperview()
            })
            let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
            view?.textLabel?.text = sectionTitle
            view?.detailTextLabel?.text = showHint ? self.hintString : nil
        } else {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.text = sectionTitle
            label.textAlignment = .center
            label.numberOfLines = 0
            label.textAlignment = self.mode == .enterNewID ? .natural : .center
            label.adjustsFontSizeToFitWidth = true
            label.textColor = self.mode == .enterNewID ? .systemRed : #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            view?.addSubview(label)
            label.snp.makeConstraints { (maker) in
                maker.centerX.equalToSuperview()
                maker.width.equalToSuperview().dividedBy(1.5)
                maker.top.equalToSuperview().offset(10)
                maker.bottom.equalToSuperview().offset(-10)
            }
        }
        return view
    }
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {

            if self.mode != .editCard && self.mode != .enterNewID {
                let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
                if showHint {
                    headerView.detailTextLabel?.textColor = .red
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        guard self.mode != .editCard && self.mode != .enterNewID else { return 100 }
        let showHint = !self.hintString.isEmpty && (self.mode == .resetAddress && section == 1 || self.mode == .resetPassword && section == 1)
        return showHint ? 60 : 40
    }
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        guard self.mode != .editCard && self.mode != .enterNewID else { return nil }
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

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard self.mode != .editCard else {
            let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 100))
            let button = UIButton(type: .system)
            button.setTitle("我知道 ID 日後不能更改，且若與其他平台使用相同ID 可能會揭露真實身份", for: .normal)
            button.addTarget(self, action: #selector(confirm), for: .touchUpInside)
            button.setTitleColor(#colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1), for: .normal)
            button.titleLabel?.numberOfLines = 0
            button.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(button)
            button.snp.makeConstraints { (maker) in
                maker.centerX.equalToSuperview()
                maker.width.equalToSuperview().dividedBy(1.5)
                maker.top.equalToSuperview().offset(10)
                maker.bottom.equalToSuperview().offset(-10)
            }
            view.addSubview(self.viewOK)
            self.viewOK.snp.makeConstraints { (maker) in
                maker.centerY.equalToSuperview()
                maker.trailing.equalTo(button.snp.leading).offset(-10)
                maker.width.height.equalTo(20)
            }
            return view
        }
        return nil
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        guard self.mode != .editCard && self.mode != .enterNewID else { return 100 }
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard self.mode != .editCard && self.mode != .enterNewID else { return }
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
extension SettingAccountVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
