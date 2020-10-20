//
//  PostVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit
import RxCocoa
import RxSwift

class PostVC: UIViewController {
    
    @IBOutlet weak var btnAddComment: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tvExcerpt: UITextView!
    @IBOutlet weak var btnShowComment: UIButton!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewOption: UIStackView!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var _bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    @IBOutlet weak var viewNewComment: UIView!
    
    private let disposeBag = DisposeBag()
    private var post = Post()
    private var commentList = [Comment]()
    private var viewSetting = UIView()
    private var viewBg = UIView()
    private var window: UIWindow! {
        return UIApplication.shared.windows.first!
    }
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private var previousRect = CGRect()
    private var show: Bool = false {
        didSet {
            if show {
                self.btnShowComment.setImage(UIImage(named: ImageInfo.down), for: .normal)
                self.view.sendSubviewToBack(self.viewNewComment)
            } else {
                self.btnShowComment.setImage(UIImage(named: ImageInfo.up), for: .normal)
                self.view.bringSubviewToFront(self.viewNewComment)
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        subscribe()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObserverToKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removerObserverFromKeyboard()
    }
    @IBAction func show(_ sender: UIButton) {
        self.show = !self.show
        self.bottomSpace.constant += self.show ? 200 : -200
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    func setContent(post: Post, commentList: [Comment]) {
        self.post = post
        self.commentList = commentList
    }
    @IBAction func didClickAddComment(_ sender: UIButton) {
        self.tvComment.becomeFirstResponder()
        self.viewSeparator.isHidden = true
        self.viewOption.isHidden = true
        sender.isSelected = true
    }
}
// MARK: - SetupUI
extension PostVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.btnShowComment.isHidden = self.commentList.isEmpty
        confiTextFieldView()
        confiTableView()
        confiButton()
    }
    private func confiTextFieldView() {
        self.tvExcerpt.isEditable = false
        self.tvExcerpt.text = self.post.excerpt
        self.tvComment.delegate = self
        self.tvComment.text = "回應..."
        self.tvComment.textColor = .lightGray
        self.tvComment.addDoneOnKeyboardWithTarget(self, action: #selector(cancel), titleText: "取消")
        self.tvComment.addRightButtonOnKeyboardWithText("取消", target: self, action: #selector(cancel), titleText: nil)
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    private func confiButton() {
        self.btnAddComment.titleLabel?.numberOfLines = 0
        self.btnAddComment.setImage(UIImage(named: ImageInfo.profile), for: .normal)
        let initString = NSMutableAttributedString(string: "反應...", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        self.btnAddComment.setAttributedTitle(initString, for: .normal)
        
        let attributedString = NSMutableAttributedString(string: "臺灣科技大學 >", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkText])
        attributedString.append(NSMutableAttributedString(string: "\n B53, 2020/10/20 17:39", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        self.btnAddComment.setAttributedTitle(attributedString, for: .selected)
    }
}
// MARK: - Private func
extension PostVC {
    @objc private func close() {
        self.viewBg.removeFromSuperview()
        self.viewSetting.removeFromSuperview()
    }
    @objc private func cancel() {
        
    }
    @objc private func send() {
        self.viewHeight.constant = 150
        self.view.layoutIfNeeded()
        self.btnAddComment.isSelected = false
        self.commentList.append(Comment(id: self.user.card.id, anonymous: true, content: self.tvComment.text, createdAt: "2020/05/05", floor: self.commentList.count + 1, likeCount: 0, gender: "F", department: self.user.card.department, school: self.user.card.school, withNickname: true, host: false, mediaMeta: []))
        self.tableView.reloadData()
        self.view.endEditing(true)
    }
}
extension PostVC {
    private func subscribe() {
        let isValid = self.tvComment.rx.text.orEmpty.map { return $0.count > 0}
        isValid.subscribe { (result) in
            if result.element == true {
                self.tvComment.addRightButtonOnKeyboardWithText("完成", target: self, action: #selector(self.send), titleText: nil)
            } else {
                self.tvComment.addRightButtonOnKeyboardWithText("取消", target: self, action: #selector(self.cancel), titleText: nil)
            }
        }.disposed(by: self.disposeBag)
    }
}
// MARK: - Keyboard
extension PostVC {
    private func addObserverToKeyboard() {
        NotificationCenter.default.addObserver(self, selector: #selector(showKeyboard(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideKeyboard(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    private func removerObserverFromKeyboard() {
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    @objc private func showKeyboard(_ noti: NSNotification) {
        self._bottomSpace.constant = 0
        self.view.layoutIfNeeded()
    }
    @objc private func hideKeyboard(_ noti: NSNotification) {
        self._bottomSpace.constant = -100
        self.view.layoutIfNeeded()
    }
}
// MARK: - UITableViewDelegate
extension PostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        cell.selectionStyle = .none
        cell.setContent(comment: commentList[indexPath.row], view: view)
        cell.setDelegate(self)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
// MARK: - showSettingViewDelegate
extension PostVC: showSettingViewDelegate {
    func showView(location: CGPoint, floor: Int) {
        guard let view = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SettingView else {
            return
        }
        guard let height = navigationController?.navigationBar.bounds.height else { return }
        self.viewBg = UIView(frame: CGRect(x: 0, y: height + window.safeAreaInsets.top, width: self.view.bounds.width, height: self.view.bounds.height - height - window.safeAreaInsets.top))
        self.viewBg.backgroundColor = .black
        self.viewBg.alpha = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.viewBg.addGestureRecognizer(tap)
        
        view.setContent(floor: floor)
        self.viewSetting = view
        self.viewSetting.frame = CGRect(x: location.x - 150, y: location.y - 80, width: 150, height: 80)
        
        self.window.addSubview(self.viewBg)
        self.window.addSubview(self.viewSetting)
    }
}
// MARK: - UITextViewDelegate
extension PostVC: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        let pos = textView.endOfDocument
        let currentRect = textView.caretRect(for: pos)
        let willBeExtend = self.viewHeight.constant <= 190
        if previousRect != CGRect.zero && willBeExtend {
            if currentRect.origin.y > previousRect.origin.y {
                self.viewHeight.constant += 20
                self.view.layoutIfNeeded()
            }
        }
        self.previousRect = currentRect
    }
}
