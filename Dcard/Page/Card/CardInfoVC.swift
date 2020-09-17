//
//  CardInfoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum CellType: Int {
    case birthday = 1
    case love
    case article
    case country
    case introduce
    
    var titel: String {
        switch self {
        case .article:
            return "我的文章"
        case .country:
            return "國家"
        case .introduce:
            return "簡介"
        case .birthday:
            return "生日"
        case .love:
            return "感情狀態"
        }
    }
}

class CardInfoVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var isFriend = false {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var isUser = false
    private var card: Card?
    private var delegate: CardVCDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        ToolbarView.shared.show(false)
    }
    func setContent(card: Card, isUser: Bool = false) {
        self.card = card
        self.isUser = isUser
    }
    func setDelegate(_ delegate: CardVCDelegate) {
        self.delegate = delegate
    }
}
extension CardInfoVC {
    private func initView() {
        confiNav()
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "CardInfoCell", bundle:
            nil), forCellReuseIdentifier: "CardInfoCell")
        self.tableView.register(UINib(nibName: "CardInfoTitleCell", bundle:
        nil), forCellReuseIdentifier: "CardInfoTitleCell")
        self.tableView.register(UINib(nibName: "CardSendCell", bundle: nil), forCellReuseIdentifier: "CardSendCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 15
    }
    private func confiNav() {
        self.navigationItem.title = "今日 ChiaCard"
        let btnHint = UIButton(type: .infoLight)
        btnHint.addTarget(self, action: #selector(alert), for: .touchUpInside)
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: btnHint), animated: true)
    }
    @objc private func alert() {
        //
    }
}
// MARK: - UITableViewDelegate
extension CardInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.isUser ? 6 : isFriend ? 7 : 5
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row != 0 {
            if self.isFriend || self.isUser {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CardInfoCell") as? CardInfoCell {
                    if row == 1 {
                        cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.birthday ?? "")
                    } else if row == 2 {
                        cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.love ?? "")
                    } else if row == 3 {
                        cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.article ?? "")
                    } else if row == 4 {
                        cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.country ?? "")
                    } else if row == 5 {
                        cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.introduce ?? "")
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "CardSendCell") as? CardSendCell {
                            cell.becomeFriend()
                            return cell
                        }
                    }
                    return cell
                }
            } else {
                if let cell = tableView.dequeueReusableCell(withIdentifier: "CardInfoCell") as? CardInfoCell {
                    if row == 1 {
                        cell.setContent(title: CellType(rawValue: row + 2)?.titel ?? "", content: card?.article ?? "")
                    } else if row == 2 {
                        cell.setContent(title: CellType(rawValue: row + 2)?.titel ?? "", content: card?.country ?? "")
                    } else if row == 3 {
                        cell.setContent(title: CellType(rawValue: row + 2)?.titel ?? "", content: card?.introduce ?? "")
                    } else {
                        if let cell = tableView.dequeueReusableCell(withIdentifier: "CardSendCell") as? CardSendCell {
                            cell.setDelegate(delegate: self)
                            return cell
                        }
                    }
                    return cell
                }
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CardInfoTitleCell") as? CardInfoTitleCell {
                cell.setContent(card: self.card ?? Card(), isUser: self.isUser)
                return cell
            }
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.isFriend && indexPath.row == 6 {
            return 120
        }
        if indexPath.row == 4 {
            return 80
        }
        return UITableView.automaticDimension
    }
}
// MARK: - CardSendCellDelegate
extension CardInfoVC: CardSendCellDelegate {
    func didClickBtnSend() {
        self.isFriend = true
        self.delegate?.addFriend(name: self.card?.name ?? "")
    }
}
