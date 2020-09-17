//
//  FollowCardVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit


protocol FollowCardVCDelegate {
    func showBellModeView(index: Int, followCard: FollowCard)
    func cancelFollowCard(index: Int, followCard: FollowCard)
    func toCardHome(followCard: FollowCard)
}
class FollowCardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var followCardList = [FollowCard]() {
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
    func setContent(followCardList: [FollowCard], title: String) {
        self.followCardList = followCardList
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension FollowCardVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "FollowCardCell", bundle: nil), forCellReuseIdentifier: "FollowCardCell")
    }
}
// MARK: - UITableViewDelegate
extension FollowCardVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.followCardList.count : 1
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCardCell", for: indexPath) as! FollowCardCell
        cell.setContent(index: row, followCard: followCardList[indexPath.row])
        cell.setDelegate(self)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 120
    }
}
// MARK: - FollowCardVCDelegate
extension FollowCardVC: FollowCardVCDelegate {
    func showBellModeView(index: Int, followCard: FollowCard) {
        self.selectedIndex = index
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: followCard.notifyMode)
    }
    func cancelFollowCard(index: Int, followCard: FollowCard) {
        ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + followCard.card.name + "」？") {
            self.followCardList.remove(at: index)
            self.tableView.reloadData()
            ProfileManager.shared.showOKView(mode: .cancelFollowCard, handler: nil)
        }
    }
    func toCardHome(followCard: FollowCard) {
        let vc = CardHomeVC()
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension FollowCardVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.followCardList[self.selectedIndex].notifyMode = newNotifymode
        self.tableView.reloadData()
    }
}
