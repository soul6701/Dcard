//
//  FavoriteInfoTitleView.swift
//  Dcard
//
//  Created by Mason on 2020/10/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

protocol FavoriteInfoTitleViewDelegate {
    func showForumView()
    func changeCatologMode()
    func changeSelectMode()
}
class FavoriteInfoTitleView: UIView {
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var btnSelect: UIButton!
    @IBOutlet weak var btnCatalog: UIButton!
    @IBOutlet weak var btnForumFilter: UIButton!
    
    private var forumViewWillShow = false {
        didSet {
            self.btnForumFilter.isEnabled = !self.forumViewWillShow
        }
    }
    private var delegate: FavoriteInfoTitleViewDelegate?
    private var favorite: Favorite = Favorite()
    private var mode: FavoriteInfoMode = .all
    
    override func awakeFromNib() {
    }
    @IBAction func didClickBtnSelect(_ sender: UIButton) {
        self.btnSelect.setTitle(self.btnForumFilter.isEnabled ? "完成" : "選取", for: .normal)
        self.btnCatalog.isEnabled = self.btnCatalog.isEnabled
        self.btnForumFilter.isEnabled = self.btnForumFilter.isEnabled
        self.delegate?.changeSelectMode()
    }
    @IBAction func didClickBtnCatalog(_ sender: UIButton) {
        self.btnSelect.isHidden = true
        self.delegate?.changeCatologMode()
    }
    @IBAction func didClickBtnForumFilter(_ sender: UIButton) {
        self.delegate?.showForumView()
    }
    func setContent(favorite: Favorite, mode: FavoriteInfoMode) {
        self.favorite = favorite
        self.lbTitle.text = self.favorite.title
        self.btnSelect.setTitle(self.mode == .all ? "選取" : "新增文章", for: .normal)
    }
    func showBtnSelect() {
        self.btnSelect.isHidden = false
    }
}
