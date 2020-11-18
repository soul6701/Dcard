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
    
    private var itemSpace: CGFloat = 8
    private var lineSpace: CGFloat = 10
    private var collectionPadding: CGFloat = 15
    private var tfAddList: UITextField?
    private var itemSize: CGSize {
        let width = floor((Double)(self.collectionView.bounds.width - itemSpace - collectionPadding * 2) / 2)
        return CGSize(width: width, height: width)
    }
    private var favoriteList = ModelSingleton.shared.favorite {
        didSet {
            self.collectionView.reloadData()
        }
    }
    private var allFavorite: Favorite {
        var allPostIDList = [String]()
        self.favoriteList.map { return $0.postIDList }.forEach { (postIDList) in
            allPostIDList += postIDList
        }
        return Favorite(title: "全部收藏", postIDList: allPostIDList)
    }
    private var allImageList: [String] {
        var list = [String]()
        for favorite in self.favoriteList {
            if let first = favorite.coverImage.first(where: { return !$0.isEmpty }) {
                list.append(first)
                if list.count >= 4 { break }
            }
        }
        return list
    }
    private var viewModel: PostVMInterface!
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subsribeViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
    }
    func setContent(title: String) {
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension FavoriteVC {
    private func initView() {
        ToolbarView.shared.show(false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addList))
        confiCollectionView()
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
    //創建播放清單
    @objc private func addList() {
        UIAlertController.showNewFavoriteCatolog(self, cancelHandler: {
            self.dismiss(animated: true, completion: nil)
        }, OKHandler: { (text) in
            self.viewModel.createFavoriteList(listName: text)
        }, disposeBag: self.disposeBag)
    }
}
// MARK: - ConfigureViewModel
extension FavoriteVC {
    private func confiViewModel() {
        self.viewModel = PostVM()
    }
    private func subsribeViewModel() {
        self.viewModel.createFavoriteListSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            self.favoriteList = ModelSingleton.shared.favorite
        }, onError: { (error) in
            AlertManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - UICollectionViewDelegate
extension FavoriteVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.favoriteList.count + 1
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let row = indexPath.row
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FavoriteCell", for: indexPath) as! FavoriteCell
        if row == 0 {
            cell.setContent(name: self.allFavorite.title, imageStrings: self.allImageList)
        } else {
            let favorite = self.favoriteList[row - 1]
            let title = favorite.title
            let mediaMetas = favorite.coverImage.first { return !$0.isEmpty }
            cell.setContent(name: title, imageStrings: [mediaMetas ?? ""])
        }
        return cell
    }
    func  collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.itemSize
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let row = indexPath.row
        let vc = FavoriteInfoVC()
        if row == 0 {
            vc.setContent(.all, title: self.allFavorite.title, postIDList: self.allFavorite.postIDList, imageStrings: self.allImageList)
        } else {
            let favorite = self.favoriteList[row - 1]
            let mediaMetas = favorite.coverImage.first { return !$0.isEmpty }
            vc.setContent(.other, title: favorite.title, postIDList: favorite.postIDList, imageStrings: [mediaMetas ?? ""])
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
