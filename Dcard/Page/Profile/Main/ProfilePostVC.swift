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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.layer.cornerRadius = 20
        tableView.backgroundColor = .secondarySystemBackground
        return tableView
    }()
    lazy private var collectionView: UICollectionView = {
        var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    lazy private var viewTitle: UIView = {
        var view = UIView()
        let imageView = UIImageView()
        return view
    }()
    @IBOutlet weak var tableViewMain: UITableView!
    private let itemSpace: CGFloat = 20
    private var itemSize: CGSize {
        let width = floor((Double)(self.collectionView.bounds.width - self.itemSpace) / 2)
        let height = floor((Double)(400 - 10 - 2 * self.itemSpace) / 3)
        return CGSize(width: width, height: height)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
}
extension ProfilePostVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.navigationItem.title = "我的成就"
        confiCollectionView()
    }
    private func confiCollectionView() {
        self.collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "CommonCell")
        setCollectionViewLayout()
    }
    private func setCollectionViewLayout() {
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
            maker.top.equalToSuperview().offset(10)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().offset(-20)
            maker.bottom.equalToSuperview().offset(last ? -50 : 0)
        }
    }
}
extension ProfilePostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableView === self.tableViewMain ? 3 : 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = UITableViewCell()
        cell.backgroundColor = .clear
        if tableView === self.tableViewMain {
            let last = row == 2
            switch row {
            case 0:
                setAutoLayout(self.viewTitle, in: cell, last: last)
            case 1:
                setAutoLayout(self.collectionView, in: cell, last: last)
            default:
               setAutoLayout(self.tableView, in: cell, last: last)
            }
        } else {
            //
        }
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        var height: CGFloat = 0
        if tableView === self.tableViewMain {
            switch row {
            case 0:
                height = 150
            case 1:
                height = 400
            default:
                height = 400
            }
        } else {
            height = (400 - 20 - 50) / 7
        }
        return height
    }
}
extension ProfilePostVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CommonCell", for: indexPath)
        cell.backgroundColor = .yellow
        return cell
    }
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
}
