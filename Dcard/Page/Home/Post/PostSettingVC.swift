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

enum PostSettingMode {
    case keep
    case setting
}
protocol PostSettingCellDelegate {
    func showAddFavoriteListOKView(title: String)
}
private class PostSettingCell: UITableViewCell {
    
    lazy private var lbTitle: UILabel = {
        let label = UILabel()
        return label
    }()
    lazy private var imageViewCatalog: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 20
        return imageView
    }()
    override func layoutSubviews() {
        self.backgroundColor = .clear
        self.addSubview(self.imageViewCatalog)
        self.imageViewCatalog.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(40)
            maker.width.height.equalTo(40)
            maker.centerY.equalToSuperview()
        }
        self.addSubview(self.lbTitle)
        self.lbTitle.snp.makeConstraints { (maker) in
            maker.leading.equalTo(self.imageViewCatalog.snp.trailing).offset(30)
            maker.height.equalTo(self.imageViewCatalog.snp.height)
            maker.centerY.equalToSuperview()
        }
    }
    func setContent(isSystemImage: Bool, image: String, title: String) {
        if isSystemImage {
            self.imageViewCatalog.image = UIImage(systemName: image)!
            self.imageViewCatalog.snp.remakeConstraints { (maker) in
                maker.width.height.equalTo(30)
            }
            self.imageViewCatalog.layer.cornerRadius = 15
        } else {
            self.imageViewCatalog.kf.setImage(with: URL(string: image))
        }
        self.lbTitle.text = title
    }
}
class PostSettingVC: UIViewController {

    lazy private var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(PostSettingCell.self, forCellReuseIdentifier: "PostSettingCell")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.isScrollEnabled = self.mode == .keep
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    lazy private var lbTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textAlignment = .center
        label.attributedText = NSAttributedString(string: "已收藏，試試將文章加入...", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private var host = false
    private var mode: PostSettingMode = .setting
    private var disposeBag = DisposeBag()
    private var delegate: PostSettingCellDelegate?
    private var post: Post = Post()
    
    private var settingDataList: [String] {
        return host ? ["分享", "轉貼到其他看板", "引用原文發文", "關閉文章通知", "刪除文章", "編輯文章", "編輯話題", "複製全文", "重新整理", "我不喜歡這篇文章"] :
            ["分享", "轉貼到其他看板", "引用原文發文", "開啟文章通知", "檢舉文章", "複製全文", "重新整理", "我不喜歡這篇文章"]
    }
    private var keepDataList: [Favorite] {
        return ModelSingleton.shared.userConfig.user.card.favorite
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(post: Post, mode: PostSettingMode, host: Bool = false) {
        self.post = post
        self.mode = mode
        self.host = host
    }
    func setDelegate(_ delegate: PostSettingCellDelegate) {
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
        let isSystemImage = self.mode == .keep && row == 0 || self.mode == .setting
        let title = self.mode == .keep ? (row == 0 ? "建立收藏分類" : self.keepDataList[row - 1].title) : self.settingDataList[indexPath.row]
        let favorite: Favorite? = row == 0 ? nil : self.keepDataList[row - 1]
        let mediaMeta = favorite?.posts.first { $0.mediaMeta.count > 0 }?.mediaMeta[0].normalizedUrl ?? ""
        let image = isSystemImage ? self.mode == .keep ? "plus" : "book.fill" : mediaMeta
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
                    //創建收藏清單
                }, disposeBag: self.disposeBag)
            } else {
                let favorite = self.keepDataList[row - 1]
                self.dismiss(animated: true) {
                    self.delegate?.showAddFavoriteListOKView(title: favorite.title)
                }
            }
        } else {
            
        }
    }
}
