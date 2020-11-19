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


enum FavoriteInfoMode {
    case all
    case other
}

class FavoriteInfoVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
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
    
    private var viewModel: PostVMInterface!
    private let disposeBag = DisposeBag()
    private var mode: FavoriteInfoMode = .all
    private var catalogSelected: Bool = false
    private var selectedForumNameList: [String] = []
    private var postIDList: [String] = []
    private var titleFavorite: String = ""
    private var newTitleFavorite: String = ""
    private var selectedPost: Post = Post()
    
    private var filteredPostList = [Post]() { //過濾後貼文
        didSet {
            self.tableView.reloadData()
        }
    }
    private var postList: [Post] = [] //全部貼文
    private var imageStrings: [String] = []
    
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
        OptionView.shared.configure(self, mode: .editFavorite)
        OptionView.shared.show()
    }
    @IBAction func didClickBtnSelect(_ sender: UIButton) {
        self.btnSelect.setTitle(self.btnForumFilter.isEnabled ? "完成" : "選取", for: .normal)
        self.btnCatalog.isEnabled = self.btnCatalog.isEnabled
        self.btnForumFilter.isEnabled = self.btnForumFilter.isEnabled
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
        } else {
            self.btnCatalog.imageView?.subviews.last?.removeFromSuperview()
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
        vc.setContent(selectedForumNameList: self.selectedForumNameList)
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        nav.navigationBar.tintColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        nav.modalPresentationStyle = .overFullScreen
        present(nav, animated: true, completion: nil)
    }
    func setContent(_ mode: FavoriteInfoMode, title: String, postIDList: [String], imageStrings: [String]) {
        self.mode = mode
        self.titleFavorite = title
        self.postIDList = postIDList
        self.imageStrings = imageStrings
    }
}
// MARK: - SetupUI
extension FavoriteInfoVC {
    private func initView() {
        confiTableView()
        confiTitleView()
        confiContainerView()
    }
    private func confiTableView() {
        let isAll = self.mode == .all
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableView.contentInset = UIEdgeInsets(top: isAll ? 300 : 260 , left: 0, bottom: 0, right: 0)
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: isAll ? 300 : 260 , left: 0, bottom: 0, right: 0)
    }
    private func confiTitleView() {
        self.viewContainertwo.isHidden = self.mode == .other
        self.lbTitle.text = self.titleFavorite
        self.btnSelect.setTitle(self.mode == .all ? "選取" : "新增文章", for: .normal)
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
// MARK: - ConfigureViewModel
extension FavoriteInfoVC {
    private func confiViewModel() {
        self.viewModel = PostVM()
    }
    private func subsribeViewModel() {
        self.viewModel.getPostInfoOfListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            self.postList = result.data
            self.filteredPostList = result.data
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
        
        self.viewModel.getPostInfoOfList(postIDs: self.postIDList)
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
            cell.setContent(post: self.filteredPostList[row], mode: .profile)
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
        let vc = UIStoryboard.home.postVC
        let post = self.filteredPostList[row]
        //假植
        var commonList = [Comment]()
        let random = (0...100).randomElement()!
        (0...random).forEach { (_) in
            commonList.append(Comment())
        }
        vc.setContent(post: post, commentList: commonList)
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
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
            self.selectedForumNameList = []
            self.btnForumFilter.setTitle("看板篩選 ▼", for: .normal)
            self.btnForumFilter.setTitleColor(.darkGray, for: .normal)
            return
        }
        self.selectedForumNameList = selectedForumNameList
        self.btnForumFilter.setTitle("看板篩選·\(selectedForumNameList.count) ▼", for: .normal)
        self.btnForumFilter.setTitleColor(#colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78), for: .normal)
        self.filteredPostList = self.filteredPostList.filter { return selectedForumNameList.contains($0.forumName) }
    }
}
// MARK: - PostCellDelegate
extension FavoriteInfoVC: PostCellDelegate {
    func edit(post: Post) {
        self.selectedPost = post
        OptionView.shared.configure(self, mode: .editPost)
        OptionView.shared.show()
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
