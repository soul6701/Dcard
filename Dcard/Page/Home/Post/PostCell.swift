//
//  PostCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import Kingfisher

protocol PostCellDelegate {
    func edit(post: Post)
}
class PostCell: UITableViewCell {
    enum PostCellMode {
        case home
        case profile
        case favorite
    }
    @IBOutlet weak var imageViewUser: UIImageView!
    @IBOutlet weak var lbForumAndSchool: UILabel!
    @IBOutlet weak var lbExcerpt: UILabel!
    @IBOutlet weak var _lbExcerpt: UILabel!
    @IBOutlet weak var imageViewThumbnail: UIImageView!
    @IBOutlet weak var LikeAndcommentCount: UILabel!
    @IBOutlet weak var lbTitle: UILabel!
    private var imageViewSelected: UIImageView!
    
    private var post: Post = Post()
    private var delegate: PostCellDelegate?
    private var mode: PostCellMode = .home
    
    private var shouldHide: Bool = true
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageViewUser.layer.cornerRadius = 5
        self.imageViewThumbnail.layer.cornerRadius = 10
        
        self.selectionStyle = .none
        
    }
    override func setEditing(_ editing: Bool, animated: Bool) {
        self.shouldHide = true
        super.setEditing(editing, animated: animated)
        
        UIViewPropertyAnimator(duration: 0.3, curve: .easeInOut) {
            self.backgroundView?.alpha = editing ? 1 : 0
        }.startAnimation()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        guard self.mode == .favorite else { return }
        if selected {
            self.imageViewSelected.image = UIImage(systemName: "checkmark.square.fill")
            self.imageViewSelected.tintColor = .link
        } else {
            self.imageViewSelected.image = UIImage(systemName: "square")
            self.imageViewSelected.tintColor = .systemGray3
        }
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if self.isEditing && self.shouldHide {
            // 隱藏系統預設選項視窗，因未暴露在外，須透過迴圈找出
            for controlView in self.subviews {
                if type(of: controlView) === NSClassFromString("UITableViewCellEditControl") {
                    controlView.isHidden = true
                    self.shouldHide = false // 第一次就隱藏，避免頻繁呼叫
                }
            }
        }
    }
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = highlighted ? #colorLiteral(red: 0.9995340705, green: 0.988355577, blue: 0.4726552367, alpha: 0.8842572774) : nil
    }
    @IBAction func didClickBtnSetting(_ sender: UIButton) {
        self.delegate?.edit(post: self.post)
    }
    
    func setContent(post: Post, mode: PostCellMode = .home) {
        self.mode = mode
        if mode == .favorite {
            self.conficontrolView()
        }
        self.post = post
        if post.mediaMeta.count != 0 {
            self.lbExcerpt.isHidden = false
            self._lbExcerpt.isHidden = true
            self.imageViewThumbnail.isHidden = false
            self.lbExcerpt.text = post.excerpt
            self.imageViewThumbnail.kf.setImage(with: URL(string: post.mediaMeta[0].thumbnail))
        } else {
            self.lbExcerpt.isHidden = true
            self._lbExcerpt.isHidden = false
            self.imageViewThumbnail.isHidden = true
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
            self.imageViewUser.setFixedView(label)
            self.imageViewUser.image = nil
        } else {
            self.imageViewUser.subviews.forEach { (view) in
                view.removeFromSuperview()
            }
            self.imageViewUser.image = post.gender == "F" ? UIImage(named: ImageInfo.pikachu) : UIImage(named: ImageInfo.carbi)
        }
    }
    func setDelegate(_ delegate: PostCellDelegate) {
        self.delegate = delegate
    }
}
// MARK: SetupUI
extension PostCell {
    // 設定背景視窗，為滿足自定義選擇動畫
    private func conficontrolView() {
        let view = UIView()
        self.imageViewSelected = UIImageView()
        self.imageViewSelected.contentMode = .scaleAspectFit
        self.imageViewSelected.tintColor = .link
        self.imageViewSelected.image = UIImage(systemName: "square")
        view.addSubview(self.imageViewSelected!)
        self.imageViewSelected.snp.makeConstraints { (maker) in
            maker.leading.equalToSuperview().offset(10)
            maker.centerY.equalToSuperview()
            maker.width.height.equalTo(25)
        }
        self.backgroundView = view
        self.backgroundView?.alpha = 0
    }
}
