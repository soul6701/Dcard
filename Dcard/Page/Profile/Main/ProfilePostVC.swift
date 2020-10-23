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
        var collectionView = UICollectionView()
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        var flowlayout = UICollectionViewFlowLayout()
        var width = floor((self.view.bounds.width - 20 * 2 - 20) / 2)
        var height = floor((400 - 10 - 2 * 20) / 3)
        flowlayout.itemSize = CGSize(width: width, height: height)
//        
        return collectionView
    }()
    lazy private var viewTitle: UIView = {
        var view = UIView()
        let imageView = UIImageView()
        
        return view
    }()
    @IBOutlet weak var tableViewMain: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

    }
}
extension ProfilePostVC {
    private func initView() {
        //

    }
    private func setAutoLayout<T: UIView>(_ view: T, in cell: UITableViewCell, last: Bool) {
        cell.addSubview(self.viewTitle)
        view.snp.makeConstraints { (maker) in
            maker.top.equalToSuperview().offset(10)
            maker.leading.equalToSuperview().offset(20)
            maker.trailing.equalToSuperview().offset(-20)
            maker.bottom.equalToSuperview().offset(last ? 0 : -50)
        }
    }
}
extension ProfilePostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let cell = UITableViewCell()
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
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let row = indexPath.row
        var height: CGFloat = 0
        switch row {
        case 0:
            height = 150
        case 1:
            height = 400
        default:
            height = 400
        }
        return height
    }
}
extension ProfilePostVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = UICollectionViewCell()
        cell.backgroundColor = .yellow
        return UICollectionViewCell()
    }
}
