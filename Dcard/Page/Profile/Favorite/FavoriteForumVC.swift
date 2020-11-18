//
//  ViewController.swift
//  Dcard
//
//  Created by Mason on 2020/11/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit


protocol FavoriteForumVCDelegate {
    func filterForum(selectedForumNameList: [String])
}
class FavoriteForumCell: UITableViewCell {
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        self.accessoryType = selected ? .checkmark : .none
        self.textLabel?.textColor = selected ? #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78) : .label
    }
}
class FavoriteForumVC: UIViewController {
    lazy private var tableView: UITableView = self.confiTableView()
    lazy private var stackView: UIStackView = self.confiStackView()
    lazy private var btnList: [UIButton] = self.confiButtonList()
    lazy private var containerViewForBtnList: UIView = self.confiContainerViewForBtnList()
    
    private var forumList: [Forum] = ModelSingleton.shared.forum
    private var selectedCellList: [IndexPath : FavoriteForumCell] = [:]
    private var selectedForumNameList: [String] = []
    private var delegate: FavoriteForumVCDelegate?
    
    override func viewDidLoad() {
        initView()
    }
    func setContent(selectedForumNameList: [String]) {
        self.selectedForumNameList = selectedForumNameList
    }
    func setDelegate(_ delegate: FavoriteForumVCDelegate) {
        self.delegate = delegate
    }
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc private func apply() {
        let nameList: [String] = self.selectedCellList.map { return self.forumList[$0.key.row].name }
        self.delegate?.filterForum(selectedForumNameList: nameList)
        dismiss(animated: true, completion: nil)
    }
    @objc private func clearFilter() {
        self.selectedCellList.forEach { (_, cell) in
            cell.isSelected = false
        }
        self.selectedCellList.removeAll()
    }
}
// MARK: - UITableViewDelegate
extension FavoriteForumVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.forumList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let forum = self.forumList[row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavoriteForumCell", for: indexPath) as! FavoriteForumCell
        cell.textLabel?.text = forum.name
        cell.selectionStyle = .none
        return cell
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let forum = self.forumList[row]
        if self.selectedForumNameList.contains(forum.name) {
            self.selectedCellList[indexPath] = (cell as! FavoriteForumCell)
            cell.accessoryType = .checkmark
            cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! FavoriteForumCell
        self.selectedCellList[indexPath] = cell
        self.btnList[0].isEnabled = self.selectedCellList.count > 0
    }
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        self.selectedCellList[indexPath] = nil
        self.btnList[0].isEnabled = self.selectedCellList.count > 0
    }
}
// MARK: - SetupUI
extension FavoriteForumVC {
    private func initView() {
        self.navigationItem.title = "看板"
        self.navigationItem.setLeftBarButton(UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(close)), animated: false)
        self.navigationItem.setRightBarButton(UIBarButtonItem(title: "常用", style: .plain, target: self, action: #selector(apply)), animated: false)
        
        self.btnList[0].isEnabled = !self.selectedForumNameList.isEmpty
        
        self.view.setFixedView(self.tableView, inSafeArea: true)
        self.containerViewForBtnList.addSubview(self.stackView)
        self.view.addSubview(self.containerViewForBtnList)
        
        setConstraint()
    }
    private func confiButtonList() -> [UIButton] {
        var buttonList = [UIButton]()
        (0...1).forEach { (i) in
            let button = UIButton(type: .system)
            button.layer.cornerRadius = 10
            if i == 0 {
                button.setTitle("清除條件", for: .normal)
                button.backgroundColor = .clear
                button.setTitleColor(.darkGray, for: .normal)
                button.setTitleColor(.systemGray3, for: .disabled)
                button.addTarget(self, action: #selector(self.clearFilter), for: .touchUpInside)
            } else {
                button.setTitle("套用", for: .normal)
                button.backgroundColor = #colorLiteral(red: 0, green: 0.3294117647, blue: 0.5764705882, alpha: 0.78)
                button.setTitleColor(.white, for: .normal)
                button.addTarget(self, action: #selector(self.apply), for: .touchUpInside)
            }
            buttonList.append(button)
        }
        return buttonList
    }
    private func confiTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(FavoriteForumCell.self, forCellReuseIdentifier: "FavoriteForumCell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = true
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }
    private func confiStackView() -> UIStackView {
        let stackView = UIStackView(arrangedSubviews: self.btnList)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 5
        stackView.alignment = .fill
        return stackView
    }
    private func confiContainerViewForBtnList() -> UIView {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    private func setConstraint() {
        self.stackView.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(15)
            maker.trailing.equalToSuperview().offset(-15)
            maker.centerY.equalToSuperview()
            maker.height.equalTo(40)
        }
        self.containerViewForBtnList.snp.makeConstraints { (maker) in
            maker.bottom.equalTo(self.tableView.snp.bottom)
            maker.leading.equalTo(self.tableView.snp.leading)
            maker.trailing.equalTo(self.tableView.snp.trailing)
            maker.height.equalTo(80)
        }
    }
}
