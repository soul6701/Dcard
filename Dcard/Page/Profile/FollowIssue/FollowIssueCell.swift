//
//  FollowIssueCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/14.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class FollowIssueCell: UITableViewCell {

    @IBOutlet weak var viewBell: UIView!
    @IBOutlet weak var imageBell: UIImageView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    private var delegate: FollowIssueVCDelegate?
    private var followIssue = FollowIssue()
    private var imageBellNameList = ["bell.circle.fill", "bell.fill", "bell.slash.fill"]
    private var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        let tap = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
        self.viewBell.addGestureRecognizer(tap)
    }
    
    @IBAction func didClickBtnFollow(_ sender: Any) {
        self.delegate?.cancelFollowIssue(index: self.index, followIssue: self.followIssue)
    }
    func setContent(index: Int, followIssue: FollowIssue) {
        self.index = index
        self.followIssue = followIssue
        let name = followIssue.listName
        let description = "\(followIssue.post.count)篇文章" + " | " + "\(followIssue.post.count)個追蹤"
        self.lbName.text = name
        self.lbDescription.text = description
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[followIssue.notifyMode])
    }
    func setDelegate(_ delegate: FollowIssueVCDelegate) {
        self.delegate = delegate
    }
    @objc private func didClickBell() {
        self.delegate?.showBellModeView(index: self.index, followIssue: self.followIssue)
    }
}
