//
//  SelectCountryVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/26.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift

struct Country {
    var name: String
    var code: String
    var alias: String
    
    init(name: String, alias: String, code: String) {
        self.name = name
        self.alias = alias
        self.code = code
    }
}
enum ContentMode {
    case result
    case common
}
protocol SelectCountryVCDelegate {
    func didSelectCountry(country: Country)
}
class SelectCountryVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    private var delegate: SelectCountryVCDelegate?
    private var hideStatusBar = false
    var mode: ContentMode = .common
    var mainCountryList = [Country]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var otherCountryList = [Country]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    var countryList: [[Country]] {
        var list = [[Country]]()
        list.append(mainCountryList)
        list.append(otherCountryList)
        return list
    }
    var resultList = [Country]() {
        didSet {
            self.mode = .result
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    override var prefersStatusBarHidden: Bool {
        return self.hideStatusBar
    }
    func setDelegate(delegate: SelectCountryVCDelegate) {
        self.delegate = delegate
    }
    func setHideStatusBar(_ hide: Bool) {
        self.hideStatusBar = hide
    }
}
// MARK: - SetupUI
extension SelectCountryVC {
    private func initView() {
        self.navigationItem.title = "選擇國家 / 地區"
        let btnBack = UIButton(type: .system)
        btnBack.setTitle("取消", for: .normal)
        btnBack.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        self.navigationItem.setLeftBarButton(UIBarButtonItem(customView: btnBack), animated: false)
        confiSearchBar()
        confiTableView()
        getCountryList()
        
    }
    private func confiTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    private func confiSearchBar() {
        self.searchBar.delegate = self
    }
    private func getCountryList() {
        var _mainCountryList = [Country]()
        var _otherCountryList = [Country]()
        
        LoginManager.shared.getCountryCode { (userinfoCountryCode, idToCountrycode) in
            userinfoCountryCode.keys.forEach { (key) in
                if key != "0" {
                    var code = ""
                    var name = ""
                    let code_regex = try! NSRegularExpression(pattern: "\\d+")
                    guard let value = userinfoCountryCode[key], !value.isEmpty else {
                        return
                    }
                    if let first = code_regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) {
                        print("🐶🐶🐶\(first)🐶🐶🐶")
                        code = (value as NSString).substring(with: first.range)
                    }
                    let name_regex = try! NSRegularExpression(pattern: "\\S+")
                    if let first = name_regex.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) {
                        name = (value as NSString).substring(with: first.range)
                        print(name)
                    }
                    if name == "美國" || name == "台灣" || name == "中國" || name == "韓國" || name == "法國" {
                        _mainCountryList.append(Country(name: name, alias: key, code: code))
                    } else {
                        _otherCountryList.append(Country(name: name, alias: key, code: code))
                    }
                }
            }
        }
        
//        (1...6).forEach { (i) in
//            _mainCountryList.append(Country(name: "台灣", alias: "TW", code: "+86"))
//        }
//        let list = [Country(name: "台中", alias: "TC", code: "+1"), Country(name: "美國", alias: "US", code: "+2"), Country(name: "台南", alias: "TN", code: "+3"), Country(name: "台東", alias: "TD", code: "+4")]
//        (1...100).forEach { (i) in
//            if let random = list.randomElement() {
//                _otherCountryList.append(Country(name: random.name, alias:  random.alias, code: random.code))
//            }
//        }
        self.mainCountryList = _mainCountryList
        self.otherCountryList = _otherCountryList
    }
    @objc private func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func closeKeyboard() {
        self.searchBar.endEditing(true)
    }
}
// MARK: - UITableViewDelegate
extension SelectCountryVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.mode == .common ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mode == .common ? self.countryList[section].count : self.resultList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        
        let cell = UITableViewCell()
        let lbName = UILabel()
        lbName.textAlignment = .left
        lbName.text = self.mode == .common ? self.countryList[section][row].name : self.resultList[row].name
        let lbCode = UILabel()
        lbCode.textAlignment = .right
        lbCode.textColor = .lightGray
        lbCode.text = self.mode == .common ? countryList[section][row].code : self.resultList[row].code
        let stackView = UIStackView(arrangedSubviews: [lbName, lbCode])
        stackView.alignment = .fill
        stackView.axis = .horizontal
        stackView.distribution = .fill
        lbCode.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 6).isActive = true
        
        cell.addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.leadingAnchor.constraint(equalTo: cell.leadingAnchor, constant: 20).isActive = true
        stackView.trailingAnchor.constraint(equalTo: cell.trailingAnchor, constant: -20).isActive = true
        stackView.topAnchor.constraint(equalTo: cell.topAnchor).isActive = true
        stackView.bottomAnchor.constraint(equalTo: cell.bottomAnchor).isActive = true
        
        return cell
    }
    //自定義header
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let view = UIView()
//        view.backgroundColor = .systemGray2
//        let lbTitle = UILabel()
//        lbTitle.textAlignment = .center
//        lbTitle.attributedText = NSAttributedString(string: "所有國家 / 地區", attributes: [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 22)])
//        view.addSubview(lbTitle)
//        lbTitle.translatesAutoresizingMaskIntoConstraints = false
//        lbTitle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 22).isActive = true
//        lbTitle.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -10).isActive = true
//        lbTitle.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
//        lbTitle.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
//
//        return section == 0 ? nil : view
//    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.mode == .common ? section == 0 ? CGFloat.leastNonzeroMagnitude : 40 : CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.mode == .common ? section == 1 ? "所有國家 / 地區" : nil : nil
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.delegate?.didSelectCountry(country: mode == .common ? self.countryList[indexPath.section][indexPath.row] : self.resultList[indexPath.row])
        self.dismiss(animated: true, completion: nil)
    }
}
// MARK: - UISearchBarDelegate
extension SelectCountryVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        self.searchBar.setShowsCancelButton(true, animated: true)
        self.resultList = [Country]()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.searchBar.setShowsCancelButton(false, animated: true)
        self.mode = .common
        self.tableView.reloadData()
        closeKeyboard()
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var list = [Country]()
        self.countryList.forEach { (countrys) in
            countrys.forEach { (country) in
                if let text = searchBar.text, country.name.contains(text) {
                    list.append(country)
                }
            }
        }
        self.resultList = list
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        closeKeyboard()
    }
}
