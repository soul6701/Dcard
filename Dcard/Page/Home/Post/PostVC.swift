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
    
    lazy private var viewCommentSetting: SettingView = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    lazy private var viewPosterSetting: SettingView = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! SettingView
    lazy private var viewBg: UIView = self.confiViewBG()
    lazy private var emotionVC: UIViewController = self.confiEmotionVC()
    
    private var card: Card = ModelSingleton.shared.userCard
    private var user: User = ModelSingleton.shared.userConfig.user
    private let disposeBag = DisposeBag()
    private var post = Post()
    private var commentList = [Comment]()
    private var previousRect = CGRect()
    private var willBeAddedList: Favorite?
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
    private var mood: Mood {
        return ModelSingleton.shared.mood
    }
    private var emotion: Mood.EmotionType? = nil {
        didSet {
            guard let emotion = emotion else {
                self.btnHeart.setTitle("🤍", for: .normal)
                return
            }
            switch emotion {
            case _ where self.mood.heart.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.heart.imageText, for: .normal)
            case _ where self.mood.angry.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.angry.imageText, for: .normal)
            case _ where self.mood.haha.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.haha.imageText, for: .normal)
            case _ where self.mood.cry.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.cry.imageText, for: .normal)
            case _ where self.mood.respect.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.respect.imageText, for: .normal)
            case _ where self.mood.surprise.contains(self.post.id):
                self.btnHeart.setTitle(Mood.EmotionType.surprise.imageText, for: .normal)
            default:
                break
            }
        }
    }
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
    private var keep = false {
        didSet {
            self.btnKeep.setImage(UIImage(systemName: self.keep ? "folder.fill" : "folder"), for: .normal)
            self.btnKeep.imageView?.tintColor = self.keep ? .systemBlue : .systemGray2
        }
    }
    private var postSettingVC: PostSettingVC?
    
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
        guard let emotion = self.emotion else {
            self.viewModel.addMood(emotion: .heart, postID: self.post.id)
            return
        }
        self.viewModel.removeMood(emotion: emotion, postID: self.post.id)
    }
    @IBAction func didClickBtnKeep(_ sender: UIButton) {
        if !keep {
            self.postSettingVC = PostSettingVC()
            guard let postSettingVC = self.postSettingVC else { return }
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
        self.postSettingVC = PostSettingVC()
        guard let postSettingVC = self.postSettingVC else { return }
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
        self.btnShowComment.isHidden = self.commentList.isEmpty
        self.btnSetting.imageView?.tintColor = (self.post.host == self.user.uid) ? .systemBlue : .systemGray2
        self.navigationItem.title = self.post.title
        self.keep = ModelSingleton.shared.allFavoritePostID.contains(self.post.id)
        self.posterMode = .school
        searchWhichEmotion()
        confiTextFieldView()
        confiTableView()
        confiView()
        confiOKView()
        confiBtnHeart()
    }
    private func confiTextFieldView() {
        self.tvExcerpt.isEditable = false
        self.tvExcerpt.text = self.post.excerpt
        self.tvComment.delegate = self
        self.tvComment.text = "回應..."                                         
        self.tvComment.textColor = .lightGray
        self.tvComment.addRightButtonOnKeyboardWithText("取消", target: self, action: #selector(cancel), titleText: nil)
    }
    private func confiBtnHeart() {
        let longPress: UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(showEmotionView))
        longPress.minimumPressDuration = 1
        self.btnHeart.addGestureRecognizer(longPress)
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
        self.OKView.buttonTapHandler = { (button) in
            guard let willBeAddedList = self.willBeAddedList?.title else {
                let vc = FavoriteInfoVC()
                var allPostIDList: [String] = []
                ModelSingleton.shared.favorite.map { return $0.postIDList }.forEach { (postIDList) in
                    allPostIDList += postIDList
                }
                var list = [String]()
                for favorite in ModelSingleton.shared.favorite {
                    if let first = favorite.coverImage.first(where: { return !$0.isEmpty }) {
                        list.append(first)
                        if list.count >= 4 { break }
                    }
                }
                vc.setContent(.all, title: "全部收藏", postIDList: allPostIDList, imageStrings: list)
                self.navigationController?.pushViewController(vc, animated: true)
                return
            }
            if let favorite = ModelSingleton.shared.favorite.first(where: { return $0.title == willBeAddedList }) {
                SwiftMessages.hide(id: "success")
                let vc = FavoriteInfoVC()
                let mediaMetas = favorite.coverImage.first { return !$0.isEmpty }
                vc.setContent(.other, title: favorite.title, postIDList: favorite.postIDList, imageStrings: [mediaMetas ?? ""])
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        self.OKConfig = SwiftMessages.Config()
        self.OKConfig.presentationContext = .window(windowLevel: .normal)
        self.OKConfig.presentationStyle = .bottom
        self.OKConfig.duration = .seconds(seconds: 2)
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
                    if let willBeAddedList = self.willBeAddedList {
                        self.OKView.configureContent(title: "", body: "已分類至" + "『\(willBeAddedList.title)』")
                        self.willBeAddedList = nil
                    } else {
                        self.OKView.configureContent(title: "", body: "文章已收藏。")
                    }
                    SwiftMessages.show(config: self.OKConfig, view: self.OKView)
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        self.viewModel.createFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                if let sender = result.sender, let favorite = sender["new"] as? Favorite {
                    self.viewModel.addFavoriteList(listName: favorite.title, postID: self.post.id, coverImage: !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")
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
    @objc private func showEmotionView() {
        self.emotionVC.modalPresentationStyle = .popover
        self.emotionVC.preferredContentSize = CGSize(width: 200, height: 50)
        self.emotionVC.popoverPresentationController?.delegate = self
        self.emotionVC.popoverPresentationController?.sourceView = self.btnHeart
        present(self.emotionVC, animated: true, completion: nil)
    }
    @objc private func selectEmotion(_ sender: UIButton) {
        self.emotion = Mood.EmotionType.allCases[sender.tag]
        self.viewModel.addMood(emotion: self.emotion!, postID: self.post.id)
    }
    private func searchWhichEmotion() {
        switch self.post.id {
        case _ where self.mood.heart.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.heart.imageText, for: .normal)
            self.emotion = .heart
        case _ where self.mood.angry.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.angry.imageText, for: .normal)
            self.emotion = .angry
        case _ where self.mood.haha.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.haha.imageText, for: .normal)
            self.emotion = .haha
        case _ where self.mood.cry.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.cry.imageText, for: .normal)
            self.emotion = .cry
        case _ where self.mood.respect.contains(self.post.id):
            self.btnHeart.setTitle(Mood.EmotionType.respect.imageText, for: .normal)
            self.emotion = .respect
        case _ where self.mood.surprise.contains(self.post.id):
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
extension PostVC: PostSettingVCDelegate {
    func showAddFavoriteListOKView(favorite: Favorite) {
        self.willBeAddedList = favorite
        self.viewModel.addFavoriteList(listName: favorite.title, postID: self.post.id, coverImage: !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")
    }
    func createFavoriteListAndInsert(title: String) {
        self.viewModel.createFavoriteList(listName: title)
    }
    func addNotSorted() {
        self.viewModel.addFavoriteList(listName: "", postID: self.post.id, coverImage: !self.post.mediaMeta.isEmpty ? self.post.mediaMeta[0].thumbnail : "")
    }
}
