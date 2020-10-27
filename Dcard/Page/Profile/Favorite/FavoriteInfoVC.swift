//
//  FavoriteInfoVC.swift
//  Dcard
//
//  Created by Mason on 2020/10/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum FavoriteInfoMode {
    case all
    case other
}

class FavoriteInfoVC: UIViewController {

    lazy private var stackView: [UIStackView] = {
        let stackView = [UIStackView](repeating: UIStackView(), count: 2)
        let haveMediaMetaPostList: [Post] = Array(self.favoritePostList.filter { $0.mediaMeta.count > 0 }.dropFirst(4))
        var imageViewList = [UIImageView]()
        haveMediaMetaPostList.forEach { (post) in
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFit
            imageView.kf.setImage(with: URL(string: post.mediaMeta[0].normalizedUrl))
            imageViewList.append(imageView)
        }
        
        stackView.enumerated().forEach { (key, stackView) in
            stackView.axis = .horizontal
            stackView.alignment = .fill
            stackView.distribution = .fillEqually
            let view = UIView()
            let _view = UIView()
            let a = [UIColor.yellow, UIColor.blue, UIColor.green, UIColor.systemPink]
            view.backgroundColor = a[key * 2 + 0]
            _view.backgroundColor = a[key * 2 + 1]
            stackView.addArrangedSubview(view)
            stackView.addArrangedSubview(view)
        }
        return stackView
    }()
    lazy private var stackViewContainer: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        return stackView
    }()
    private var itemSpace: CGFloat = 5
    @IBOutlet weak var tableView: UITableView!
    
    private var mode: FavoriteInfoMode = .all
    private var favorite: Favorite = Favorite()
    private var favoritePostList: [Post] {
        return self.favorite.posts
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()

    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    @IBAction func back(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func setContent(favorite: Favorite = ModelSingleton.shared.userConfig.user.card.favorite[0], mode: FavoriteInfoMode) {
        self.mode = mode
        self.favorite = favorite
    }
}
// MARK: - SetupUI
extension FavoriteInfoVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.backgroundColor = .clear
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 370, left: 0, bottom: 0, right: 0)
        if self.mode == .all {
            self.tableView.contentInset = UIEdgeInsets(top: 250, left: 0, bottom: 0, right: 0)
            confiStackView()
        }
    }
    private func confiStackView() {
        self.stackView.forEach { (stackView) in
            self.stackViewContainer.addArrangedSubview(stackView)
        }
        self.view.insertSubview(self.stackViewContainer, at: 0)
        self.stackViewContainer.snp.makeConstraints { (maker) in
            maker.leading.equalTo(self.tableView.snp.leading)
            maker.trailing.equalTo(self.tableView.snp.trailing)
            maker.height.equalTo(250)
            maker.top.equalTo(self.tableView.snp.top)
        }
    }
}
// MARK: - UITableViewDelegate
extension FavoriteInfoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.favoritePostList.count : 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        if section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
            cell.setContent(post: self.favoritePostList[row], mode: .profile)
            return cell
        } else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            cell.selectionStyle = .none
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) //隱藏分隔線
            return cell
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 0 else { return nil }
        let view = UINib(nibName: "FavoriteInfoTitleView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! FavoriteInfoTitleView
        view.setContent(favorite: self.favorite, mode: self.mode)
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 120 : CGFloat.leastNonzeroMagnitude
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 180
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let yOffset = scrollView.contentOffset.y
        print("aaaaa\(yOffset)")
        print("bbbbbb\(self.stackViewContainer.center.y)")
        self.stackViewContainer.center.y = -(yOffset + 250) + 250
        self.view.layoutIfNeeded()
    }
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        //
    }
}
