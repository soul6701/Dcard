//
//  PostCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher
class PostCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var lbForumAndSchool: UILabel!
    @IBOutlet weak var lbExcerpt: UILabel!
    @IBOutlet weak var _lbExcerpt: UILabel!
    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var LikeAndcommentCount: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        userImageView.layer.cornerRadius = 5
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
            lbExcerpt.text = post.excerpt
        }
        let letters = NSCharacterSet.letters
        
        lbForumAndSchool.text = post.forumName + " " + post.school + (post.department.rangeOfCharacter(from: letters) != nil && !post.withNickname ? " " + post.department : "")
        
        
        LikeAndcommentCount.text = "❤️\(post.likeCount) 回應: \(post.commentCount)"
        lbTitle.text = post.title
        if post.withNickname {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: userImageView.bounds.width, height: userImageView.bounds.height))
            label.textAlignment = .center
            label.text = "\(post.department.first!)"
            label.textColor = .white
            label.backgroundColor = post.gender == "F" ? .systemPink : .cyan
            userImageView.addSubview(label)
        } else {
            userImageView.image = post.gender == "F" ? UIImage(named: "pikachu") : UIImage(named: "carbi")
        }
    }
}
