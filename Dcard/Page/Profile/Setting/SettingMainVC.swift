//
//  SettingMainVC.swift
//  Dcard
//
//  Created by admin on 2020/10/8.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class SubtitleTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class RightDetailTableViewCell: UITableViewCell {

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
class SettingMainVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var sectionTitleList = ["帳號", "偏好設定", "關於ChaiCard", "意見回饋", ""]
    private var rowTitleList = [["常用信箱", "個人身份驗證", "Facebook 帳號連結", "google帳號連結", "Apple帳號連結", "修改密碼", "所在國家/地區"], ["全部熱門隱藏看板設定", "推播通知設定", "使用 Touch ID解鎖我的文章", "顯示主題" , "自動播放影片", "清除圖片快取"], ["Facebook 粉絲專頁", "instagram 官方帳號", "聯絡客服", "常見問題" , "服務條款", "版本"]]
    private var logoutTitleList = ["登出其他裝置", "登出"]
    private var preference = Preference() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var heart = 0
    private var country = Country(name: "", alias: "", code: "")
    private var address = ""
    private var isVerified = false
    private var facebookIsConnected = false
    private var googleIsConnected = false
    private var appleIsConnected = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ToolbarView.shared.show(false)
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.preference = ModelSingleton.shared.preference
    }
}
// MARK: - SetupUI
extension SettingMainVC {
    private func initView() {
        confiTableView()
        confiNav()
        
        let user = ModelSingleton.shared.userConfig.user
        self.country = user.country
        self.address = user.address
        self.isVerified = user.isVerified
        self.facebookIsConnected = user.facebookIsConnected
        self.googleIsConnected = user.googleIsConnected
        self.appleIsConnected = user.appleIsConnected
    }
    private func confiTableView() {
        self.tableView.showsVerticalScrollIndicator = false
        self.tableView.register(UINib(nibName: "FeedbackCell", bundle: nil), forCellReuseIdentifier: "FeedbackCell")
        self.tableView.register(SubtitleTableViewCell.self, forCellReuseIdentifier: "SubtitleCell")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "CommonCell")
        self.tableView.register(RightDetailTableViewCell.self, forCellReuseIdentifier: "RightDetailCell")
    }
    private func confiNav() {
        self.navigationItem.title = "設定"
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
}
// MARK: - Private Func
extension SettingMainVC {
    private func confiRightDetailTableViewCell(_ isOK: Bool, title: String, textState: (String, String), cell: RightDetailTableViewCell) {
        cell.textLabel?.text = title
        if isOK {
            cell.tintColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0, green: 0.5603182912, blue: 0, alpha: 1)
            cell.detailTextLabel?.text = textState.0
            cell.accessoryType = .checkmark
        } else {
            cell.tintColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
            cell.detailTextLabel?.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
            cell.detailTextLabel?.text = textState.1
            cell.accessoryType = .disclosureIndicator
        }
    }
    private func resetRightDetailTableViewCell(cell: RightDetailTableViewCell) {
        cell.tintColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        cell.detailTextLabel?.textColor = #colorLiteral(red: 0.5704585314, green: 0.5704723597, blue: 0.5704649091, alpha: 1)
        cell.detailTextLabel?.text = ""
        cell.accessoryType = .none
    }
    private func openCountrySetting() {
        let vc = SelectCountryVC()
        vc.setDelegate(self)
        let nav = UINavigationController(rootViewController: vc)
        nav.modalPresentationStyle = .fullScreen
        nav.modalTransitionStyle = .crossDissolve
        self.present(nav, animated: true)
    }
    @objc private func toggle(_ sender: UISwitch) {
        self.preference.touchIDOn = sender.isOn
        ProfileManager.shared.saveToDataBase(preference: preference)
    }
}
// MARK: - UITableViewDelegate
extension SettingMainVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section <= 2 ? rowTitleList[section].count : section == 3 ? 1 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        if section <= 2 {
            let title = rowTitleList[section][row]
            if section == 0 {
                switch row {
                case 0:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "SubtitleCell", for: indexPath) as! SubtitleTableViewCell
                    cell.textLabel?.text = title
                    cell.detailTextLabel?.text = self.address
                    cell.accessoryType = .disclosureIndicator
                case 1:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                    confiRightDetailTableViewCell(self.isVerified, title: title, textState: ("驗證完成", "待驗證"), cell: cell)
                    return cell
                case 2, 3, 4:
                    let isOK = row == 2 ? self.facebookIsConnected : (row == 3 ? self.googleIsConnected : self.appleIsConnected)
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                    confiRightDetailTableViewCell(isOK, title: title, textState: ("已啟用", "尚未啟用"), cell: cell)
                    return cell
                case 6:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                    resetRightDetailTableViewCell(cell: cell)
                    cell.textLabel?.text = title
                    cell.detailTextLabel?.text = self.country.alias
                    cell.accessoryType = .disclosureIndicator
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                    cell.textLabel?.text = title
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            } else if section == 1 {
                switch row {
                case 2:
                    let switchButton = UISwitch()
                    switchButton.onTintColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
                    switchButton.isOn = self.preference.touchIDOn
                    switchButton.addTarget(self, action: #selector(toggle(_:)), for: .valueChanged)
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                    cell.textLabel?.text = title
                    cell.accessoryView = switchButton
                    return cell
                case 3, 4:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                    resetRightDetailTableViewCell(cell: cell)
                    cell.textLabel?.text = title
                    cell.detailTextLabel?.text = row == 3 ? self.preference.themeToString : self.preference.autoPlayVedioToString
                    cell.accessoryType = .disclosureIndicator
                    return cell
                case 5:
                    let button = UIButton(type: .custom)
                    button.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
                    button.setTitleColor(#colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78), for: .normal)
                    button.setTitle("清除", for: .normal)
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                    cell.selectionStyle = .none
                    cell.textLabel?.text = title
                    cell.accessoryView = button
                    return cell
                default:
                    let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                    cell.textLabel?.text = title
                    cell.accessoryType = .disclosureIndicator
                    return cell
                }
            } else {
                guard row != 5 else {
                    let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
                    let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetailCell", for: indexPath) as! RightDetailTableViewCell
                    resetRightDetailTableViewCell(cell: cell)
                    cell.textLabel?.text = title
                    cell.detailTextLabel?.text = appVersion
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "CommonCell", for: indexPath)
                cell.textLabel?.text = title
                cell.accessoryType = .disclosureIndicator
                return cell
            }
        } else if section == 3 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "FeedbackCell", for: indexPath) as! FeedbackCell
            cell.setContent(heart: self.heart)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.textAlignment = .center
            cell.textLabel?.text = logoutTitleList[row]
            cell.textLabel?.textColor = row == 0 ? .link : .systemRed
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
       
        if section <= 2 {
            let title = rowTitleList[section][row]
            switch section {
            case 0:
                switch row {
                case 0:
                    let vc = SettingAccountVC()
                    vc.setContent(mode: .setAddress, title: title)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 5:
                    let vc = SettingAccountVC()
                    vc.setContent(mode: .resetPassword, title: title)
                    self.navigationController?.pushViewController(vc, animated: true)
                case 6:
                    openCountrySetting()
                default:
                    break
                }
            case 1:
                switch row {
                case 0, 1, 3, 4:
                    var mode: SettingDetailMode! {
                        switch row {
                        case 0:
                            return .hideBoard
                        case 1:
                            return .notifySetting
                        case 3:
                            return .showTheme
                        default:
                            return .autoPlayVedio
                        }
                    }
                    let vc = SettingDetailVC()
                    vc.setContent(mode: mode, title: title)
                    self.navigationController?.pushViewController(vc, animated: true)
                default:
                    break
                }
            default:
                break
            }
        } else if section == 4 {
            guard let nav = self.navigationController else { return }
            for vc in nav.viewControllers where vc is LoginVC {
                self.navigationController?.popToViewController(vc, animated: true)
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 3 ? 150 : 50
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleList[section]
    }
}
// MARK: - FeedbackCellDelegate
extension SettingMainVC: FeedbackCellDelegate {
    func saveHeart(_ value: Int) {
        self.heart = value
    }
}
// MARK: - SelectCountryVCDelegate
extension SettingMainVC: SelectCountryVCDelegate {
    func didSelectCountry(country: Country) {
        self.country = country
        self.tableView.reloadRows(at: [IndexPath(row: 6, section: 0)], with: .automatic)
    }
}
