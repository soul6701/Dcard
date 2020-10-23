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
    private var mailList = [Mail]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(mailList: [Mail]) {
        self.mailList = mailList
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
        cell.setContent(mailList: self.mailList)
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let label = UILabel()
        view.backgroundColor = .systemGray5
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        label.snp.makeConstraints { (maker) in
            maker.left.equalToSuperview().offset(30)
            maker.height.equalTo(10)
            maker.centerY.equalToSuperview()
        }
        label.attributedText = NSAttributedString(string: "所有好友", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        return view
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.bounds.height
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
}
