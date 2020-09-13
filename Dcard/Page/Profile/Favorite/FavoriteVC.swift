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

class FavoriteVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var itemSpace: CGFloat = 6
    private var lineSpace: CGFloat = 10
    private var collectionPadding: CGFloat = 10
    private var tfAddList: UITextField?
    private var itemSize: CGSize {
        let width = floor((Double)(self.collectionView.bounds.width - itemSpace - collectionPadding * 2) / 2)
        return CGSize(width: width, height: width)
    }
    private var favoriteList = [Favorite]()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(false, animated: true)
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
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        self.collectionView.register(UINib(nibName: "FavoriteCell", bundle: nil), forCellWithReuseIdentifier: "FavoriteCell")
        let _view = UIView(frame: self.collectionView.frame)
        _view.backgroundColor = #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 0.8784514127)
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
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        cell.setContent(name: self.favoriteList[row].listName, imageString: !self.favoriteList[row].post.isEmpty ? self.favoriteList[row].post[0].mediaMeta[0].normalizedUrl : "")
        return cell
    }
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
}
