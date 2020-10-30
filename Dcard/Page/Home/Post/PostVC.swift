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
import IQKeyboardManagerSwift
import SwiftMessages

private class PresentationController : UIPresentationController {
    
    lazy private var bgButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .black
        button.alpha = 0.8
        button.addTarget(self, action: #selector(self.willDismiss), for: .touchUpInside)
        return button
    }()
    
    private var height: CGFloat
    
    init(height: CGFloat, presentedViewController: UIViewController, presenting: UIViewController?) {
        self.height = height
        super.init(presentedViewController: presentedViewController, presenting: presenting)
    }
    override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerView = containerView else {
            return CGRect.zero
        }
        return CGRect(x: 0, y: containerView.bounds.height - self.height, width: containerView.bounds.width, height: self.height)
    }
    override func presentationTransitionWillBegin() {
        guard let containerView = containerView, let presentedView = self.presentedView else { return }
        self.bgButton.frame = containerView.frame
        containerView.setFixedView(self.bgButton)
        presentedView.layer.masksToBounds = true
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.cornerRadius = 40
    }
    @objc private func willDismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}

class PostVC: UIViewController {

    @IBOutlet weak var tvExcerpt: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnShowComment: UIButton!
    
    @IBOutlet weak var imageViewAvator: UIImageView!
    @IBOutlet weak var viewAddNewComment: UIView!
    @IBOutlet weak var viewNewComment: UIView!
    @IBOutlet weak var lbSchool: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewOption: UIStackView!
    @IBOutlet weak var tvComment: UITextView!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var btnKeep: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var _bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    //收藏文章提示視窗
    private var OKView: MessageView!
    private var OKConfig: SwiftMessages.Config!
    
    lazy private var viewCommentSetting: SettingView = {
        return UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    }()
    lazy private var viewPosterSetting: SettingView = {
        return UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    }()
    lazy private var viewBg: UIView = {
        let height = navigationController?.navigationBar.bounds.height ?? 0
        let insetTop = UIApplication.shared.windows.first!.safeAreaInsets.top
        let view = UIView(frame: CGRect(x: 0, y: height + insetTop, width: self.view.bounds.width, height: self.view.bounds.height - height - insetTop))
        view.backgroundColor = .black
        view.alpha = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        view.addGestureRecognizer(tap)
        return view
    }()
    private var card: Card {
        return ModelSingleton.shared.userCard
    }
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private let disposeBag = DisposeBag()
    private var post = Post()
    private var commentList = [Comment]()
    private var previousRect = CGRect()
    var willBeAddedListTitle = ""
    private var show: Bool = false {
        didSet {
            self.btnShowComment.setImage(UIImage(named: show ? ImageInfo.down : ImageInfo.up), for: .normal)
        }
    }
    private let beforeString = NSMutableAttributedString(string: "反應...", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    private var afterString: NSMutableAttributedString {
        let string = NSMutableAttributedString(string: self.posterSchoolString + ">\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkText])
        string.append(NSMutableAttributedString(string: "B\(self.commentList.count + 1), \(Date.getCurrentDateString(true))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        return string
    }
    private var viewModel: PostVMInterface!
    private var posterSchoolString = ""
    private var imageAvator = UIImage()
    private var willbeOpened = false {
        didSet {
            self.viewOption.isHidden = self.willbeOpened
            self.viewSeparator.isHidden = self.willbeOpened
            self.lbSchool.attributedText = self.willbeOpened ? afterString : beforeString
            _ = self.willbeOpened ? self.tvComment.becomeFirstResponder() : self.view.endEditing(true)
        }
    }
    private var posterMode: PosterMode = .school {
        didSet {
            switch posterMode {
            case .school:
                self.posterSchoolString = self.card.school
                self.imageAvator = UIImage(named: self.card.sex == "F" ? ImageInfo.pikachu : ImageInfo.carbi)!
                self.imageViewAvator.image = self.imageAvator
            case .school_department:
                self.posterSchoolString = self.card.school + " " + self.card.department
                self.imageAvator = UIImage(named: self.card.sex == "F" ? ImageInfo.pikachu : ImageInfo.carbi)!
                self.imageViewAvator.image = self.imageAvator
            case .cardName:
                self.posterSchoolString = self.card.name
            }
        }
    }
    private var schoolList: [String] {
        return [self.card.school, self.card.department, self.card.name]
    }
    private var heart = false {
        didSet {
            self.btnHeart.setImage(UIImage(systemName: self.heart ? "heart.fill" : "heart"), for: .normal)
            self.btnHeart.imageView?.tintColor = self.heart ? .systemRed : .systemGray2
        }
    }
    private var keep = false {
        didSet {
            self.btnKeep.setImage(UIImage(systemName: self.keep ? "folder.fill" : "folder"), for: .normal)
            self.btnKeep.imageView?.tintColor = self.keep ? .systemBlue : .systemGray2
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        subscribe()
        confiViewModel()
        subsribeViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        addObserverToKeyboard()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removerObserverFromKeyboard()
    }
    @IBAction func didClickBtnShowComment(_ sender: UIButton) {
        self.show = !self.show
        self.bottomSpace.constant += self.show ? 200 : -200
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func didClickBtnHeart(_ sender: UIButton) {
        self.heart = !self.heart
    }
    @IBAction func didClickBtnKeep(_ sender: UIButton) {
        if !keep {
            let vc = PostSettingVC()
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
            vc.setDelegate(self)
            vc.setContent(post: self.post, mode: .keep)
            present(vc, animated: true, completion: nil)
        }
        self.keep = !self.keep
    }
    @IBAction func didClickBtnSetting(_ sender: UIButton) {
        let vc = PostSettingVC()
        vc.modalPresentationStyle = .custom
        vc.transitioningDelegate = self
        vc.setContent(post: self.post, mode: .setting, host: self.post.host)
        present(vc, animated: true, completion: nil)
    }
    func setContent(post: Post, commentList: [Comment]) {
        self.post = post
        self.commentList = commentList
    }
}
// MARK: - SetupUI
extension PostVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.btnShowComment.isHidden = self.commentList.isEmpty
        self.btnSetting.imageView?.tintColor = self.post.host ? .systemBlue : .systemGray2
        self.navigationItem.title = self.post.title
        self.heart = false
        self.keep = false
        self.posterMode = .school
        confiTextFieldView()
        confiTableView()
        confiView()
        confiOKView()
    }
    private func confiTextFieldView() {
        self.tvExcerpt.isEditable = false
        self.tvExcerpt.text = self.post.excerpt
        self.tvComment.delegate = self
        self.tvComment.text = "回應..."                                         
        self.tvComment.textColor = .lightGray
        self.tvComment.addRightButtonOnKeyboardWithText("取消", target: self, action: #selector(cancel), titleText: nil)
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    private func confiView() {
        self.imageViewAvator.layer.cornerRadius = 20
        let tap = UITapGestureRecognizer(target: self, action: #selector(addNewComment))
        self.viewAddNewComment.addGestureRecognizer(tap)
        self.willbeOpened = false
    }
    private func confiOKView() {
        self.OKView = MessageView.viewFromNib(layout: .cardView)
        self.OKView.id = "success"
        self.OKView.configureTheme(backgroundColor: .darkGray, foregroundColor: .white)
        self.OKView.button?.setTitle("查看收藏", for: .normal)
        self.OKView.button?.setTitleColor(.link, for: .normal)
        self.OKView.button?.backgroundColor = .clear
        
        self.OKConfig = SwiftMessages.Config()
        self.OKConfig.presentationContext = .window(windowLevel: .normal)
        self.OKConfig.presentationStyle = .bottom
    }
}
// MARK: - SubscribeViewModel
extension PostVC {
    private func confiViewModel() {
        self.viewModel = PostVM()
    }
    private func subsribeViewModel() {
        self.viewModel.ccreartFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result {
                self.showOKView()
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - Private Handler
extension PostVC {
    @objc private func close() {
        self.viewBg.removeFromSuperview()
        self.viewCommentSetting.removeFromSuperview()
        self.viewPosterSetting.removeFromSuperview()
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
    }
    @objc private func cancel() {
        self.willbeOpened = false
    }
    @objc private func send() {
        //沒任何留言隱藏開啟留言圖示，發出新留言則顯示
        if self.btnShowComment.isHidden {
            self.btnShowComment.isHidden = false
        }
        self.viewHeight.constant = 150
        self.view.layoutIfNeeded()
        self.commentList.append(Comment(id: self.card.id, anonymous: true, content: self.tvComment.text, createdAt: "2020/05/05", floor: self.commentList.count + 1, likeCount: 0, gender: self.card.sex, department: self.card.department, school: self.card.school, withNickname: true, host: false, mediaMeta: []))
        self.tableView.reloadData()
        self.willbeOpened = false
    }
    @objc private func addNewComment() {
        if !self.willbeOpened {
            self.willbeOpened = true
        } else {
            IQKeyboardManager.shared.shouldResignOnTouchOutside = false
            self.viewPosterSetting.setContent(mode: .posterSetting)
            self.viewPosterSetting.setDelegate(self)
            let location = self.imageViewAvator.convert(CGPoint(x: self.imageViewAvator.frame.maxX, y: self.imageViewAvator.frame.minY), to: self.view)
            self.viewPosterSetting.frame = CGRect(x: location.x + 10, y: location.y - 40, width: 200, height: 90)
            self.view.addSubview(self.viewBg)
            self.view.addSubview(self.viewPosterSetting)
        }
    }
    private func showOKView() {
        self.OKConfig.duration = .seconds(seconds: 1.5)
        self.OKView.configureContent(title: "", body: "已分類至" + "『\(self.willBeAddedListTitle)』")
        SwiftMessages.show(config: self.OKConfig, view: self.OKView)
    }
}
// MARK: - SubscribeRX
extension PostVC {
    private func subscribe() {
        let isValid = self.tvComment.rx.text.orEmpty.map { return $0.count > 0 }
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
        self.willbeOpened = false
        self._bottomSpace.constant = -100
        self.view.layoutIfNeeded()
    }
}
// MARK: - UITableViewDelegate
extension PostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableView ? commentList.count : self.schoolList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if tableView === self.tableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
            cell.selectionStyle = .none
            cell.setContent(comment: commentList[indexPath.row], view: view)
            cell.setDelegate(self)
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            cell.textLabel?.text = self.schoolList[row]
            if row == 2 {
                cell.imageView?.kf.setImage(with: URL(string: ModelSingleton.shared.userConfig.user.avatar))
            } else {
                cell.imageView?.image = imageAvator
            }
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView === self.tableView ? 200 : 30
    }
}
// MARK: - showSettingViewDelegate
extension PostVC: showSettingViewDelegate {
    func showView(location: CGPoint, floor: Int) {
        self.viewCommentSetting.setContent(mode: .commentSetting, floor: floor)
        self.viewCommentSetting.frame = CGRect(x: location.x - 150, y: location.y - 80, width: 150, height: 80)
        
        self.view.addSubview(self.viewBg)
        self.view.addSubview(self.viewCommentSetting)
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
// MARK: - UIPopoverPresentationControllerDelegate
extension PostVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
// MARK: - SettingViewDelegate
extension PostVC: SettingViewDelegate {
    func changePoster(_ mode: PosterMode) {
        self.posterMode = mode
        self.lbSchool.attributedText = self.afterString
        if mode != .cardName {
            self.imageViewAvator.image = imageAvator
        } else {
            self.imageViewAvator.kf.setImage(with: URL(string: self.user.avatar))
        }
        close()
    }
}
// MARK: - UIViewControllerTransitioningDelegate
extension PostVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(height: 450, presentedViewController: presented, presenting: presenting )
    }
}
// MARK: - PostSettingCellDelegate
extension PostVC: PostSettingCellDelegate {
    func showAddFavoriteListOKView(title: String) {
        self.viewModel.creartFavoriteList(listName: title, post: self.post)
    }
}
