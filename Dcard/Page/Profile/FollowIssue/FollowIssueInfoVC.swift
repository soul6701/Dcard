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
    @IBOutlet weak var topSpace: NSLayoutConstraint!
    @IBOutlet weak var tbHeight: NSLayoutConstraint!
    @IBOutlet weak var ViewSegmented: UIView!
    @IBOutlet weak var viewProfileInfo: UIView!
    @IBOutlet var lbIssueTitle: [UILabel]!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var viewBell: UIView!
    @IBOutlet weak var imageBell: UIImageView!
    @IBOutlet weak var btnFollow: customButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var lbFollowing: UILabel!
    
    private var imageBellNameList = ["bell.circle.fill", "bell.fill", "bell.slash.fill"]
    private var followIssue: FollowIssue!
    private var myPostList = ProfileManager.shared.myPostList
    private var isFollowing = false
    private var notifyMode = 0
    private var canBeDragged = false
    
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
    @IBAction func didClickShare(_ sender: UIButton) {
        //
    }
    
    func setContent(followIssue: FollowIssue) {
        self.followIssue = followIssue
    }
}
// MARK: - SetupUI
extension FollowIssueInfoVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.tbHeight.constant = self.mode == .user ? -175 : -75
        addControlAndSetAutoLayout()
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
        self.viewBell.addGestureRecognizer(tap)
        self.isFollowing = self.followIssue.isFollowing
        self.notifyMode = self.followIssue.notifyMode
        self.lbIssueTitle.forEach { (lb) in
            lb.text = self.followIssue.listName
        }
        self.lbDescription.text = "\(followIssue.postCount) 篇文章 | \(followIssue.followCount) 位粉絲"
        resetBellState(self.isFollowing, notifyMode: self.notifyMode)
        
        confiTableView()
    }
    private func addControlAndSetAutoLayout() {
        self.ViewSegmented.addSubview(self.control)
        self.control.snp.makeConstraints { (maker) in
            maker.bottom.top.leading.equalToSuperview()
            maker.width.equalToSuperview().dividedBy(3)
        }
    }
    private func confiTableView() {
        self.tableView.isScrollEnabled = false
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        let pan = UIPanGestureRecognizer(target: self, action: #selector(didPanArticle))
        pan.delegate = self
        pan.cancelsTouchesInView = false
        pan.delaysTouchesBegan = true
        self.tableView.addGestureRecognizer(pan)
    }
}
// MARK: - Private Handler
extension FollowIssueInfoVC {
    @objc private func didClickControl(_ sender: ScrollableSegmentedControl) {
        
    }
    //彈出通知選項視窗
    @objc private func didClickBell() {
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: self.notifyMode)
    }
    //移動文章表格
    @objc private func didPanArticle(_ ges: UIPanGestureRecognizer) {
        if ges.state == .began || ges.state == .changed {
            
            let translation = ges.translation(in: ges.view)
            if self.bottomSpace.constant > 0 || self.canBeDragged {
                self.bottomSpace.constant += translation.y
            } else if self.bottomSpace.constant > 100 {
                self.bottomSpace.constant = 100
            } else {
                self.bottomSpace.constant = 0
            }
            let scale = max(min(self.bottomSpace.constant, 100) / 100, 0)
            let _scale = max(min(self.bottomSpace.constant, 50) / 50, 0)
            self.lbDescription.alpha = scale
            self.imageBell.alpha = scale
            self.btnFollow.alpha = scale
            self.lbIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.iconHeight.constant = 50 * scale
            self.stackViewHeight.constant = 50 + 50 * scale
            self.lbIcon.layer.cornerRadius = (self.iconHeight.constant - 5) / 2
            self.btnShare.isHidden = scale < 1
            self.lbFollowing.alpha = (1 - _scale)
            self.view.layoutIfNeeded()
            ges.setTranslation(CGPoint.zero, in: ges.view)
        }
        if ges.state == .ended {
            if self.bottomSpace.constant >= 50 {
                self.bottomSpace.constant = 100
                self.tableView.isScrollEnabled = false
                self.lbDescription.alpha = 1
                self.imageBell.alpha = 1
                self.btnFollow.alpha = 1
                self.btnShare.isHidden = false
                self.lbFollowing.alpha = 0
                self.lbIcon.transform = CGAffineTransform(scaleX: 1, y: 1)
                self.iconHeight.constant = 50
                self.stackViewHeight.constant = 100
                self.lbIcon.layer.cornerRadius = (self.iconHeight.constant - 5) / 2
            } else {
                self.tableView.scrollsToTop = true
                self.bottomSpace.constant = 0
                self.tableView.isScrollEnabled = true
                self.lbDescription.alpha = 0
                self.imageBell.alpha = 0
                self.btnFollow.alpha = 0
                self.btnShare.isHidden = true
                self.lbFollowing.alpha = 1
                self.lbIcon.transform = CGAffineTransform(scaleX: 0, y: 0)
                self.iconHeight.constant = 0
                self.stackViewHeight.constant = 50
                self.lbIcon.layer.cornerRadius = (self.iconHeight.constant - 5) / 2
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
//    private func scrollHandler(_ yOffset: CGFloat) {
//        if yOffset <= 0 {
//            self.canBeDragged = true
//            self.tableView.isScrollEnabled = false
//        } else {
//            self.canBeDragged = false
//        }
//    }
}
// MARK: - UITableViewDelegate
extension FollowIssueInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.myPostList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.setContent(post: self.myPostList[indexPath.row], mode: .profile)
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
        vc.setContent(post: myPostList[row], commentList: [Comment()])
        vc.navigationItem.title = myPostList[row].title
        vc.modalPresentationStyle = .formSheet
        self.navigationController?.pushViewController(vc, animated: true) {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        guard self.mode == .other else { return }
//        scrollHandler(scrollView.contentOffset.y)
//    }
//
//    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
//        guard self.mode == .other && decelerate else { return }
//        scrollHandler(scrollView.contentOffset.y)
//    }
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

