//
//  SettingView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/7.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class SettingView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let items = ["回應並標註 ", "複製", "檢舉", "我不喜歡這則回應"]
    private var floor = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(floor: Int) {
        self.floor = floor
    }
}
extension SettingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.attributedText = NSAttributedString(string: indexPath.row == 0 ? items[indexPath.row] + "B\(floor)": items[indexPath.row], attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 12)])
        cell.contentView.backgroundColor = .white
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 20
    }
}
