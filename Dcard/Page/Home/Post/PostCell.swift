//
//  PostCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

enum PostCellMode {
    case home
    case profile
}

class PostCell: UITableViewCell {

    @IBOutlet weak var btnEdit: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lbForumAndSchool: UILabel!
    @IBOutlet weak var lbExcerpt: UILabel!
    @IBOutlet weak var _lbExcerpt: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var LikeAndcommentCount: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.userImageView.layer.cornerRadius = 5
        self.selectionStyle = .none
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = highlighted ? #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 0.8842572774) : nil
    }
    func setContent(post: Post, mode: PostCellMode) {
        self.btnEdit.isHidden = mode == .home
        if post.mediaMeta.count != 0 {
            self.lbExcerpt.isHidden = false
            self._lbExcerpt.isHidden = true
            self.thumbnailImageView.isHidden = false
            self.lbExcerpt.text = post.excerpt
            self.thumbnailImageView.kf.setImage(with: URL(string: post.mediaMeta[0].thumbnail))
        } else {
            self.lbExcerpt.isHidden = true
            self._lbExcerpt.isHidden = false
            self.thumbnailImageView.isHidden = true
            self._lbExcerpt.text = post.excerpt
        }
        let letters = NSCharacterSet.letters
        
        self.lbForumAndSchool.text = post.forumName + " " + post.school + (post.department.rangeOfCharacter(from: letters) != nil && !post.withNickname ? " " + post.department : "")
        
        self.LikeAndcommentCount.text = (post.likeCount != "0" ? "❤️" : "🤍") + "\(post.likeCount) 回應: \(post.commentCount)"
        self.lbTitle.text = post.title
        if post.withNickname {
            let label = UILabel()
            label.textAlignment = .center
            label.text = "\(post.department.first!)"
            label.textColor = .white
            label.backgroundColor = post.gender == "F" ? #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1) : #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1)
            self.userImageView.setFixedView(label)
            self.userImageView.image = nil
        } else {
            self.userImageView.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            self.userImageView.image = post.gender == "F" ? UIImage(named: ImageInfo.pikachu) : UIImage(named: ImageInfo.carbi)
        }
    }
}
