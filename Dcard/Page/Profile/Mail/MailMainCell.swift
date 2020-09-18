//
//  MailMainCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class MailMainCell: UITableViewCell {
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var itemSpace: CGFloat = 8
    private var lineSpace: CGFloat = 10
    private var collectionPadding: CGFloat = 10
    private var itemSize: CGSize {
        let width = floor((self.collectionView.bounds.width - 2 * self.collectionPadding - itemSpace) / 2)
        let height = width * 1.5
        return CGSize(width: width, height: height)
    }
    private var headerSize: CGSize {
        return CGSize(width: self.collectionView.bounds.width, height: 20)
    }
    private var friendList = [Card]()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        initView()
    }
    func setContent(friendList: [Card]) {
        self.friendList = friendList
    }
}
// MARK: - SetupUI
extension MailMainCell {
    private func initView() {
        confiCollectionView()
    }
    private func confiCollectionView() {
        self.collectionView.register(UINib(nibName: "MailAllCell", bundle: nil), forCellWithReuseIdentifier: "MailAllCell")
        setCollectionViewLayout()
    }
    private func setCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: self.collectionPadding, left: self.collectionPadding, bottom: self.collectionPadding, right: self.collectionPadding)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = self.itemSpace
        layout.minimumLineSpacing = self.lineSpace
        self.collectionView.collectionViewLayout = layout
    }
}

// MARK: - UICollectionViewDelegate
extension MailMainCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.friendList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MailAllCell", for: indexPath) as! MailAllCell
        let friend = self.friendList[indexPath.row]
        cell.setContent(card: friend)
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath) as! MailAllCell
        cell.setHighlightView()
    }
}
