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

class PresentationController : UIPresentationController {
    
    lazy private var buttonBG: UIButton = self.confiButtonBG()
    
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
        containerView.setFixedView(self.buttonBG)
        presentedView.layer.masksToBounds = true
        presentedView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        presentedView.layer.cornerRadius = 40
    }
    @objc private func willDismiss() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
    private func confiButtonBG() -> UIButton {
        let button = UIButton()
        button.backgroundColor = .black
        button.alpha = 0.8
        button.addTarget(self, action: #selector(self.willDismiss), for: .touchUpInside)
        return button
    }
}

class PostVC: UIViewController {

    @IBOutlet weak var tvExcerpt: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnShowComment: UIButton!
    @IBOutlet weak var tvComment: UITextView!
    
    @IBOutlet weak var imageViewAvator: UIImageView!
    @IBOutlet weak var viewAddNewComment: UIView!
    @IBOutlet weak var viewNewComment: UIView!
    @IBOutlet weak var lbSchool: UILabel!
    @IBOutlet weak var viewSeparator: UIView!
    @IBOutlet weak var viewOption: UIStackView!
    @IBOutlet weak var btnHeart: UIButton!
    @IBOutlet weak var btnKeep: UIButton!
    @IBOutlet weak var btnSetting: UIButton!
    
    @IBOutlet weak var bottomSpace: NSLayoutConstraint! //留言顯示
    @IBOutlet weak var _bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewHeight: NSLayoutConstraint!
    
    
    
    //留言編輯視窗
    lazy private var viewCommentSetting: SettingView = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    lazy private var viewPosterSetting: SettingView = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    lazy private var viewBg: UIView = self.confiViewBG()
    
    private var card: Card = ModelSingleton.shared.userCard
    private var schoolList: [String] {
        return [self.card.school, self.card.department, self.card.name]
    }
    
    private let disposeBag = DisposeBag()
    private var post = Post()
    private var commentList = [Comment]()
    private var previousRect = CGRect()
    private var willBeAddedList: Favorite?
    private var show: Bool = false {
        didSet {
            self.btnShowComment.setImage(UIImage(named: !self.show ? ImageInfo.arrow_hide : ImageInfo.arrow_show), for: .normal)
        }
    }
    private let beforeString = NSMutableAttributedString(string: "反應...", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
    private var afterString: NSMutableAttributedString {
        let string = NSMutableAttributedString(string: self.posterSchoolString + ">\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.darkText])
        string.append(NSMutableAttributedString(string: "B\(self.commentList.count + 1), \(Date.getCurrentDateString(true))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14, weight: .light), NSAttributedString.Key.foregroundColor: UIColor.lightGray]))
        return string
    }
    private var willbeOpened = false {
        didSet {
            self.viewOption.isHidden = self.willbeOpened
            self.viewSeparator.isHidden = self.willbeOpened
            self.lbSchool.attributedText = self.willbeOpened ? afterString : beforeString
            _ = self.willbeOpened ? self.tvComment.becomeFirstResponder() : self.view.endEditing(true)
        }
    }
    
    private var viewModel: PostVMInterface!
    private var posterSchoolString = ""

    private var emotion: Mood.EmotionType? = nil {
        didSet {
            guard let emotion = emotion else {
                self.btnHeart.setTitle("🤍", for: .normal)
                return
            }
            self.btnHeart.setTitle(emotion.imageText, for: .normal)
        }
    }
//    private
    
    private var imageAvator = UIImage()
    
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
    }
    @IBAction func didClickBtnShowComment(_ sender: UIButton) {
        self.show = !self.show
        self.bottomSpace.constant += self.show ? 200 : -200
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    @IBAction func didClickBtnKeep(_ sender: UIButton) {
        if !keep {
            let postSettingVC = PostSettingVC()
            postSettingVC.modalPresentationStyle = .custom
            postSettingVC.transitioningDelegate = self
            postSettingVC.setDelegate(self)
            postSettingVC.setContent(post: self.post, mode: .keep)
            present(postSettingVC, animated: true, completion: nil)
        } else {
            self.viewModel.removePostFromFavoriteList(postID: self.post.id)
        }
    }
    @IBAction func didClickBtnSetting(_ sender: UIButton) {
        let postSettingVC = PostSettingVC()
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = self
        postSettingVC.setContent(post: self.post, mode: .setting, host: self.post.host)
        present(postSettingVC, animated: true, completion: nil)
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
        self.navigationItem.title = self.post.title
        confiTextView()
        confiTableView()
        confiView()
        confiButton()
        
        setupData()
    }
    private func setupData() {
        self.tvExcerpt.text = self.post.excerpt
        self.willbeOpened = false
        self.btnShowComment.isHidden = self.commentList.isEmpty
        self.btnSetting.imageView?.tintColor = (self.post.host == ModelSingleton.shared.userConfig.user.uid) ? .systemBlue : .systemGray2
        self.keep = ModelSingleton.shared.allFavoritePostID.contains(self.post.id)
        self.posterMode = .school
        searchWhichEmotion()
    }
    private func confiTextView() {
        self.tvExcerpt.isEditable = false
        self.tvComment.delegate = self
        self.tvComment.text = "回應..."                                         
        self.tvComment.textColor = .lightGray
        self.tvComment.addRightButtonOnKeyboardWithText("取消", target: self, action: #selector(cancel), titleText: nil)
    }
    private func confiButton() {
        let longpress = UILongPressGestureRecognizer(target: self, action: #selector(showEmotionView))
        longpress.minimumPressDuration = 1
        self.btnHeart.addGestureRecognizer(longpress)
        
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(changeHeart))
        self.btnHeart.addGestureRecognizer(tap)
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
    }
    private func confiView() {
        self.imageViewAvator.layer.cornerRadius = 20
        let tap = UITapGestureRecognizer(target: self, action: #selector(addNewComment))
        self.viewAddNewComment.addGestureRecognizer(tap)
    }
    
    private func confiViewBG() -> UIView {
        let height = navigationController?.navigationBar.bounds.height ?? 0
        let insetTop = UIApplication.shared.windows.first!.safeAreaInsets.top
        let view = UIView(frame: CGRect(x: 0, y: height + insetTop, width: self.view.bounds.width, height: self.view.bounds.height - height - insetTop))
        view.backgroundColor = .black
        view.alpha = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.close))
        view.addGestureRecognizer(tap)
        return view
    }
    private func confiEmotionVC() -> UIViewController {
        let vc: UIViewController = UIViewController()
        vc.view.layer.cornerRadius = 15
        vc.view.backgroundColor = .white
        let btnList: [UIButton] = Mood.EmotionType.allCases.enumerated().map { (key, mode) -> UIButton in
            let btn: UIButton = UIButton(type: .system)
            btn.tag = key
            btn.addTarget(self, action: #selector(selectEmotion), for: .touchUpInside)
            btn.setAttributedTitle(NSAttributedString(string: mode.imageText, attributes: [.font: UIFont.systemFont(ofSize: 30)]), for: .normal)
            return btn
        }
        let stv: UIStackView = UIStackView(arrangedSubviews: btnList)
        stv.translatesAutoresizingMaskIntoConstraints = false
        stv.distribution = .fillEqually
        stv.alignment = .fill
        stv.axis = .horizontal
        vc.view.addSubview(stv)
        stv.snp.makeConstraints { (maker) in
            maker.leading.trailing.top.equalToSuperview()
            maker.height.equalTo(50)
        }
        return vc
    }
}
// MARK: - SubscribeViewModel
extension PostVC {
    private func confiViewModel() {
        self.viewModel = PostVM()
    }
    private func subsribeViewModel() {
        self.viewModel.addFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                self.keep = !self.keep
                self.dismiss(animated: true) {
                    if let willBeAddedListTitle = self.willBeAddedList?.title {
                        AlertManager.shared.showHintView(target: self, body: "已分類至" + "『\(willBeAddedListTitle)』", willBeAddedListTitle: willBeAddedListTitle)
                        self.willBeAddedList = nil
                    } else {
                        AlertManager.shared.showHintView(target: self, body: "文章已收藏。", willBeAddedListTitle: nil)
                    }
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        self.viewModel.createFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                if let sender = result.sender, let favorite = sender["new"] as? Favorite {
                    self.viewModel.addFavoriteList(listName: favorite.title, post: [(self.post.id, !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")])
                    self.willBeAddedList = favorite
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.removePostFromFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                self.keep = !self.keep
                AlertManager.shared.showOKView(mode: .favorite(.removePost), handler: nil)
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.addMoodSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                if let sender = result.sender, let data = sender["emotion"] as? Mood.EmotionType {
                    self.emotion = data
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.removeMoodSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                self.emotion = nil
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - Business Logic
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
    @objc private func changeHeart() {
        guard let emotion = self.emotion else {
            self.viewModel.addMood(emotion: .heart, postID: self.post.id)
            return
        }
        self.viewModel.removeMood(emotion: emotion, postID: self.post.id)
    }
    @objc private func showEmotionView() {
        let vc = self.confiEmotionVC()
        vc.modalPresentationStyle = .popover
        vc.preferredContentSize = CGSize(width: self.view.bounds.width * 2 / 3, height: 60)
        vc.popoverPresentationController?.delegate = self
        vc.popoverPresentationController?.sourceView = self.btnHeart
        self.present(vc, animated: true, completion: nil)
    }
    @objc private func selectEmotion(_ sender: UIButton) {
        if let emotion = self.emotion {
            self.viewModel.removeMood(emotion: emotion, postID: self.post.id)
        } else {
            
        }
        self.emotion = Mood.EmotionType.allCases[sender.tag]
        self.viewModel.addMood(emotion: self.emotion!, postID: self.post.id)
    }
    private func searchWhichEmotion() {
        let mood = ModelSingleton.shared.mood
        switch self.post.id {
        case _ where mood.heart.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.heart.imageText, for: .normal)
            self.emotion = .heart
        case _ where mood.angry.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.angry.imageText, for: .normal)
            self.emotion = .angry
        case _ where mood.haha.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.haha.imageText, for: .normal)
            self.emotion = .haha
        case _ where mood.cry.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.cry.imageText, for: .normal)
            self.emotion = .cry
        case _ where mood.respect.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.respect.imageText, for: .normal)
            self.emotion = .respect
        case _ where mood.surprise.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.surprise.imageText, for: .normal)
            self.emotion = .surprise
        default:
            self.emotion = nil
        }
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
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillShowNotification).observeOn(MainScheduler.instance).subscribe { (_) in
            self._bottomSpace.constant = 0
            self.view.layoutIfNeeded()
        }.disposed(by: self.disposeBag)
        
        NotificationCenter.default.rx.notification(UIResponder.keyboardWillHideNotification).observeOn(MainScheduler.instance).subscribe { (_) in
            self.willbeOpened = false
            self._bottomSpace.constant = -100
            self.view.layoutIfNeeded()
        }.disposed(by: self.disposeBag)
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
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
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
        if self.previousRect != CGRect.zero && willBeExtend {
            self.viewHeight.constant += 20
            if currentRect.origin.y > self.previousRect.origin.y {
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
            self.imageViewAvator.kf.setImage(with: URL(string: ModelSingleton.shared.userConfig.user.avatar))
        }
        close()
    }
}

// MARK: - UIViewControllerTransitioningDelegate
extension PostVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(height:  self.view.bounds.height * 1 / 2, presentedViewController: presented, presenting: presenting )
    }
}
// MARK: - PostSettingCellDelegate
extension PostVC: PostSettingVCDelegate {
    func showAddFavoriteListOKView(favorite: Favorite) {
        self.willBeAddedList = favorite
        self.viewModel.addFavoriteList(listName: favorite.title, post: [(self.post.id, !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")])
    }
    func createFavoriteListAndInsert(title: String) {
        self.viewModel.createFavoriteList(listName: title)
    }
    func addNotSorted() {
        self.viewModel.addFavoriteList(listName: "", post: [(self.post.id, !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")])

    }
}
