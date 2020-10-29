//
//  ProfileVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ProfileVC: UIViewController {

    @IBOutlet var bottomSpace: NSLayoutConstraint!
    @IBOutlet weak var tableViewMain: UITableView!
    
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    private var card: Card {
        return ModelSingleton.shared.userCard
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableViewMain.reloadData()
        ToolbarView.shared.show(true)
    }
}
// MARK: - SetupUI
extension ProfileVC {
    private func initView() {
        ProfileManager.shared.setBaseNav(self.navigationController!)
        self.navigationItem.title = ""
        self.bottomSpace.constant = Size.bottomSpace
        confiTableView()
    }
    private func confiTableView() {
        self.tableViewMain.register(UINib(nibName: "ProfileOneCell", bundle: nil), forCellReuseIdentifier: "ProfileOneCell")
        self.tableViewMain.register(UINib(nibName: "ProfileTwoCell", bundle: nil), forCellReuseIdentifier: "ProfileTwoCell")
        self.tableViewMain.register(UINib(nibName: "ProfileThreeCell", bundle: nil), forCellReuseIdentifier: "ProfileThreeCell")
    }
}
// MARK: - UITableViewDelegate
extension ProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        switch row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileOneCell", for: indexPath) as! ProfileOneCell
            cell.setContent(name: self.user.lastName + self.user.firstName, school: self.card.school, department: self.card.department, avatar: self.user.avatar)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileTwoCell", for: indexPath) as! ProfileTwoCell
            cell.setContent(postCount: self.card.post.count, replyCount: self.card.comment.count, KeepedCount: self.card.beKeeped)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileThreeCell", for: indexPath) as! ProfileThreeCell
            cell.setContent(isNew: true)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        switch row {
        case 0:
            return 120
        case 1:
            return 60
        default:
            return self.tableViewMain.bounds.height - 120 - 60
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if row == 1 {
            let vc = UIStoryboard.profile.profilePostVC
            self.navigationController?.pushViewController(vc, animated: true) {
                self.navigationController?.setNavigationBarHidden(false, animated: false)
            }
        }
    }
}
