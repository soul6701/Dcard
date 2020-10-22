//
//  ProfileThreeCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

struct ProfileThreeCellInCell {
    var name: String
    var image: UIImage
}

enum ProfileThreeCellType: Int {
    case favorites = 0
    case followIssue
    case followCard
    case artical
    case introduce
    case myCard
    case mail
    case setting
    
    var cell: ProfileThreeCellInCell {
        var _cell = ProfileThreeCellInCell(name: "", image: UIImage())
        switch self {
        case .favorites:
            _cell = ProfileThreeCellInCell(name: "我的收藏", image: UIImage(named: "finn")!)
        case .followIssue:
            _cell = ProfileThreeCellInCell(name: "我追蹤的話題", image: UIImage(named: "ironman")!)
        case .followCard:
            _cell = ProfileThreeCellInCell(name: "我追蹤的卡稱", image: UIImage(named: "millennium")!)
        case .artical:
            _cell = ProfileThreeCellInCell(name: "我發表的文章", image: UIImage(named: "simpson")!)
        case .introduce:
            _cell = ProfileThreeCellInCell(name: "抽卡自我介紹", image: UIImage(named: "naruto")!)
        case .myCard:
            _cell = ProfileThreeCellInCell(name: "我的卡稱", image: UIImage(named: "stich")!)
        case .mail:
            _cell = ProfileThreeCellInCell(name: "我的信件", image: UIImage(named: "supermario")!)
        case .setting:
            _cell = ProfileThreeCellInCell(name: "設定", image: UIImage(named: "settings")!)
        }
        return _cell
    }
    var vcName: String {
        var _vcName = ""
        switch self {
        case .favorites:
            _vcName = "FavoriteVC"
        case .followIssue:
            _vcName = "FollowIssueVC"
        case .followCard:
            _vcName = "FollowCardVC"
        case .artical:
            _vcName = "ArticalVC"
        case .introduce:
            _vcName = "IntroduceVC"
        case .myCard:
            _vcName = "MyCardVC"
        case .mail:
            _vcName = "MailVC"
        case .setting:
            _vcName = "SettingVC"
        }
        return _vcName
    }
}
class ProfileThreeCell: UITableViewCell {

    @IBOutlet var tableView: UITableView!
    private var isNew = true //有新信件未讀
    private var favoriteList = [Favorite]()
    private var followIssueList = [FollowIssue]()
    private var followCardList = [FollowCard]()
    private var mail = [Mail]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.selectionStyle = .none
        self.tableView.register(UINib(nibName: "ProfileThreeTbCell", bundle: nil), forCellReuseIdentifier: "ProfileThreeTbCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        self.tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    func setContent(isNew: Bool) {
        self.isNew = isNew
        self.tableView.reloadData()
    }
}
// MARK: - UITableViewDelegate
extension ProfileThreeCell: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 8
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileThreeTbCell", for: indexPath) as! ProfileThreeTbCell
        if let type = ProfileThreeCellType(rawValue: indexPath.row) {
            cell.setContent(type: type, name: type.cell.name, image: type.cell.image, isNew: type == .mail ? self.isNew : false)
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellType = ProfileThreeCellType.init(rawValue: indexPath.row)!
        ProfileManager.shared.toNextPage(next: cellType)
    }
}
