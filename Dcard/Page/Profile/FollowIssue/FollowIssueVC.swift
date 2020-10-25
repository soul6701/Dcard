//
//  FollowIssueVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol FollowIssueVCDelegate {
    func showBellModeView(index: Int, followIssue: FollowIssue)
    func cancelFollowIssue(index: Int, followIssue: FollowIssue)
    
}
class FollowIssueVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var followIssueList = [FollowIssue]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ToolbarView.shared.show(false)
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    func setContent(followIssueList: [FollowIssue], title: String) {
        self.followIssueList = followIssueList
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension FollowIssueVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "FollowIssueCell", bundle: nil), forCellReuseIdentifier: "FollowIssueCell")
    }
}
// MARK: - UITableViewDelegate
extension FollowIssueVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.followIssueList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            return cell
        }
        
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowIssueCell", for: indexPath) as! FollowIssueCell
        cell.setContent(index: row, followIssue: self.followIssueList[row])
        cell.setDelegate(self)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 120
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let vc = FollowIssueInfoVC()
        vc.setContent(followIssue: self.followIssueList[row])
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
// MARK: - FollowIssueVCDelegate
extension FollowIssueVC: FollowIssueVCDelegate {
    func showBellModeView(index: Int, followIssue: FollowIssue) {
        self.selectedIndex = index
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: followIssue.notifyMode)
    }
    func cancelFollowIssue(index: Int, followIssue: FollowIssue) {
        ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + followIssue.listName + "」？") {
            self.followIssueList.remove(at: index)
            self.tableView.reloadData()
            ProfileManager.shared.showOKView(mode: .cancelFollowIssue, handler: nil)
        }
    }
}
// MARK: - SelectNotifyViewDelegate
extension FollowIssueVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.followIssueList[self.selectedIndex].notifyMode = newNotifymode
        self.tableView.reloadData()
    }
}
