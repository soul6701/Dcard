//
//  CommentCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/7/2.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol showSettingViewDelegate {
    func showView(location: CGPoint, floor: Int)
}
class CommentCell: UITableViewCell {

    @IBOutlet weak var btnSetting: UIButton!
    @IBOutlet weak var photoView: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDate: UILabel!
    @IBOutlet weak var lbLikeCount: UILabel!
    @IBOutlet weak var txtExcerpt: UITextView!
    @IBOutlet weak var btnHeart: UIButton!
    
    private var view: UIView!
    private var comment: Comment!
    private var delegate: showSettingViewDelegate?
    private var heart = false {
        didSet {
            if comment.likeCount <= 0 {
                if heart {
                    btnHeart.setTitle("❤️", for: .normal)
                } else {
                    btnHeart.setTitle("🤍", for: .normal)
                }
            }
            lbLikeCount.text = "\(heart ? comment.likeCount + 1 : comment.likeCount)"
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(comment: Comment, view: UIView) {
        self.comment = comment
        txtExcerpt.text = comment.content
        lbLikeCount.text = "\(comment.likeCount)"
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let date = formatter.date(from: comment.createdAt)
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "zh_Hant_TW")
        formatter.timeZone = TimeZone(identifier: "Asia/Taipei")
        let prefix = comment.host ? "原PO - " : ""
        lbDate.text = "B\(comment.floor)" + " " + formatter.string(from: date ?? Date())
        let postfix = comment.withNickname ? "" : " \(comment.department)"
        lbName.text = prefix + comment.school + postfix
        self.view = view
        btnHeart.setTitle(comment.likeCount > 0 ? "❤️" : "🤍", for: .normal)
        
        if comment.withNickname {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: photoView.bounds.width, height: photoView.bounds.height))
            label.textAlignment = .center
            label.text = "\(comment.department.first!)"
            label.textColor = .white
            label.backgroundColor = comment.gender == "F" ? .systemPink : .cyan
            photoView.addSubview(label)
        } else {
            photoView.image = comment.gender == "F" ? UIImage(named: ImageInfo.pikachu) : UIImage(named: ImageInfo.carbi)
        }
    }
    func setDelegate(_ delegate: showSettingViewDelegate) {
        self.delegate = delegate
    }
    @IBAction func onClickHeart(_ sender: UIButton) {
        heart = !heart
    }
    @IBAction func onClickSetting(_ sender: UIButton) {
        let point = self.btnSetting.convert(CGPoint.zero, to: self.view)
        delegate?.showView(location: point,floor: self.comment.floor)
    }
}
