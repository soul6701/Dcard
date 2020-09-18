//
//  MailAllVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class MailAllVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var friendList = [Card]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(friendList: [Card]) {
        self.friendList = friendList
    }
}
// MARK: - SetupUI
extension MailAllVC {
    private func initView() {
        confiNav()
        confiTableView()
    }
    private func confiNav() {
        self.navigationItem.title = "所有好友"
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "MailMainCell", bundle: nil), forCellReuseIdentifier: "MailMainCell")
    }
}
// MARK: - UITableViewDelegate
extension MailAllVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailMainCell", for: indexPath) as! MailMainCell
        cell.setContent(friendList: self.friendList)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        label.centerXAnchor.constraint(equalTo: <#T##NSLayoutAnchor<NSLayoutXAxisAnchor>#>, constant: <#T##CGFloat#>)
        label.attributedText = NSAttributedString(string: "所有好友", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemGray2])
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        100
//    }
}

