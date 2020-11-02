//
//  FavoriteInfoVC.swift
//  Dcard
//
//  Created by Mason on 2020/10/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum FavoriteInfoMode {
    case all
    case other
}
protocol FavoriteForumVCDelegate {
    func filterForum(selectedForumNameList: [String])
}
fileprivate class FavoriteForumCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        self.textLabel?.textColor = selected ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .label
    }
}
fileprivate class FavoriteForumVC: UIViewController {
    lazy private var tableView: UITableView = {
       let tableView = UITableView()
        tableView.register(FavoriteForumCell.self, forCellReuseIdentifier: "FavoriteForumCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    lazy private var stackView: UIStackView = {
       let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.alignment = .fill
        return stackView
    }()
    lazy private var btnList: [UIButton] = {
        var buttonList = [UIButton]()
        (0...1).forEach { (i) in
            let button = UIButton(type: .system)
            button.setTitle(i == 0 ? "清除條件" : "套用", for: .normal)
            button.backgroundColor = i == 0 ? .clear : #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
            button.setTitleColor(i == 0 ? .darkGray : .white, for: .normal)
            button.setTitleColor(i == 0 ? .systemGray3 : nil, for: .disabled)
            button.layer.cornerRadius = 10
            if i == 0 {
                button.addTarget(self, action: #selector(clearFilter), for: .touchUpInside)
            } else {
                button.addTarget(self, action: #selector(self.apply), for: .touchUpInside)
            }
            
            buttonList.append(button)
        }
        return buttonList
    }()
    private var forumList: [Forum] {
        return ModelSingleton.shared.forum
    }
    private var selectedCellList = [IndexPath: FavoriteForumCell]()
    private var selectedForumNameList = [String]()
    private var delegate: FavoriteForumVCDelegate?
    
    override func viewDidLoad() {
        self.navigationItem.title = "看板"
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: btn), animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "常用", style: .plain, target: self, action: #selector(apply)), animated: false)
        self.btnList[0].isEnabled = !self.selectedForumNameList.isEmpty
        self.btnList.forEach { (btn) in
            self.stackView.addArrangedSubview(btn)
        }
        addViewAndSetupAutolayout()
    }
    func setContent(selectedForumNameList: [String]) {
        self.selectedForumNameList = selectedForumNameList
    }
    func setDelegate(_ delegate: FavoriteForumVCDelegate) {
        self.delegate = delegate
    }
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func apply() {
        let nameList: [String] = self.selectedCellList.map { return self.forumList[$0.key.row].name }
        self.delegate?.filterForum(selectedForumNameList: nameList)
        dismiss(animated: true, completion: nil)
    }
    @objc private func clearFilter() {
        self.selectedCellList.forEach { (_, cell) in
            cell.isSelected = false
        }
        self.selectedCellList.removeAll()
    }
    private func addViewAndSetupAutolayout() {
        self.view.setFixedView(self.tableView, inSafeArea: true)
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.stackView)
        self.stackView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(15)
            maker.trailing.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(40)
        }
        self.view.addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.tableView.snp.bottom)
            maker.leading.equalTo(self.tableView.snp.leading)
            maker.trailing.equalTo(self.tableView.snp.trailing)
            maker.height.equalTo(80)
        }
    }
}
// MARK: - UITableViewDelegate
extension FavoriteForumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forumList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let forum = self.forumList[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteForumCell", for: indexPath) as! FavoriteForumCell
        cell.textLabel?.text = forum.name
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let forum = self.forumList[row]
        if self.selectedForumNameList.contains(forum.name) {
            self.selectedCellList[indexPath] = (cell as! FavoriteForumCell)
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteForumCell
        self.selectedCellList[indexPath] = cell
        self.btnList[0].isEnabled = self.selectedCellList.count > 0
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedCellList[indexPath] = nil
        self.btnList[0].isEnabled = self.selectedCellList.count > 0
    }
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
    
    private var itemSpace: CGFloat = 5
    private var mode: FavoriteInfoMode = .all
    private var catalogSelected = false
    private var selectedForumNameList = [String]()
    private var favorite: Favorite = Favorite()
    private var favoritePostList: [Post] {
        return self.favorite.posts
    }
    private var filteredPostList = [Post]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var hotFavoritePostList: [Post] {
        return self.favorite.posts.filter { return $0.hot }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
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
    func setContent(favorite: Favorite = ModelSingleton.shared.favorite[0], mode: FavoriteInfoMode) {
        self.mode = mode
        self.favorite = favorite
        
        if self.mode == .all {
            var posts = [Post]()
            self.favorite.posts.forEach { (post) in
                posts.append(Post(id: post.id, title: post.title, excerpt: post.excerpt, createdAt: post.createdAt, commentCount: post.commentCount, likeCount: post.likeCount, forumName: ModelSingleton.shared.forum.randomElement()?.name ?? "", gender: post.gender, department: post.department, anonymousSchool: post.anonymousSchool, anonymousDepartment: post.anonymousDepartment, school: post.school, withNickname: post.withNickname, mediaMeta: post.mediaMeta, host: post.host, hot: post.hot))
            }
            self.favorite.posts = posts
        }
    }
}
// MARK: - SetupUI
extension FavoriteInfoVC {
    private func initView() {
        confiTableView()
        confiTitleView()
        confiContainerView()
        self.filteredPostList = self.favoritePostList
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
        self.lbTitle.text = self.mode == .all ? "全部收藏" : self.favorite.title
        self.btnSelect.setTitle(self.mode == .all ? "選取" : "新增文章", for: .normal)
    }
    private func confiContainerView() {
        if self.mode == .all {
            let postList: [Post] = self.favorite.posts.filter { $0.mediaMeta.count > 0}
            if postList.count > 4 {
                postList[0...3].enumerated().forEach { (key, value) in
                    let mediaMeta = value.mediaMeta[0]
                    self.imageViewList[key].kf.setImage(with: URL(string: mediaMeta.normalizedUrl))
                }
            } else {
                self.imageViewList.enumerated().forEach { (key, value) in
                    if key < postList.count {
                        value.kf.setImage(with: URL(string: postList[key].mediaMeta[0].normalizedUrl))
                    }
                }
            }
        } else {
            self.stackView.isHidden = true
            self.imageViewList[1].isHidden = true
            let firstMediaMeta = self.favorite.posts.first { return $0.mediaMeta.count > 0 }?.mediaMeta[0].normalizedUrl ?? ""
            self.imageViewList[0].kf.setImage(with: URL(string: firstMediaMeta))
        }
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
            self.filteredPostList = self.favoritePostList
            self.selectedForumNameList = []
            self.btnForumFilter.setTitle("看板篩選 ▼", for: .normal)
            self.btnForumFilter.setTitleColor(.darkGray, for: .normal)
            return
        }
        self.selectedForumNameList = selectedForumNameList
        self.btnForumFilter.setTitle("看板篩選·\(selectedForumNameList.count) ▼", for: .normal)
        self.btnForumFilter.setTitleColor(#colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78), for: .normal)
        self.filteredPostList = self.favoritePostList.filter { return selectedForumNameList.contains($0.forumName) }
    }
}
