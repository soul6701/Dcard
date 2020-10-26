//
//  ReportVC.swift
//  Dcard
//
//  Created by Mason on 2020/10/26.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ReportVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var rowDataList = ["包含不雅字詞", "中傷、歧視、挑釁或謾罵他人", "交換個人資料", "大量濫用或惡意使用", "色情露點、性行為或血腥恐怖等讓人不舒服之內容", "廣告、商業宣傳之內容", "其他違規及違法的項目"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(self.closeReportView)), animated: false)
        self.navigationItem.title = "檢舉這個話題的原因"
    }
    @objc private func closeReportView() {
        dismiss(animated: true, completion: nil)
    }
}
extension ReportVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rowDataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        cell.textLabel?.text = self.rowDataList[indexPath.row]
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
