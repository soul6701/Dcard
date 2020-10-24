//
//  SettingDetailVC.swift
//  Dcard
//
//  Created by admin on 2020/10/12.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum SettingDetailMode {
    case hideBoard
    case notifySetting
    case showTheme
    case autoPlayVedio
    
    var rowList: [String] {
        switch self {
        case .notifySetting:
            return ["關閉", "標註我的回應", "所有回應", "我的文章獲得心情", "我的回應獲得喜歡", "我的卡稱受到多人追蹤", "卡友來信"]
        case .showTheme:
            return ["根據系統設定", "淺色模式", "深色模式"]
        case .autoPlayVedio:
            return ["開啟", "關閉", "僅 Wi-Fi"]
        default:
            return []
        }
    }
    var sectionList: [String] {
        switch self {
        case .notifySetting:
            return ["我追蹤的文章有新回應", "其他論壇相關通知", "抽卡相關通知"]
        case .showTheme:
            return ["選擇主題"]
        case .autoPlayVedio:
            return ["自動播放影片"]
        default:
            return []
        }
    }
}
class SettingDetailVC: UIViewController {

    @IBOutlet weak var viewNotHideAnyBoard: UIView!
    @IBOutlet weak var tableView: UITableView!
    private var navigationItemTitle = ""
    private var mode: SettingDetailMode = .autoPlayVedio
    private var sectionList = [String]()
    private var rowList = [String]()
    private var preference = Preference()
    private var state: Int {
        switch self.mode {
        case .notifySetting:
            return self.preference.newReply
        case .autoPlayVedio:
            return self.preference.autoPlayVedio
        case .showTheme:
            return self.preference.showTheme
        default:
            return 0
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(mode: SettingDetailMode, title: String) {
        self.mode = mode
    }
}
// MARK: - SetupUI
extension SettingDetailVC {
    private func initView() {
        self.preference = ModelSingleton.shared.preference
        self.sectionList = self.mode.sectionList
        self.rowList = self.mode.rowList
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        self.tableView.isHidden = self.mode == .hideBoard
        self.tableView.showsVerticalScrollIndicator = false
        self.viewNotHideAnyBoard.isHidden = self.mode != .hideBoard
        self.navigationItem.title = self.navigationItemTitle
    }
}
// MARK: - Private Handler
extension SettingDetailVC {
    @objc private func toggle(_ sender: UISwitch) {
        let tag = sender.tag
        let isON = sender.isOn
        switch tag {
        case 3:
            preference.getMood = isON
        case 4:
            preference.getLiked = isON
        case 5:
            preference.getFollowed = isON
        default:
            preference.newMail = isON
        }
        ProfileManager.shared.saveToDataBase(preference: preference)
    }
}
// MARK: - UITableViewDelegate
extension SettingDetailVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sectionList.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch self.mode {
        case .notifySetting:
            return section == 0 ? 3 : (section == 1 ? 3 : 1)
        default:
            return self.rowList.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        switch self.mode {
        case .hideBoard:
            return UITableViewCell()
        case .notifySetting:
            if section == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                cell.textLabel?.text = self.rowList[row]
                cell.textLabel?.textColor = row == self.state ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .label
                cell.accessoryType = row == self.state ? .checkmark : .none
                return cell
            } else {
                let _row = section == 1 ? row + 3 : row + 6
                let switchButton = UISwitch()
                switchButton.tag = _row
                switchButton.onTintColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
                switchButton.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
                let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
                switch _row {
                case 3:
                    switchButton.isOn = self.preference.getMood
                case 4:
                    switchButton.isOn = self.preference.getLiked
                case 5:
                    switchButton.isOn = self.preference.getFollowed
                default:
                    switchButton.isOn = self.preference.newMail
                }
                cell.textLabel?.text = self.rowList[_row]
                cell.accessoryView = switchButton
                cell.selectionStyle = .none
                return cell
            }
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            cell.textLabel?.text = self.rowList[row]
            cell.textLabel?.textColor = row == self.state ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .label
            cell.accessoryType = row == self.state ? .checkmark : .none
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section == 0 else { return }
        let row = indexPath.row
        switch self.mode {
        case .showTheme:
            preference.showTheme = row
            let scene = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate
            scene?.window?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: row) ?? .unspecified
        case .autoPlayVedio:
            preference.autoPlayVedio = row
        case .notifySetting:
            preference.newReply = row
        default:
            break
        }
        ProfileManager.shared.saveToDataBase(preference: preference)
        self.tableView.reloadSections([0], with: .automatic)
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sectionList[section]
    }
}
