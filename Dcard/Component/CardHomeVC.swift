//
//  CardHomeVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class CardHomeVC: UIViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "CardHomeVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy private var _tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        return tableView
    }()
    @IBOutlet weak var viewIcon: customView!
    @IBOutlet weak var lbIcon: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var stackViewHeight: NSLayoutConstraint!
    @IBOutlet weak var iconHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBell: UIView!
    @IBOutlet weak var viewProfileInfo: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageBell: UIImageView!
    @IBOutlet weak var btnFollow: customButton!
    
    private var dragging = false
    private var oldY: CGFloat = 0
    private var imageBellNameList = ["bell.circle.fill", "bell.fill", "bell.slash.fill"]
    private var followCard: FollowCard!
    private var navigationItemTitle = ""
    private var myPostList = ProfileManager.shared.myPostList
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    @IBAction func didClickBtnCancelFollow(_ sender: UIButton) {
        ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + followCard.card.name + "」？") {
            self.resetBellState(false, notifyMode: 0)
            ProfileManager.shared.showOKView(mode: .cancelFollowCard, handler: nil)
        }
    }
    func setContent(followCard: FollowCard, title: String) {
        self.followCard = followCard
        self.navigationItemTitle = title
    }
}
// MARK: - SetupUI
extension CardHomeVC {
    private func initView() {
        confiTableview()
        self.view.bringSubviewToFront(self.viewProfileInfo)
        self.navigationItem.title = self.navigationItemTitle
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
        self.viewBell.addGestureRecognizer(tap)
        
        resetBellState(self.followCard.isFollowing, notifyMode: self.followCard.notifyMode)
    }
    private func confiTableview() {
        self._tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self._tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.backgroundColor = .clear
        self._tableView.backgroundColor = .clear
    }
}
// MARK: - Private Func
extension CardHomeVC {
    @objc private func didClickBell() {
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: self.followCard.notifyMode)
    }
    //重置通知狀態
    private func resetBellState(_ isFollowing: Bool, notifyMode: Int) {
        if isFollowing {
            self.viewBell.isHidden = false
            self.btnFollow.setTitleColor(.darkText, for: .normal)
            self.btnFollow.setTitle("追蹤中", for: .normal)
            self.btnFollow.backgroundColor = .lightGray
        } else {
            self.viewBell.isHidden = true
            self.btnFollow.setTitleColor(.white, for: .normal)
            self.btnFollow.setTitle("追蹤", for: .normal)
            self.btnFollow.backgroundColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        }
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[notifyMode])
    }
}
// MARK: - UITableViewDelegate
extension CardHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let isTableView = tableView === self.tableView
        return isTableView ? 1 : (section == 0 ? self.myPostList.count : 1)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let isTableView = tableView === self.tableView
        if isTableView {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
            cell.selectionStyle = section == 0 ? .none : .default
            cell.backgroundColor = .clear
            if section == 1 {
                cell.setFixedView(self._tableView)
            }
            return cell
        } else {
            guard indexPath.section == 0 else {
                let cell = UITableViewCell()
                cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
                cell.textLabel?.text = "沒有更多囉！"
                cell.textLabel?.textAlignment = .center
                cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) //隱藏分隔線
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.setContent(post: self.myPostList[indexPath.row], mode: .profile)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return tableView === self.tableView && section == 1 ? "所有文章" : nil
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let isTableView = tableView === self.tableView
        var height = CGFloat.leastNonzeroMagnitude
        if isTableView {
            switch section {
            case 0:
                height = self.viewProfileInfo.frame.height
            default:
                height = self.tableView.frame.height - 50
            }
        } else {
            switch section {
            case 0:
                height = 120
            default:
                height = 180
            }
        }
        return height
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        let isTableView = tableView === self.tableView
        let scale = min(max(1.0 - yOffset / 100.0, 0.0), 1.0)
        if isTableView {
            self.view.bringSubviewToFront(self.tableView)
            self.lbDescription.alpha = scale
            self.lbIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
            self.iconHeight.constant = 50 - (1 - scale) * 50
            self.stackViewHeight.constant = 100 - (1 - scale) * 50
            self.viewIcon.cornerRadius = (self.iconHeight.constant - 10) / 2
            self.view.layoutIfNeeded()
            
        }
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let yOffset = scrollView.contentOffset.y
        let isTableView = tableView === self.tableView
        if isTableView {
            self.tableView.contentOffset = CGPoint(x: 0, y: yOffset >= 50 ? 100 : 0)
            self.lbDescription.alpha = yOffset >= 50 ? 0 : 1
            self.view.bringSubviewToFront(self.tableView.contentOffset.y == 0 ? self.viewProfileInfo : self.tableView)
        }
    }
}
// MARK: - SelectNotifyViewDelegate
extension CardHomeVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[newNotifymode])
    }
}
