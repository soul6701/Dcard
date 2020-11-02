//
//  ProfilePostCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/10/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

fileprivate struct ProfilePostCellModel {
    var title: String = ""
    var icon: String = ""
    var description: String = ""
    var iconColor: UIColor = .white
}
enum ProfilePostCellMode: Int {
    case post = 0
    case comment
    case beKeeped
    case beReplyed
    case getHeart
    case getMood
    
    fileprivate var data: ProfilePostCellModel {
        let (card, post, comment) = (ModelSingleton.shared.userCard, ModelSingleton.shared.post, ModelSingleton.shared.comment)
        var data = ProfilePostCellModel()
        switch self {
        case .post:
            data = ProfilePostCellModel(title: "發過的文章", icon: "doc.on.clipboard.fill", description: String(post.count) + " " + "篇", iconColor: .blue)
        case .comment:
            data = ProfilePostCellModel(title: "發過的回應", icon: "bubble.left.fill", description: String(comment.count) + " " + "則", iconColor: .darkGray)
        case .beKeeped:
            data = ProfilePostCellModel(title: "文章被收藏", icon: "bookmark.fill", description: String(card.beKeeped) + " " + "次", iconColor: .blue)
        case .beReplyed:
            data = ProfilePostCellModel(title: "文章被回應", icon: "tag.fill", description:  String(card.beReplyed) + " " + "則", iconColor: .orange)
        case .getHeart:
            data = ProfilePostCellModel(title: "回應得到愛心", icon: "heart", description: String(card.getHeart) + " " + "顆", iconColor: .red)
        case .getMood:
            data = ProfilePostCellModel(title: "文章獲得心情", icon: "heart.circle.fill", description: String(card.getMood) + " " + "個", iconColor: .red)
        }
        return data
    }
}
class ProfilePostCell: UICollectionViewCell {
    
    @IBOutlet weak var view: UIView!
    @IBOutlet weak var lbDescription: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.view.layer.cornerRadius = 20
    }
    func setContent(mode: ProfilePostCellMode) {
        self.lbTitle.text = mode.data.title
        self.imageViewIcon.image = UIImage(systemName: mode.data.icon)
        self.imageViewIcon.tintColor = mode.data.iconColor
        mode == .post ? self.imageViewIcon.transform = CGAffineTransform(scaleX: -1, y: 1) : nil
        self.lbDescription.text = mode.data.description
    }
}
