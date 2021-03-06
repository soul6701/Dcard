//
//  FavoriteVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol FavoriteVCDelegate {
    //
}
class FavoriteVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var itemSpace: CGFloat = 8
    private var lineSpace: CGFloat = 10
    private var collectionPadding: CGFloat = 15
    private var tfAddList: UITextField?
    private var itemSize: CGSize {
        let width = floor((Double)(self.collectionView.bounds.width - itemSpace - collectionPadding * 2) / 2)
        return CGSize(width: width, height: width)
    }
    private var favoriteList = [Favorite]() {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ToolbarView.shared.show(false)
        initView()
    }
    func setContent(favoriteList: [Favorite], title: String) {
        self.favoriteList = favoriteList
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension FavoriteVC {
    private func initView() {
        confiCollectionView()
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addList))
    }
    private func confiCollectionView() {
        self.collectionView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
        let _view = UIView(frame: self.collectionView.frame)
        _view.backgroundColor = #colorLiteral(red: 0.7540688515, green: 0.7540867925, blue: 0.7540771365, alpha: 0.1963291952)
        self.collectionView.backgroundView = _view
        setCollectionViewLayout()
    }
    private func setCollectionViewLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: collectionPadding, left: collectionPadding, bottom: collectionPadding, right: collectionPadding)
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = self.itemSpace
        layout.minimumLineSpacing = self.lineSpace
        self.collectionView.collectionViewLayout = layout
    }
    @objc private func addList() {
        let alertController = UIAlertController(title: "建立收藏分類", message: "為你的收藏分類命名", preferredStyle: .alert)
        alertController.addTextField { (tf) in
            self.tfAddList = tf
            tf.becomeFirstResponder()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        let OKAction = UIAlertAction(title: "建立", style: .default) { (action) in
            self.favoriteList.append(Favorite(listName: self.tfAddList?.text ?? "", post: []))
            self.collectionView.reloadData()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
        
        let OKActionValid = self.tfAddList?.rx.text.orEmpty.map({ return !$0.isEmpty })
        OKActionValid?.bind(to: OKAction.rx.isEnabled).disposed(by: self.disposeBag)
    }
}
// MARK: - UICollectionViewDelegate
extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favoriteList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let favorite = self.favoriteList[indexPath.row]
        let name = favorite.listName
        let post = favorite.post
        let index = (indexPath.row) % 8
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.setContent(name: name, imageString: !post.isEmpty ? post[index].mediaMeta[0].thumbnail : "")
        return cell
    }
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
}
// MARK: - FavoriteVCDelegate
extension FavoriteVC: FavoriteVCDelegate {
    
}
