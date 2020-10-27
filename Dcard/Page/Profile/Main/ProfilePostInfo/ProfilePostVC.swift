//
//  ProfilePostVC.swift
//  Dcard
//
//  Created by admin on 2020/10/22.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class ProfilePostVC: UIViewController {

    lazy private var tableView: UITableView = {
       var tableView = UITableView()
        tableView.register(UINib(nibName: "ProfilePostMoodCell", bundle: nil), forCellReuseIdentifier: "ProfilePostMoodCell")
        tableView.separatorStyle = .none
        tableView.allowsSelection = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 20
        tableView.backgroundColor = .tertiarySystemGroupedBackground
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showMaintainView))
        tableView.addGestureRecognizer(tap)
        return tableView
    }()
    lazy private var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.register(UINib(nibName: "ProfilePostCell", bundle: nil), forCellWithReuseIdentifier: "ProfilePostCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    lazy private var viewTitle: ProfilePostView = {
        let view = UINib(nibName: "ProfilePostView", bundle: nil).instantiate(withOwner: nil, options: nil).first as! ProfilePostView
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.showMaintainView))
        tableView.addGestureRecognizer(tap)
        view.addGestureRecognizer(tap)
        return view
    }()
    @IBOutlet weak var tableViewMain: UITableView!
    
    private let itemSpace: CGFloat = 15
    private var itemSize: CGSize {
        let width = floor((Double)(self.collectionView.bounds.width - self.itemSpace) / 2)
        let height = floor((Double)(400 - 15 - 2 * self.itemSpace) / 3)
        return CGSize(width: width, height: height)
    }
    private var mood: Mood {
        return ModelSingleton.shared.userConfig.user.card.mood
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        ProfileManager.shared.setupMaintainBaseVC(target: self)
    }
}
// MARK: - SetupUI
extension ProfilePostVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.navigationItem.title = "我的成就"
        setupCollectionViewLayout()
    }
    private func setupCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = self.itemSize
        layout.minimumLineSpacing = self.itemSpace
        layout.minimumInteritemSpacing = self.itemSpace
        self.collectionView.collectionViewLayout = layout
    }
    private func setAutoLayout<T: UIView>(_ view: T, in cell: UITableViewCell, last: Bool) {
        view.translatesAutoresizingMaskIntoConstraints = false
        cell.addSubview(view)
        view.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(15)
            maker.leading.equalToSuperview().offset(15)
            maker.trailing.equalToSuperview().offset(-15)
            maker.bottom.equalToSuperview().offset(last ? -50 : 0)
        }
    }
}
// MARK: - Private Handler
extension ProfilePostVC {
    @objc private func showMaintainView() {
        ProfileManager.shared.showMaintainView()
    }
}
// MARK: - UITableViewDelegate
extension ProfilePostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableViewMain ? 3 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if tableView === self.tableViewMain {
            let cell = UITableViewCell()
            cell.backgroundColor = .clear
            let last = row == 2
            switch row {
            case 0:
                setAutoLayout(self.viewTitle, in: cell, last: last)
            case 1:
                setAutoLayout(self.collectionView, in: cell, last: last)
            default:
               setAutoLayout(self.tableView, in: cell, last: last)
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "ProfilePostMoodCell", for: indexPath) as! ProfilePostMoodCell
            cell.setContent(rank: row)
            return cell
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        var height: CGFloat = 0
        if tableView === self.tableViewMain {
            switch row {
            case 0:
                height = 90
            case 1:
                height = 400
            default:
                height = 400
            }
        } else {
            height = (400 - 15 - 50) / 7
        }
        return height
    }
}
// MARK: - UICollectionViewDelegate
extension ProfilePostVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ProfilePostCell", for: indexPath) as! ProfilePostCell
        cell.setContent(mode: ProfilePostCellMode(rawValue: row)!)
        return cell
    }
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        if row != 0 && row != 2 {
            ProfileManager.shared.showMaintainView()
        } else {
            ProfileManager.shared.toNextPage(next: .artical)
        }
    }
}
