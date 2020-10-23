//
//  SettingView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/7.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol SettingViewDelegate {
    func changePoster(_ mode: PosterMode)
}
enum SettingViewMode {
    case commentSetting
    case posterSetting
}
enum PosterMode: Int {
    case school = 0
    case school_department
    case cardName
}
class SettingView: UIView {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var mode: SettingViewMode = .commentSetting
    private let user = ModelSingleton.shared.userConfig.user
    
    
    private var dataList: [String] {
        return mode == .commentSetting ? ["回應並標註 ", "複製", "檢舉", "我不喜歡這則回應"] : [self.user.card.school, self.user.card.school + " " + self.user.card.department, self.user.card.name]
    }
    private var floor = 0
    private var delegate: SettingViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        confiTableView()
        self.tableView.layer.cornerRadius = 20
    }
    func setContent(mode: SettingViewMode, floor: Int = 0) {
        self.mode = mode
        self.floor = floor
    }
    func setDelegate(_ delegate: SettingViewDelegate) {
        self.delegate = delegate
    }
    private func confiTableView() {
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
    }
}
// MARK: - UITableViewDelegate
extension SettingView: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
        let row = indexPath.row
        let data = self.dataList[row]
        cell.backgroundColor = .white
        cell.textLabel?.attributedText = NSAttributedString(string: (self.mode == .posterSetting ? data : (indexPath.row == 0 ? data + "B\(floor)": data)), attributes: [.font : UIFont.systemFont(ofSize: 12), .foregroundColor: UIColor.black])
        cell.selectionStyle = .none
        if self.mode == .commentSetting {
            cell.imageView?.image = nil
        } else {
            if row != 2 {
                cell.imageView?.image = UIImage(named: self.user.sex == "F" ? ImageInfo.pikachu : ImageInfo.carbi)
            } else {
                cell.imageView?.kf.setImage(with: URL(string: self.user.avatar))
            }
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.mode == .commentSetting ? 20 : 30
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if self.mode == .posterSetting {
            self.delegate?.changePoster(PosterMode(rawValue: row)!)
        }
    }
}
