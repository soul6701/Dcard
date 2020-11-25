//
//  FavoriteInfoVC.swift
//  Dcard
//
//  Created by Mason on 2020/10/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa




class FavoriteInfoVC: UIViewController {
    enum FavoriteInfoMode {
        case all
        case other
    }
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var heightRelative: NSLayoutConstraint!
    //標題視窗
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var viewContainertwo: UIView!
    @IBOutlet weak var btnCatalog: UIButton!
    @IBOutlet weak var btnForumFilter: UIButton!
    //封面視窗
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet var imageViewList: [UIImageView]!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var btnEdit: UIButton!
    
    @IBOutlet weak var btnAddPost: customButton!
    private var viewModel: PostVMInterface!
    private let disposeBag = DisposeBag()
    private var mode: FavoriteInfoMode = .all
    private var catalogSelected: Bool = false
    private var selectedForumNameList: [String]?
    private var postIDList: [String] {
        return self.favorite.postIDList
    }
    private var postList: [Post] = [] //全部貼文
    private var favorite: Favorite = Favorite()
    private var titleFavorite: String {
        return self.favorite.title
    }
    private var newTitleFavorite: String = ""
    private var selectedPost: Post = Post()
    private var willBeAddedPostList: [Int] = [] {
        didSet {
            if self.willBeAddedPostList.isEmpty {
                self.btnAddPost.isEnabled = false
                self.btnAddPost.backgroundColor = .systemGray3
            } else {
                self.btnAddPost.isEnabled = true
                self.btnAddPost.backgroundColor = .link
                self.btnAddPost.setTitle("加入 \(self.willBeAddedPostList.count) 篇文章", for: .normal)
            }
        }
    }
    private var allpostList: [Post]? //全部貼文包含其他收藏及未分類
    
    private var filteredPostList = [Post]() { //過濾後貼文
        didSet {
            self.tableView.reloadData()
        }
    }
    private var notSortedIDList: [String] {
        return ModelSingleton.shared.favorite.first(where: { return $0.title.isEmpty })?.postIDList ?? []
    }
    private var notSortedPostList: [Post] { //未分類貼文
        return self.filteredPostList.filter { self.notSortedIDList.contains($0.id) }
    }
    private var mainPostIDList: [String] {
        if self.mode == .all {
            let allPostIDlist = self.notSortedIDList + self.postIDList
            return allPostIDlist.reduce([String]()) { (result, id) -> [String] in
                if !result.contains(id) {
                    var list = result
                    list.append(id)
                    return list
                }
                return result
            }
        } else {
            return self.postIDList
        }
    }
    private var imageStrings: [String] = []
    private var willbeDeletedID: String = ""
    private var willBeAddedList: Favorite?
    private var willShow = false // 新增文章
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subsribeViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func edit(_ sender: UIButton) {
        OptionView.shared.show(self, mode: .editFavorite)
    }
    @IBAction func didClickBtnSelect(_ sender: UIButton) {
        if self.mode == .all {
            self.resetButtonState()
        } else {
            self.showAddPostView()
        }
    }
    @IBAction func didClickBtnCatalog(_ sender: UIButton) {
        if !self.catalogSelected {
            let view = UIView()
            view.translatesAutoresizingMaskIntoConstraints = false
            view.backgroundColor = .link
            guard let imageView = self.btnCatalog.imageView else { return }
            imageView.addSubview(view)
            view.snp.makeConstraints { (maker) in
                maker.center.equalToSuperview()
                maker.height.equalTo(imageView.bounds.height * 1.8 / 3)
                maker.width.equalTo(imageView.bounds.height * 1.8 / 3)
            }
            self.filteredPostList = self.notSortedPostList
        } else {
            self.btnCatalog.imageView?.subviews.last?.removeFromSuperview()
            if let selectedForumNameList = self.selectedForumNameList {
                self.filteredPostList = self.postList.filter { return selectedForumNameList.contains($0.forumName) }
            } else {
                self.filteredPostList = self.postList
            }
        }
        self.catalogSelected = !self.catalogSelected
        self.btnSelect.alpha = 0
        self.tableView.alpha = 0
        UIView.animate(withDuration: 1) {
            self.btnSelect.alpha = 1
            self.tableView.alpha = 1
        }
    }
    @IBAction func didClickBtnForumFilter(_ sender: UIButton) {
        let vc = FavoriteForumVC()
        vc.setDelegate(self)
        vc.setContent(selectedForumNameList: self.selectedForumNameList ?? [])
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        nav.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    @IBAction func addPost(_ sender: customButton) {
        let postSettingVC = PostSettingVC()
        postSettingVC.modalPresentationStyle = .custom
        postSettingVC.transitioningDelegate = self
        postSettingVC.setDelegate(self)
        postSettingVC.setContent(mode: .keep)
        present(postSettingVC, animated: true, completion: nil)
    }
    func setContent(_ mode: FavoriteInfoMode, favorite: Favorite) {
        self.mode = mode
        self.favorite = favorite
        self.imageStrings = favorite.coverImage
    }
}
// MARK: - SetupUI
extension FavoriteInfoVC {
    private func initView() {
        confiTableView()
        confiTitleView()
        confiContainerView()
        confiButton()
        
        self.heightRelative.constant = self.mode == .all ? 300 : 260
    }
    private func confiTableView() {
        let isAll = self.mode == .all
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableView.contentInset = UIEdgeInsets(top: isAll ? 300 : 260 , left: 0, bottom: 0, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: isAll ? 300 : 260 , left: 0, bottom: 0, right: 0)
        self.tableView.allowsMultipleSelectionDuringEditing = true
    }
    private func confiTitleView() {
        self.viewContainertwo.isHidden = self.mode == .other
        self.lbTitle.text = self.titleFavorite
        self.btnSelect.setTitle(self.mode == .all ? "選取" : "新增文章", for: .normal)
    }
    private func confiButton() {
        self.btnEdit.isHidden = self.mode == .all
        self.btnAddPost.setTitle("加入 ０ 篇文章", for: .disabled)
        self.btnAddPost.setTitleColor(.white, for: .normal)
        self.willBeAddedPostList = []
    }
    private func confiContainerView() {
        if self.mode == .all {
            zip(self.imageStrings, self.imageViewList).forEach { (urlString, imageView) in
                imageView.kf.setImage(with: URL(string: urlString))
            }
        } else {
            self.stackView.isHidden = true
            self.imageViewList[1].isHidden = true
            if let firstMediaMeta = self.imageStrings.first {
                self.imageViewList[0].kf.setImage(with: URL(string: firstMediaMeta))
            }
        }
    }
}
// MARK: - Private Handler
extension FavoriteInfoVC {
    private func resetButtonState() {
        self.btnSelect.setTitle(self.btnForumFilter.isEnabled ? "完成" : "選取", for: .normal)
        self.btnCatalog.isEnabled = !self.btnCatalog.isEnabled
        self.btnForumFilter.isEnabled = !self.btnForumFilter.isEnabled
        
        self.btnAddPost.isHidden = self.tableView.isEditing
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    private func showAddPostView() {
        if let allpostList = self.allpostList {
            let vc = NewPostTableViewController(postList: allpostList, self)
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .overCurrentContext
            self.present(nav, animated: true, completion: {
                nav.navigationBar.tintColor = .systemGray
                nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
            })
        } else {
            self.willShow = true
            var allPostIDList: [String] = []
            ModelSingleton.shared.favorite.map { return $0.postIDList }.forEach { (postIDList) in
               allPostIDList += postIDList
           }
            self.viewModel.getPostInfoOfList(postIDs: allPostIDList)
        }
    }
}
// MARK: - ConfigureViewModel
extension FavoriteInfoVC {
    private func confiViewModel() {
        self.viewModel = PostVM()
    }
    private func subsribeViewModel() {
        self.viewModel.getPostInfoOfListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            guard !self.willShow else {
                var allPostIDList: [String] = []
                ModelSingleton.shared.favorite.map { return $0.postIDList }.forEach { (postIDList) in
                   allPostIDList += postIDList
               }
                guard allPostIDList.count == result.data.count else { return }
                self.allpostList = result.data
                let vc = NewPostTableViewController(postList: result.data, self)
                let nav = UINavigationController(rootViewController: vc)
                nav.modalPresentationStyle = .overCurrentContext
                self.present(nav, animated: true, completion: {
                    nav.navigationBar.tintColor = .systemGray
                    nav.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.black]
                })
                self.willShow = false
                return
            }
            guard self.mainPostIDList.count == result.data.count else { return }
            self.postList = result.data
            self.filteredPostList = result.data
            if self.mode != .all {
                self.imageStrings = [self.postList.first { return !$0.mediaMeta.isEmpty }?.mediaMeta.first?.thumbnail ?? ""]
                self.confiContainerView()
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        self.viewModel.removeFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                AlertManager.shared.showOKView(mode: .favorite(.remove), handler: nil)
                self.navigationController?.popViewController(animated: true)
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.updateFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                AlertManager.shared.showOKView(mode: .favorite(.update), handler: nil)
                self.lbTitle.text = self.newTitleFavorite
            } else {
                self.newTitleFavorite = ""
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.removePostFromFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                AlertManager.shared.showOKView(mode: .favorite(.removePost), handler: nil)
                self.viewModel.getPostInfoOfList(postIDs: self.mainPostIDList.filter( { return $0 != self.willbeDeletedID}))
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        self.viewModel.createFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                if let sender = result.sender, let favorite = sender["new"] as? Favorite {
                    let postList: [(String, String)] = self.willBeAddedPostList.map { (index) -> (String, String) in
                        let mediaMetaArray = self.filteredPostList[index].mediaMeta
                        return (self.filteredPostList[index].id, !mediaMetaArray.isEmpty ? mediaMetaArray[0].thumbnail : "")
                    }
                    self.viewModel.addFavoriteList(listName: favorite.title, post: postList)
                    self.willBeAddedList = favorite
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        self.viewModel.addFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                self.dismiss(animated: true) {
                    if let willBeAddedListTitle = self.willBeAddedList?.title {
                        AlertManager.shared.showHintView(target: self, body: "已分類至" + "『\(willBeAddedListTitle)』", willBeAddedListTitle: willBeAddedListTitle)
                        self.willBeAddedList = nil
                    } else {
                        AlertManager.shared.showHintView(target: self, body: "文章已收藏。", willBeAddedListTitle: nil)
                    }
                    if self.mode == .all {
                        self.resetButtonState()
                    }
                }
            }
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.viewModel.getPostInfoOfList(postIDs: self.mainPostIDList)
    }
}
// MARK: - UITableViewDelegate
extension FavoriteInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.filteredPostList.count : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.setContent(post: self.filteredPostList[row], mode: .favorite)
            cell.setDelegate(self)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) //隱藏分隔線
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 180
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let post = self.filteredPostList[row]
        guard !tableView.isEditing else {
            var newList = self.willBeAddedPostList
            newList.append(row)
            self.willBeAddedPostList = newList
            return
        }
        let vc = UIStoryboard.home.postVC
        var commonList = [Comment]()
        let random = (0...100).randomElement()!
        (0...random).forEach { (_) in
            commonList.append(Comment())
        }
        vc.setContent(post: post, commentList: commonList)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        guard !tableView.isEditing else {
            self.willBeAddedPostList = self.willBeAddedPostList.filter( { $0 != row })
            return
        }
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        return tableView.isEditing && section == 0
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        self.topSpace.constant = yOffset + (self.mode == .all ? 300 : 260)
        self.view.layoutIfNeeded()
    }
}
// MARK: - FavoriteForumVCDelegate
extension FavoriteInfoVC: FavoriteForumVCDelegate {
    func filterForum(selectedForumNameList: [String]) {
        guard !selectedForumNameList.isEmpty else {
            self.filteredPostList = self.postList
            self.selectedForumNameList = nil
            self.btnForumFilter.setTitle("看板篩選", for: .normal)
            self.btnForumFilter.setTitleColor(.darkGray, for: .normal)
            self.btnForumFilter.imageView?.isHidden = false
            return
        }
        self.selectedForumNameList = selectedForumNameList
        self.btnForumFilter.setTitle("看板篩選·\(selectedForumNameList.count)", for: .normal)
        self.btnForumFilter.setTitleColor(#colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78), for: .normal)
        self.filteredPostList = self.filteredPostList.filter { return selectedForumNameList.contains($0.forumName) }
    }
}
// MARK: - PostCellDelegate
extension FavoriteInfoVC: PostCellDelegate {
    func edit(post: Post) {
        self.selectedPost = post
        OptionView.shared.show(self, mode: .editPost)
    }
}
// MARK: - OptionViewDelegate
extension FavoriteInfoVC: OptionViewDelegate {
    func didClickAt(_ mode: OptionView.Mode, indexPath: IndexPath) {
        let row = indexPath.row
        if mode == .editFavorite {
            if row == 0 {
                self.viewModel.removeFavoriteList(listName: self.titleFavorite)
            } else {
                var tfName: UITextField!
                let alert = UIAlertController(title: "請輸入新名字😄", message: "", preferredStyle: .alert)
                alert.addTextField { (tf) in
                    tf.clearButtonMode = .whileEditing
                    tfName = tf
                }
                let OKAction = UIAlertAction(title: "確認", style: .default) { (action) in
                    self.newTitleFavorite = tfName.text ?? ""
                    self.viewModel.updateFavoriteList(oldListName: self.titleFavorite, newListName: self.newTitleFavorite)
                }
                let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
                tfName.rx.text.orEmpty.map { !$0.isEmpty }.bind(to: OKAction.rx.isEnabled).disposed(by: self.disposeBag)
                alert.addAction(OKAction)
                alert.addAction(cancelAction)
                present(alert, animated: true)
            }
        } else {
            switch row {
            case 0:
                let vc = UIActivityViewController(activityItems: [self.selectedPost.title], applicationActivities: nil)
                vc.completionWithItemsHandler = { (_, completed, _, error) in
                    if let error = error {
                        AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
                    }
                    if completed {
                        AlertManager.shared.showOKView(mode: .profile(.shareCardInfoAndIssueInfo), handler: nil)
                    }
                }
                present(vc, animated: true)
            case 1:
                break
            case 2:
                break
            case 3:
                break
            default:
                break
            }
        }
    }
}
// MARK: - UIPopoverPresentationControllerDelegate
extension FavoriteInfoVC: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
// MARK: - UIViewControllerTransitioningDelegate
extension FavoriteInfoVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        return PresentationController(height:  self.view.bounds.height * 1 / 2, presentedViewController: presented, presenting: presenting )
    }
}
// MARK: - PostSettingCellDelegate
extension FavoriteInfoVC: PostSettingVCDelegate {
    func showAddFavoriteListOKView(favorite: Favorite) {
        self.willBeAddedList = favorite
        let postList: [(String, String)] = self.willBeAddedPostList.map { (index) -> (String, String) in
            let mediaMetaArray = self.filteredPostList[index].mediaMeta
            return (self.filteredPostList[index].id, !mediaMetaArray.isEmpty ? mediaMetaArray[0].thumbnail : "")
        }
        self.viewModel.addFavoriteList(listName: favorite.title, post: postList)
    }
    func createFavoriteListAndInsert(title: String) {
        self.viewModel.createFavoriteList(listName: title)
    }
    func addNotSorted() {
        let postList: [(String, String)] = self.willBeAddedPostList.map { (index) -> (String, String) in
            let mediaMetaArray = self.filteredPostList[index].mediaMeta
            return (self.filteredPostList[index].id, !mediaMetaArray.isEmpty ? mediaMetaArray[0].thumbnail : "")
        }
        self.viewModel.addFavoriteList(listName: "", post: postList)
    }
}
// MARK: - NewPostTableViewControllerDelagte
extension FavoriteInfoVC: NewPostTableViewControllerDelagte {
    func addPostCallBack(postList: [(id: String, coverImage: String)]) {
        self.willBeAddedList = self.favorite
        self.viewModel.addFavoriteList(listName: self.titleFavorite, post: postList)
    }
}

protocol NewPostTableViewControllerDelagte {
    func addPostCallBack(postList: [(id: String, coverImage: String)])
}
// MARK: - Private Object
fileprivate class NewPostTableViewController: UITableViewController {
    var postList = [Post]()
    lazy private var btnAddPost: UIButton = {
        let button = UIButton()
        button.setTitle("加入 ０ 篇文章", for: .disabled)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.backgroundColor = .systemGray3
        button.addTarget(self, action: #selector(self.addPost), for: .touchUpInside)
        return button
    }()
    private var shouldUpdateConstraint = true
    private var willBeAddedPostList: [Int] = [] {
        didSet {
            if self.willBeAddedPostList.isEmpty {
                self.btnAddPost.isEnabled = false
                self.btnAddPost.backgroundColor = .systemGray3
            } else {
                self.btnAddPost.isEnabled = true
                self.btnAddPost.backgroundColor = .link
                self.btnAddPost.setTitle("加入 \(self.willBeAddedPostList.count) 篇文章", for: .normal)
            }
        }
    }
    private var delegate: NewPostTableViewControllerDelagte?
    
    init(postList: [Post], _ delegate: NewPostTableViewControllerDelagte) {
        self.postList = postList
        self.delegate = delegate
        super.init(style: .plain)
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        self.navigationItem.title = "新增文章"
        self.navigationItem.largeTitleDisplayMode = .always
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(close)), animated: true)
        
        self.tableView.setEditing(true, animated: false)
        self.tableView.allowsMultipleSelectionDuringEditing = true
        
        self.view.addSubview(self.btnAddPost)
        self.view.bringSubviewToFront(self.btnAddPost)
        self.btnAddPost.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            maker.leading.equalToSuperview().offset(20)
            maker.height.equalTo(50)
            maker.centerX.equalToSuperview()
        }
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.postList.count : 1
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.setContent(post: self.postList[row], mode: .favorite)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) //隱藏分隔線
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        return section == 0 ? 120 : 180
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let section = indexPath.section
        return section == 0
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        var newList = self.willBeAddedPostList
        newList.append(row)
        self.willBeAddedPostList = newList
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        self.willBeAddedPostList = self.willBeAddedPostList.filter( { $0 != row })
    }
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func addPost() {
        guard let delegate = self.delegate else { return }
        let _postList: [(String, String)] = self.willBeAddedPostList.map { (index) -> (String, String) in
            let mediaMetaArray = self.postList[index].mediaMeta
            return (self.postList[index].id, !mediaMetaArray.isEmpty ? mediaMetaArray[0].thumbnail : "")
        }
        delegate.addPostCallBack(postList: _postList)
    }
}
