//
//  FollowIssueInfoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/10/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

class FollowIssueInfoVC: UIViewController {
    
    lazy private var control: ScrollableSegmentedControl = {
        let control = ScrollableSegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.segmentStyle = .textOnly
        control.insertSegment(withTitle: "最新", at: 0)
        control.insertSegment(withTitle: "熱門", at: 1)
        control.underlineSelected = true
        control.segmentContentColor = .lightGray
        control.selectedSegmentContentColor = .black
        control.backgroundColor = .clear
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(self.didClickControl(_:)), for: .valueChanged)
        return control
    }()
    lazy private var btnBG: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.alpha = 0.8
        button.backgroundColor = .black
        button.addTarget(self, action: #selector(self.closeHintView), for: .touchUpInside)
        return button
    }()
    lazy private var tableViewHint: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        tableView.layer.cornerRadius = 10
        tableView.showsVerticalScrollIndicator = false
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    lazy private var pan: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(self.didPanArticle))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        pan.delaysTouchesBegan = true
        return pan
    }()
    @IBOutlet weak var viewContainer: UIView!
    @IBOutlet weak var viewTitle: UIStackView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var ViewSegmented: UIView!
    @IBOutlet weak var viewProfileInfo: UIView!
    @IBOutlet var lbIssueTitle: [UILabel]!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var viewBell: UIView!
    @IBOutlet weak var imageBell: UIImageView!
    @IBOutlet weak var btnFollow: customButton!
    @IBOutlet weak var tableViewAll: UITableView!
    @IBOutlet weak var tableViewHot: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lbFollowing: UILabel!
    
    private var imageBellNameList = ["bell.circle.fill", "bell.fill", "bell.slash.fill"]
    private var followIssue: FollowIssue!
    private var allPostList = ProfileManager.shared.myPostList
    private var hotPostList: [Post] {
        return self.allPostList.filter{ return $0.hot }
    }
    private var isFollowing = false
    private var notifyMode = 0
    private var canBeDragged = false
    private var viewProfileInfoHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func didClickBtnCancelFollow(_ sender: UIButton) {
        if self.isFollowing {
            ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + self.followIssue.listName + "」？") {
                self.isFollowing = false
                self.resetBellState(false, notifyMode: self.notifyMode)
                ProfileManager.shared.showOKView(mode: .cancelFollowCard, handler: nil)
            }
        } else {
            let loadingView = UIActivityIndicatorView(style: .medium)
            loadingView.color = .white
            loadingView.translatesAutoresizingMaskIntoConstraints = false
            self.btnFollow.addSubview(loadingView)
            loadingView.snp.makeConstraints { (maker) in
                maker.bottom.equalToSuperview().offset(-2)
                maker.top.equalToSuperview().offset(2)
                maker.centerX.equalToSuperview()
                maker.width.equalTo(loadingView.snp.height)
            }
            
            self.btnFollow.setTitle("", for: .normal)
            loadingView.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                self.isFollowing = true
                self.resetBellState(true, notifyMode: self.notifyMode)
                loadingView.stopAnimating()
            }
        }
    }
    @IBAction func didClickBack(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func didClickBtnEdit(_ sender: UIButton) {
        self.btnBG.isHidden = false
        self.tableViewHint.isHidden = false
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.8) {
            self.setupHintViewEndSize()
            self.tableViewHint.layoutIfNeeded()
        }.startAnimation()
    }
    
    func setContent(followIssue: FollowIssue) {
        self.followIssue = followIssue
    }
}
// MARK: - SetupUI
extension FollowIssueInfoVC {
    private func initView() {
        ToolbarView.shared.show(false)
        addControlAndSetAutoLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
        self.viewBell.addGestureRecognizer(tap)
        self.isFollowing = self.followIssue.isFollowing
        self.notifyMode = self.followIssue.notifyMode
        self.lbIssueTitle.forEach { (lb) in
            lb.text = self.followIssue.listName
        }
        self.lbDescription.text = "\(followIssue.post.count) 篇文章 | \(followIssue.followCount) 位粉絲"
        resetBellState(self.isFollowing, notifyMode: self.notifyMode)
        confiTableView()
        setupHintView()
        self.view.layoutIfNeeded()
        self.viewProfileInfoHeight = self.viewProfileInfo.frame.height
        self.viewTitle.alpha = 0
        self.lbFollowing.alpha = 0
        self.tableViewHot.isHidden = true
    }
    private func addControlAndSetAutoLayout() {
        self.ViewSegmented.addSubview(self.control)
        self.control.snp.makeConstraints { (maker) in
            maker.bottom.top.leading.equalToSuperview()
            maker.width.equalToSuperview().dividedBy(3)
        }
    }
    private func confiTableView() {
        self.tableViewAll.isScrollEnabled = false
        self.tableViewHot.isScrollEnabled = false
        self.tableViewAll.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableViewHot.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        
        self.viewContainer.addGestureRecognizer(self.pan)
    }
    private func setupHintView() {
        self.view.setFixedView(self.btnBG)
        self.view.addSubview(self.tableViewHint)
        setupHintViewInitialSize()
    }
    private func setupHintViewInitialSize() {
        self.tableViewHint.snp.remakeConstraints { (maker) in
            maker.top.equalTo(self.btnEdit.snp.bottom).offset(5)
            maker.trailing.equalTo(self.btnEdit.snp.leading).offset(5)
            maker.width.height.equalTo(1)
        }
        self.btnBG.isHidden = true
        self.tableViewHint.isHidden = true
    }
    private func setupHintViewEndSize() {
        self.tableViewHint.snp.remakeConstraints { (maker) in
            maker.top.equalTo(self.btnEdit.snp.bottom).offset(5)
            maker.trailing.equalTo(self.btnEdit.snp.leading).offset(5)
            maker.width.equalTo(200)
            maker.height.equalTo(100)
        }
    }
}
// MARK: - Private Handler
extension FollowIssueInfoVC {
    @objc private func didClickControl(_ sender: ScrollableSegmentedControl) {
        let isAll = sender.selectedSegmentIndex == 0
        self.tableViewAll.isHidden = !isAll
        self.tableViewHot.isHidden = isAll
        self.canBeDragged = false
    }
    //彈出通知選項視窗
    @objc private func didClickBell() {
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: self.notifyMode)
    }
    //移動文章表格
    @objc private func didPanArticle(_ ges: UIPanGestureRecognizer) {
        let upperBoundary = 40 - self.viewProfileInfoHeight
        let tableView = (self.control.selectedSegmentIndex == 0 ? self.tableViewAll : self.tableViewHot)!
        if ges.state == .began || ges.state == .changed {
            let translation = ges.translation(in: ges.view)
            if self.topSpace.constant > upperBoundary || self.canBeDragged {
                self.topSpace.constant += translation.y
                self.btnEdit.isHidden = true
            } else if self.topSpace.constant <= upperBoundary {
                self.topSpace.constant = upperBoundary
                self.btnEdit.isHidden = true
            } else {
                self.topSpace.constant = 40
                self.btnEdit.isHidden = false
            }
            let scale = min(self.topSpace.constant / 40, 1)
            self.viewProfileInfo.alpha = scale
            self.viewTitle.alpha = 1 - scale
            self.lbFollowing.alpha = 1 - scale
            self.view.layoutIfNeeded()
            ges.setTranslation(CGPoint.zero, in: ges.view)
        }
        if ges.state == .ended {
            let linePosition = 40 - self.viewProfileInfoHeight / 2
            if self.topSpace.constant >= linePosition {
                self.topSpace.constant = 40
                tableView.isScrollEnabled = false
                self.viewProfileInfo.alpha = 1
                self.viewTitle.alpha = 0
                self.lbFollowing.alpha = 0
                self.btnEdit.isHidden = false
            } else {
                tableView.scrollsToTop = true
                self.topSpace.constant = upperBoundary
                tableView.isScrollEnabled = true
                self.viewProfileInfo.alpha = 0
                self.viewTitle.alpha = 1
                self.lbFollowing.alpha = 1
                self.btnEdit.isHidden = true
            }
            self.view.layoutIfNeeded()
        }
    }
    //重置通知狀態
    private func resetBellState(_ isFollowing: Bool, notifyMode: Int) {
        if isFollowing {
            self.imageBell.isHidden = false
            self.btnFollow.setTitleColor(.darkGray, for: .normal)
            self.btnFollow.setTitle("追蹤中", for: .normal)
            self.btnFollow.backgroundColor = .systemGray5
        } else {
            self.imageBell.isHidden = true
            self.btnFollow.setTitleColor(.white, for: .normal)
            self.btnFollow.setTitle("追蹤", for: .normal)
            self.btnFollow.backgroundColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        }
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[notifyMode])
    }
    //TableView滾輪動作
    private func scrollHandler(in tableView: UITableView, yOffset: CGFloat) {
        if yOffset <= 0 {
            self.canBeDragged = true
            tableView.isScrollEnabled = false
        } else {
            self.canBeDragged = false
        }
    }
    @objc private func closeHintView() {
        setupHintViewInitialSize()
    }
}
// MARK: - UITableViewDelegate
extension FollowIssueInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        let notTableViewHint = tableView !== self.tableViewHint
        return notTableViewHint ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let notTableViewHint = tableView !== self.tableViewHint
        let isTableViewAll = tableView == self.tableViewAll
        return notTableViewHint ? (section == 0 ? (isTableViewAll ? self.allPostList.count : self.hotPostList.count ) : 1) : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        let notTableViewHint = tableView !== self.tableViewHint
        let isTableViewAll = tableView == self.tableViewAll
        
        if notTableViewHint {
            if section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
                cell.setContent(post: isTableViewAll ? self.allPostList[row] : self.hotPostList[row], mode: .profile)
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
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            cell.imageView?.image = UIImage(systemName: row == 0 ? "square.and.arrow.up.fill" : "exclamationmark.circle.fill")
            cell.imageView?.tintColor = .systemGray5
            cell.textLabel?.text = row == 0 ? "分享" : "檢舉話題"
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let notTableViewHint = tableView !== self.tableViewHint
        return notTableViewHint ? (indexPath.section == 0 ? 120 : 180) : 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let notTableViewHint = tableView !== self.tableViewHint
        let isTableViewAll = tableView == self.tableViewAll
        let post = isTableViewAll ? allPostList[row] : hotPostList[row]
        
        if notTableViewHint {
            let vc = UIStoryboard.home.postVC
            vc.setContent(post: post, commentList: [Comment()])
            vc.navigationItem.title = post.title
            vc.modalPresentationStyle = .formSheet
            self.navigationController?.pushViewController(vc, animated: true) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        } else {
            setupHintViewInitialSize()
            if row == 0 {
                let vc = UIActivityViewController(activityItems: [self.followIssue.listName], applicationActivities: nil)
                vc.completionWithItemsHandler = { (_, completed, _, error) in
                    if let error = error {
                        ProfileManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
                    }
                    if completed {
                        ProfileManager.shared.showOKView(mode: .shareCardInfoAndIssueInfo, handler: nil)
                    }
                }
                present(vc, animated: true, completion: nil)
            } else {
                let vc = ReportVC()
                let nav = UINavigationController(rootViewController: vc)
                nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
                nav.modalPresentationStyle = .fullScreen
                present(nav, animated: true, completion: nil)
            }
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let notTableViewHint = scrollView !== self.tableViewHint
        if notTableViewHint {
            scrollHandler(in: scrollView as! UITableView, yOffset: scrollView.contentOffset.y)
        }
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard decelerate else { return }
        let notTableViewHint = scrollView !== self.tableViewHint
        if notTableViewHint {
            scrollHandler(in: scrollView as! UITableView, yOffset: scrollView.contentOffset.y)
        }
    }
}
// MARK: - SelectNotifyViewDelegate
extension FollowIssueInfoVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.notifyMode = newNotifymode
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[newNotifymode])
    }
}
extension FollowIssueInfoVC: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

