//
//  RecentPostCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher
class RecentPostCell: UITableViewCell {

    @IBOutlet weak var lbForumAndSchool: UILabel!
    @IBOutlet weak var lbExcerpt: UILabel!
    @IBOutlet weak var _lbExcerpt: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var LikeAndcommentCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setContent(post: Post) {
        if post.mediaMeta.count != 0 {
            lbExcerpt.isHidden = true
            _lbExcerpt.text = post.excerpt
            thumbnailImageView.kf.setImage(with: URL(string: post.mediaMeta[0].thumbnail))
        } else {
            _lbExcerpt.isHidden = true
            thumbnailImageView.isHidden = true
            lbExcerpt.text = post.title + "\n" + post.excerpt
        }
        print("aaa: \(post.mediaMeta.count)")
        lbForumAndSchool.text = post.forumName + " " + (post.school ?? "匿名")
        LikeAndcommentCount.text = "❤️\(post.likeCount) 回應: \(post.commentCount)"
    }
}
