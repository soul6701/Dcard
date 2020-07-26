//
//  Drawer.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

protocol DrawerDelegate {
    func checkOutPage(page: Forum)
}
class Drawer: UIView {
    @IBOutlet weak var tableView: UITableView!
    
    private var forumList = [Forum]()
    private var delegate: DrawerDelegate?
    private var currentForum: Int?
    
    override func awakeFromNib() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    func setContent(forumList: [Forum]) {
        self.forumList = forumList.sorted(by: { (left, right) -> Bool in
            left.postCount > right.postCount
        })
    }
    func setDelegate(delegate: DrawerDelegate) {
        self.delegate = delegate
    }
}
extension Drawer: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return forumList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UINib(nibName: "ForumCell", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ForumCell
        cell.selectionStyle = .none
        cell.setContent(logo: forumList[indexPath.row].logo, forum: forumList[indexPath.row].name)
//        cell.textLabel?.text = forumList[indexPath.row].name
//        cell.imageView?.kf.setImage(with: URL(string: forumList[indexPath.row].logo))
        cell.backgroundColor = #colorLiteral(red: 0.99443084, green: 0.7995457053, blue: 0.987103045, alpha: 1)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //第一次打開抽屜 currentForum = nil
        guard let currentForum = currentForum else {
            tableView.cellForRow(at: indexPath)?.backgroundColor = #colorLiteral(red: 1, green: 0.6875414252, blue: 0.658618331, alpha: 1)
            delegate?.checkOutPage(page: forumList[indexPath.row])
            self.currentForum = indexPath.row
            return
        }
        //當選中頁面 = 目前頁面
        guard currentForum != indexPath.row else {
            return
        }
        //當選中頁面 != 目前頁面
        for cell in tableView.visibleCells {
            cell.backgroundColor = (tableView.indexPath(for: cell) == indexPath) ? #colorLiteral(red: 1, green: 0.6875414252, blue: 0.658618331, alpha: 1) : #colorLiteral(red: 0.99443084, green: 0.7995457053, blue: 0.987103045, alpha: 1)
        }
        self.currentForum = indexPath.row
        delegate?.checkOutPage(page: forumList[indexPath.row])
    }
}
