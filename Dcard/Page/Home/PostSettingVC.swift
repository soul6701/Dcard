//
//  PostSettingVC.swift
//  Dcard
//
//  Created by admin on 2020/10/21.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class PostSettingVC: UITableViewController {

    init(host: Bool) {
        super.init(style: .plain)
        self.host = host
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var host = false
    
    private var dataList: [String] {
        return host ? ["分享", "轉貼到其他看板", "引用原文發文", "關閉文章通知", "刪除文章", "編輯文章", "編輯話題", "複製全文", "重新整理", "我不喜歡這篇文章"] :
            ["分享", "轉貼到其他看板", "引用原文發文", "開啟文章通知", "檢舉文章", "複製全文", "重新整理", "我不喜歡這篇文章"]
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.isScrollEnabled = false
        self.tableView.separatorStyle = .none
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = self.dataList[indexPath.row]
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
}
