//
//  CardHomeVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum CardHomeVCMode {
    case user
    case other
}

class CardHomeVC: UIViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "CardHomeVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @IBOutlet weak var tbHeight: NSLayoutConstraint!
    @IBOutlet weak var viewFollow: UIView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var viewIcon: customView!
    @IBOutlet weak var lbID: UILabel!
    @IBOutlet weak var lbName: UILabel!
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
    private var myPostList = ProfileManager.shared.myPostList
    private var isFollowing = false
    private var notifyMode = 0
    private var mode: CardHomeVCMode = .user
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.mode == .user {
            self.followCard = FollowCard(card: ModelSingleton.shared.userConfig.user.card)
            resetData(self.followCard)
        }
    }
    @IBAction func didClickBtnCancelFollow(_ sender: UIButton) {
        if self.isFollowing {
            ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + followCard.card.name + "」？") {
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
    @IBAction func didClickEdit(_ sender: UIButton) {
        let vc = SettingAccountVC()
        vc.setContent(mode: .editCard, title: "編輯卡稱")
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true) {
            nav.navigationBar.tintColor = #colorLiteral(red: 0.5741485357, green: 0.5741624236, blue: 0.574154973, alpha: 1)
            nav.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.black]
        }
    }
    @IBAction func didClickShare(_ sender: UIButton) {
        let alertSheet = UIAlertController(title: nil, message: "分享", preferredStyle: .actionSheet)
        let actionShare = UIAlertAction(title: "分享我的公開頁面", style: .default) { (action) in
            //
        }
        let aciontCancel = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertSheet.addAction(actionShare)
        alertSheet.addAction(aciontCancel)
        self.present(alertSheet, animated: true, completion: nil)
    }
    
    func setContent(followCard: FollowCard = FollowCard(card: ModelSingleton.shared.userConfig.user.card), mode: CardHomeVCMode) {
        self.followCard = followCard
        self.mode = mode
    }
}
// MARK: - SetupUI
extension CardHomeVC {
    private func initView() {
        confiTableview()
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        ToolbarView.shared.show(false)
        
        if self.mode == .other {
            let tap = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
            self.viewBell.addGestureRecognizer(tap)
        }
        self.viewFollow.isHidden = self.mode == .user
        self.bottomSpace.constant = self.mode == .user ? 0 : 125
        self.tbHeight.constant = self.mode == .user ? -175 : -125
        resetData(self.followCard)
    }
    private func confiTableview() {
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
    }
}
// MARK: - Private Func
extension CardHomeVC {
    @objc private func didClickBell() {
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: self.followCard.notifyMode)
    }
    //重置卡稱資訊
    private func resetData(_ followCard: FollowCard) {
        self.isFollowing = followCard.isFollowing
        self.notifyMode = followCard.notifyMode
        self.lbDescription.text = "\(followCard.card.post.count) 篇文章 | \(followCard.card.fans) 位粉絲"
        self.lbID.text = "@\(followCard.card.id)"
        self.lbName.text = followCard.card.name
        self.lbIcon.text = String(followCard.card.id.first!).uppercased()
        resetBellState(self.isFollowing, notifyMode: self.notifyMode)
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
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard self.mode == .other else { return }
        let yOffset = scrollView.contentOffset.y
        let scale = min(max(1.0 - yOffset / 125.0, 0.0), 1.0)
        self.lbDescription.alpha = scale
        self.bottomSpace.constant = 125 * scale
        self.imageBell.alpha = scale
        self.btnFollow.alpha = scale
        self.lbIcon.transform = CGAffineTransform(scaleX: scale, y: scale)
        self.iconHeight.constant = 50 * scale
        self.stackViewHeight.constant = 50 + 50 * scale
        
        self.viewIcon.cornerRadius = (self.iconHeight.constant - 5) / 2
        self.view.layoutIfNeeded()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard self.mode == .other else { return }
        let auto = self.bottomSpace.constant <= 50 && self.bottomSpace.constant != 0
        
        self.lbDescription.alpha = auto ? 0 : 1
        self.bottomSpace.constant = auto ? 0 : 125
        self.imageBell.alpha = auto ? 0 : 1
        self.btnFollow.alpha = auto ? 0 : 1
        self.lbIcon.transform = CGAffineTransform(scaleX: auto ? 0 : 1, y: auto ? 0 : 1)
        self.iconHeight.constant = auto ? 0 : 50
        self.stackViewHeight.constant = auto ? 150 : 100
        self.viewIcon.cornerRadius = auto ? 0 : 45 / 2
        self.view.layoutIfNeeded()
    }
}
// MARK: - SelectNotifyViewDelegate
extension CardHomeVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.notifyMode = newNotifymode
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[newNotifymode])
    }
}
