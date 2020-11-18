//
//  PostSettingVC.swift
//  Dcard
//
//  Created by admin on 2020/10/21.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol PostSettingVCDelegate {
    func showAddFavoriteListOKView(title: String)
    func createFavoriteListAndInsert(title: String)
}
class PostSettingVC: UIViewController {
    enum PostSettingMode {
        case keep
        case setting
    }
    
    lazy private var tableView: UITableView = self.confiTableView()
    lazy private var lbTitle: UILabel = self.confiLbTitle()
    private var host: String = ""
    private var mode: PostSettingMode = .setting
    private var disposeBag = DisposeBag()
    private var delegate: PostSettingVCDelegate?
    private var post: Post = Post()
    private var viewModel: PostVMInterface!
    
    private var settingDataList: [String] {
        return host == ModelSingleton.shared.userConfig.user.uid ? ["分享", "轉貼到其他看板", "引用原文發文", "關閉文章通知", "刪除文章", "編輯文章", "編輯話題", "複製全文", "重新整理", "我不喜歡這篇文章"] :
            ["分享", "轉貼到其他看板", "引用原文發文", "開啟文章通知", "檢舉文章", "複製全文", "重新整理", "我不喜歡這篇文章"]
    }
    private var keepDataList: [Favorite] = ModelSingleton.shared.favorite
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(post: Post, mode: PostSettingMode, host: String = "") {
        self.post = post
        self.mode = mode
        self.host = host
    }
    func setDelegate(_ delegate: PostSettingVCDelegate) {
        self.delegate = delegate
    }
}
// MARK: - SetupUI
extension PostSettingVC {
    private func initView() {
        self.view.backgroundColor = #colorLiteral(red: 0.8321695924, green: 0.985483706, blue: 0.4733308554, alpha: 0.8150684932)
        if self.mode == .keep {
            self.view.addSubview(self.lbTitle)
            self.lbTitle.snp.makeConstraints { (maker) in
                maker.top.leading.trailing.equalToSuperview()
                maker.height.equalTo(70)
            }
            self.view.addSubview(self.tableView)
            self.tableView.snp.makeConstraints { (maker) in
                maker.top.equalTo(self.lbTitle.snp.bottom).offset(5)
                maker.leading.trailing.equalToSuperview()
                maker.bottom.equalToSuperview()
            }
        } else {
            self.view.addSubview(self.tableView)
            self.tableView.snp.makeConstraints { (maker) in
                maker.bottom.leading.trailing.equalToSuperview()
                maker.top.equalToSuperview().offset(20)
            }
        }
    }
    private func confiTableView() -> UITableView {
        let tableView = UITableView()
        tableView.register(PostSettingCell.self, forCellReuseIdentifier: "PostSettingCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = self.mode == .keep
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }
    private func confiLbTitle() -> UILabel {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "已收藏，試試將文章加入...", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }
}
// MARK: - UITableViewDelegate
extension PostSettingVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mode == .keep ? 1 + self.keepDataList.count : self.settingDataList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostSettingCell", for: indexPath) as! PostSettingCell
        
        var isSystemImage: Bool
        var title: String
        var image: String
        if self.mode == .keep {
            if row == 0 {
                isSystemImage = true
                title = "建立收藏分類"
                image = "plus"
            } else {
                isSystemImage = false
                title = self.keepDataList[row - 1].title
                let favorite = self.keepDataList[row - 1]
                let mediaMeta = favorite.coverImage.first ?? ""
                image =  mediaMeta
            }
        } else {
            isSystemImage = true
            title = self.settingDataList[indexPath.row]
            image = "book.fill"
        }
        cell.setContent(isSystemImage: isSystemImage, image: image, title: title)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return UIView()
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        if self.mode == .keep {
            if row == 0 {
                UIAlertController.showNewFavoriteCatolog(self, cancelHandler: {
                    self.dismiss(animated: true, completion: nil)
                }, OKHandler: { (text) in
                    self.delegate?.createFavoriteListAndInsert(title: text)
                }, disposeBag: self.disposeBag)
            } else {
                let favorite = self.keepDataList[row - 1]
                self.delegate?.showAddFavoriteListOKView(title: favorite.title)
            }
        } else {
            let vc = UIActivityViewController(activityItems: [self.post.title], applicationActivities: nil)
            vc.completionWithItemsHandler = { (_, completed, _, error) in
                if let error = error {
                    AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
                }
                if completed {
                    AlertManager.shared.showOKView(mode: .profile(.shareCardInfoAndIssueInfo), handler: nil)
                }
            }
        }
    }
}
