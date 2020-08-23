//
//  ProfileVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/10.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import IQKeyboardManagerSwift
import SwiftMessages
import MarqueeLabel

enum ChatRoomDirectionMode {
    case down
    case up
}
enum ChatRoomContentMode {
    case search
    case message
}
class ContextMode {
    var mode: messageCellType
    var context: String
    
    init(context: String, mode: messageCellType) {
        self.context = context
        self.mode = mode
    }
}
class ChatRoomVC: UIViewController {
    
    
    @IBOutlet weak var lbNotFound: UILabel!
    @IBOutlet weak var viewEnterMessage: UIView!
    @IBOutlet weak var btnDirection: UIButton!
    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet weak var marqueeLabel: MarqueeLabel!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var tableViewSearchResult: UITableView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tfMessage: UITextField!
    @IBOutlet weak var lbHint: UILabel!
    
    private var searchMode: ChatRoomContentMode = .message {
        didSet {
            if searchMode == .search {
                if self.tfMessage.isFirstResponder {
                    self.tfMessage.resignFirstResponder()
                }
                self.searchBar.becomeFirstResponder()
                self.btnDirection.isHidden = true
            } else {
                self.btnDirection.isHidden = false
                self.lbNotFound.isHidden = true
                self.tableView.isHidden = false
                self.tableViewSearchResult.isHidden = true
                self.viewEnterMessage.isHidden = false
            
                IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                self.searchBar.text = ""
                self.tableView.reloadData()
//                self.searchArray = [ContextMode]()
//                self.tableViewSearchResult.reloadData()
            }
        }
    }
    private var searchView: UISearchController!
    private var searchArray = [ContextMode]() {
        didSet {
            self.lbNotFound.isHidden = !self.searchArray.isEmpty || self.searchBar.text?.isEmpty ?? true
            self.tableViewSearchResult.isHidden = self.searchArray.isEmpty
            self.tableView.isHidden = !self.searchArray.isEmpty || !(self.searchBar.text?.isEmpty ?? true)
            IQKeyboardManager.shared.shouldResignOnTouchOutside = self.lbNotFound.isHidden
            self.tableViewSearchResult.reloadData()
        }
    }
    private let disposeBag = DisposeBag()
    private var directionMode: ChatRoomDirectionMode = .down
    private var phoneView: MessageView!
    private var btnMenu: UIButton!
    private var btnPhone: UIButton!
    private var btnSearch: UIButton!
    private var currentBottomSpace: CGFloat = 0
    private var window: UIWindow {
        return UIApplication.shared.windows.first!
    }
    private var i = 0
    private var contextList = [ContextMode]()
    private var _contextList = ["你愛咖啡　低調的感覺　偏愛收集的音樂　怪的很另類", "你很特別　每一個小細節　哎呀呀呀　如此的對味", "我怕浪費　情緒的錯覺　討厭自己像刺蝟　小心的防備", "我很反對　為失戀掉眼淚　哎呀呀呀　離你遠一些", """
喜歡看你緊緊皺眉　叫我膽小鬼　你的表情大過於朋友的曖昧
     寂寞的稱謂　甜蜜的責備　有獨一無二專屬的特別
""", """
喜歡看你緊緊皺眉　叫我膽小鬼　我的心情就像和情人在鬥嘴
奇怪的直覺　錯誤的定位　對你哎呀呀呀　我有點膽怯
""", """
我在我的世界不能犯規
你在你的世界笑我無所謂
"""]
    private var marqueeTextArray = ["歡迎收聽“麻瓜聯播網”FM94.87，這邊是DJ臭肥宅，大家週末有什麼安排呢？先進入廣告，稍後回來！ 『我希望有個如你一般的人。如這山間清晨一般明亮清爽的人，如奔赴古城道路上陽光一般的人，溫暖而不炙熱，覆蓋我所有肌膚。由起點到夜晚，由山野到書房，一切問題的答案都很簡單。我希望有個如你一般的人，貫徹未來，數遍生命的公路牌。』", "『在季節的車上，如果你要提前下車，請別推醒裝睡的我，這樣我可以沉睡到終點，假裝不知道你已經離開。』"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        addObserverToKeyboard()
        self.currentBottomSpace = self.bottomSpace.constant
        IQKeyboardManager.shared.enable = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = false
        ToolbarView.shared.show(false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if self.searchMode == .search {
            self.btnDirection.isHidden = self.tableView.contentOffset.y <= 0 && !(self.tableView.contentSize.height > self.tableView.frame.size.height)
            resetButtonState()
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removerObserverFromKeyboard()
    }
    @IBAction func didClickBtnSend(_ sender: UIButton) {
        sendMessage(self.tfMessage)
    }
    @IBAction func didClickBtnDirection(_ sender: UIButton) {
        guard self.tableView.numberOfRows(inSection: 0) != 0 else {
            return
        }
        if self.directionMode == .down {
            self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: .top)
        } else {
            self.scrollToBottom()
            self.btnDirection.setImage(UIImage(named: ImageInfo.arrow_up), for: .normal)
            self.directionMode = .down
        }
    }
}
// MARK: - SetupUI
extension ChatRoomVC {
    private func initView() {
        self.btnSend.layer.cornerRadius = 10
        self.btnDirection.layer.cornerRadius = 10
        self.lbHint.text = ""
        self.lbNotFound.isHidden = true
        self.tableViewSearchResult.isHidden = true
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: ImageInfo.cat)!)
        confiTextfield()
        confiTableView()
        confiNav()
        confiHintView()
        setMarqueeText(self.marqueeTextArray)
    }
    
    private func confiTextfield() {
        self.tfMessage.layer.cornerRadius = 10
        self.tfMessage.delegate = self
        let image = UIButton()
        image.imageEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 5, right: 0)
        image.setImage(UIImage(named: ImageInfo.icecream), for: .normal)
        image.contentMode = .scaleAspectFit
        self.tfMessage.leftView = image
        self.tfMessage.leftViewMode = .always
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "messageCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.contentInset = UIEdgeInsets(top: 23 + 5, left: 0, bottom: 0, right: 0)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.tableViewSearchResult.contentInset = UIEdgeInsets(top: 23 + 5, left: 0, bottom: 0, right: 0)
        self.tableViewSearchResult.delegate = self
        self.tableViewSearchResult.dataSource = self
    }
    private func confiNav() {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationItem.title = "卡比獸"
        
        self.btnMenu = UIButton(type: .custom)
        self.btnMenu.setImage(UIImage(named: ImageInfo.chatroom_menu), for: .normal)
        self.btnMenu.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnMenu.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnMenu.addTarget(self, action: #selector(didClickBtnMenu), for: .touchUpInside)
    
        self.btnPhone = UIButton(type: .custom)
        self.btnPhone.setImage(UIImage(named: ImageInfo.phone), for: .normal)
        self.btnPhone.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnPhone.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnPhone.addTarget(self, action: #selector(didClickBtnPhone), for: .touchUpInside)
        
        self.btnSearch = UIButton(type: .custom)
        self.btnSearch.setImage(UIImage(named: ImageInfo.chatroom_search), for: .normal)
        self.btnSearch.widthAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnSearch.heightAnchor.constraint(equalToConstant: 40).isActive = true
        self.btnSearch.addTarget(self, action: #selector(didClickBtnSearch), for: .touchUpInside)
        
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: self.btnMenu), UIBarButtonItem(customView: self.btnPhone), UIBarButtonItem(customView: self.btnSearch)], animated: false)
    }
    private func confiHintView() {
//        self.phoneView = MessageView.viewFromNib(layout: .tabView)
    }
}
// MARK: - Handler
extension ChatRoomVC {
    @objc private func didClickBtnMenu() {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true)
    }
    @objc private func didClickBtnPhone() {
        self.phoneView = MessageView.viewFromNib(layout: .tabView)
        self.phoneView.configureTheme(backgroundColor: #colorLiteral(red: 0.8711531162, green: 0.4412498474, blue: 0.8271986842, alpha: 1), foregroundColor: .black)
        self.phoneView.id = "phone"
        self.phoneView.configureContent(title: "警告", body: "查無此用者，已遭封鎖", iconImage: UIImage(named: ImageInfo.alert)!)
        self.phoneView.configureIcon(withSize: CGSize(width: 64, height: 64), contentMode: .scaleAspectFit)
        self.phoneView.button?.removeFromSuperview()
        var config = SwiftMessages.Config()
        config.presentationContext = .window(windowLevel: .alert)
        config.presentationStyle = .center
        config.duration = .forever
        config.dimMode = .gray(interactive: true)
        config.eventListeners = .init(arrayLiteral: { (event) in
            if event == .didHide {
                SwiftMessages.hide(id: "phone")
                let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                imageView.loadGif(name: "哭泣")
                imageView.layer.zPosition = 100
                self.window.addSubview(imageView)
                self.window.bringSubviewToFront(imageView)
                let _ = Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (timer) in
                        imageView.removeFromSuperview()
                    }
            }
        })
        SwiftMessages.show(config: config, view: self.phoneView)
    }
    @objc private func didClickBtnSearch() {
        if self.searchMode == .message {
//            self.tfMessage.resignFirstResponder()
            self.searchBar.delegate = self
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: self.searchBar)
            self.navigationItem.setHidesBackButton(true, animated: true)
            let btnCancel = UIButton(type: .system)
            btnCancel.setTitle("取消", for: .normal)
            btnCancel.addTarget(self, action: #selector(didBtnCancel), for: .touchUpInside)
            self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: btnCancel)], animated: true)
            self.searchMode = .search
        }
    }
    @objc private func didBtnCancel() {
        hideSearchBar()
    }
    private func hideSearchBar() {
        self.navigationItem.leftBarButtonItem = nil
        self.navigationItem.setHidesBackButton(false, animated: false)
        self.navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: self.btnMenu), UIBarButtonItem(customView: self.btnPhone), UIBarButtonItem(customView: self.btnSearch)], animated: false)
        self.searchMode = .message
    }
    private func setMarqueeText(_ textArray: [String]) {
        self.marqueeLabel.textColor = .black
        self.marqueeLabel.shadowColor = .white
        self.marqueeLabel.shadowOffset = CGSize(width: 4, height: -1)
        self.marqueeLabel.backgroundColor = #colorLiteral(red: 0.7728639245, green: 1, blue: 0.8035855889, alpha: 1)
        self.marqueeLabel.speed = .rate(80)
        self.marqueeLabel.fadeLength = 10.0
        
        var text = ""
        for index in 0..<textArray.count {
            text += index != textArray.count - 1 ? textArray[index] + " " : textArray[index]
        }
        self.marqueeLabel.text = text
    }
    private func sendMessage(_ tf: UITextField) {
        guard let txt = tf.text, !txt.isEmpty else {
            return
        }
        self.contextList.append(ContextMode(context: txt, mode: .left))
        self.tableView.reloadData()
        self.view.layoutIfNeeded()
        updateTableContentInset()
        scrollToBottom()
        tf.text = ""
        
        speak()
    }
    private func speak() {
        guard self.i < self._contextList.count else {
            return
        }
        let random = Int.random(in: 0...2)
        let _random = Int.random(in: 0...3)
        var start = 0
        var _start = 0
        
        let _timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
            if _start == _random {
                timer.invalidate()
                self.lbHint.text = "卡比輸入中..."
                let timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
                    if start == random {
                        self.contextList.append(ContextMode(context: self._contextList[self.i], mode: .right))
                        self.i += 1
                        self.lbHint.text = ""
                        self.tableView.reloadData()
                        self.view.layoutIfNeeded()
                        self.updateTableContentInset()
                        self.scrollToBottom()
                        timer.invalidate()
                    }
                    start += 1
                }
                timer.fire()
            }
            _start += 1
        }
        _timer.fire()
    }
    private func scrollToBottom() {
        if self.contextList.count != 0 {
            let indexPath = IndexPath(row: tableView.numberOfRows(inSection: tableView.numberOfSections - 1) - 1, section: tableView.numberOfSections - 1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
        }
    }
    private func resetButtonState() {
        self.btnDirection.setImage(UIImage(named: self.tableView.contentOffset.y >= 0 ? ImageInfo.arrow_up : ImageInfo.arrow_down), for: .normal)
        self.directionMode = self.tableView.contentOffset.y >= 0 ? .down : .up
    }
    //tableView由下而上顯示
    private func updateTableContentInset() {
        let numRows = self.tableView.numberOfRows(inSection: 0)
        var contentInsetTop = self.tableView.bounds.size.height
        for i in 0..<numRows {
            let rowRect = self.tableView.rectForRow(at: IndexPath(item: i, section: 0))
            contentInsetTop -= rowRect.size.height
            if contentInsetTop <= 23 + 5 {
                contentInsetTop = 23 + 5
            }
        }
        self.tableView.contentInset = UIEdgeInsets(top: contentInsetTop,left: 0,bottom: 0,right: 0)
    }
}
// MARK: - Keyboard
extension ChatRoomVC {
    private func addObserverToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removerObserverFromKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func showKeyboard(_ noti: NSNotification) {
        if noti.name == UIResponder.keyboardWillShowNotification {
            if self.searchMode == .search {
//                IQKeyboardManager.shared.shouldResignOnTouchOutside = false
//                self.searchBar.keyboardDistanceFromTextField = 50
//                self.viewEnterMessage.isHidden = true
            } else {
//                IQKeyboardManager.shared.shouldResignOnTouchOutside = true
                self.bottomSpace.constant = -self.window.safeAreaInsets.bottom
                self.view.layoutIfNeeded()
                self.scrollToBottom()
                
            }
        }
    }
    @objc private func hideKeyboard(_ noti: NSNotification) {
        if noti.name == UIResponder.keyboardWillHideNotification {
            if self.searchMode == .search {
//                self.hideSearchBar()
                self.viewEnterMessage.isHidden = true
            } else {
                self.bottomSpace.constant = self.currentBottomSpace
                self.view.layoutIfNeeded()
            }
        }
    }
}
// MARK: - UITableViewDelegate
extension ChatRoomVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchMode == .message && tableView != self.tableViewSearchResult ? self.contextList.count : self.searchArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.searchMode == .message && tableView != self.tableViewSearchResult {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! messageCell
            cell.setContent(context: contextList[indexPath.row].context, mode: contextList[indexPath.row].mode)
            cell.selectionStyle = .none
            return cell
        } else {
            let cell = UITableViewCell()
            cell.backgroundColor = .black
            cell.textLabel?.textColor = .white
            cell.imageView?.image = UIImage(named: self.searchArray[indexPath.row].mode == .left ? ImageInfo.pikachu : ImageInfo.carbi)
            cell.textLabel?.text = self.searchArray[indexPath.row].context
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.searchMode == .message && tableView != self.tableViewSearchResult ? UITableView.automaticDimension : 100
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if searchMode == .message && tableView != self.tableViewSearchResult {
            return nil
        } else {
            if !(self.searchBar.text?.isEmpty ?? true) {
                let lbHint = UILabel()
                lbHint.text = "搜索結果"
                lbHint.backgroundColor = .white
                lbHint.textColor = .black
                return lbHint
            }
            return nil
        }
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return searchMode == .message && tableView != self.tableViewSearchResult ?
            UITableView.automaticDimension : !(self.searchBar.text?.isEmpty ?? true) ? 30 : UITableView.automaticDimension
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if self.searchMode == .message {
            self.btnDirection.isHidden = self.tableView.contentOffset.y <= 0 && !(self.tableView.contentSize.height > self.tableView.frame.size.height)
            resetButtonState()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.searchMode == .message {
            resetButtonState()
        }
    }
}
// MARK: - UITextFieldDelegate
extension ChatRoomVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        sendMessage(textField)
        return true
    }
}
// MARK: - UISearchBarDelegate
extension ChatRoomVC: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let _seachArray = contextList.filter({ (context) -> Bool in
            if let range = context.context.range(of: searchText, options: .caseInsensitive, range: context.context.startIndex..<context.context.endIndex, locale: nil) {
                return !range.isEmpty
            }
            return false
        })
        self.searchArray = _seachArray
    }
}
// MARK: - UIImagePickerControllerDelegate
extension ChatRoomVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       let image = info[.originalImage] as? UIImage
        self.view.backgroundColor = UIColor(patternImage: image!)
        picker.dismiss(animated: true, completion: nil)
    }
}
