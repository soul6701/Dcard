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
        self.userImageView.layer.cornerRadius = 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = highlighted ? #colorLiteral(red: 0.5818830132, green: 0.2156915367, blue: 1, alpha: 0.4206442637) : .white
    }
    func setContent(post: Post) {
        if post.mediaMeta.count != 0 {
            self.lbExcerpt.isHidden = true
            self._lbExcerpt.text = post.excerpt
            self.thumbnailImageView.kf.setImage(with: URL(string: post.mediaMeta[0].thumbnail))
        } else {
            self._lbExcerpt.isHidden = true
            self.thumbnailImageView.isHidden = true
            self.lbExcerpt.text = post.excerpt
        }
        let letters = NSCharacterSet.letters
        
        self.lbForumAndSchool.text = post.forumName + " " + post.school + (post.department.rangeOfCharacter(from: letters) != nil && !post.withNickname ? " " + post.department : "")
        
        
        self.LikeAndcommentCount.text = "❤️\(post.likeCount) 回應: \(post.commentCount)"
        self.lbTitle.text = post.title
        if post.withNickname {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.userImageView.bounds.width, height: self.userImageView.bounds.height))
            label.textAlignment = .center
            label.text = "\(post.department.first!)"
            label.textColor = .white
            label.backgroundColor = post.gender == "F" ? .systemPink : .cyan
            self.userImageView.addSubview(label)
        } else {
            self.userImageView.image = post.gender == "F" ? UIImage(named: "pikachu") : UIImage(named: "carbi")
        }
    }
}
