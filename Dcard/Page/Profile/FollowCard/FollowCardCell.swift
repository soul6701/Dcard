//
//  FollowCardCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class FollowCardCell: UITableViewCell
{
    @IBOutlet weak var viewToCardHomePage: UIView!
    @IBOutlet weak var viewID: customView!
    @IBOutlet weak var viewNew: customView!
    @IBOutlet weak var viewBell: UIView!
    @IBOutlet weak var imageBell: UIImageView!
    @IBOutlet weak var lbID: UILabel!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbDescription: UILabel!
    private var delegate: FollowCardVCDelegate?
    private var imageBellNameList = ["bell.circle.fill", "bell.fill", "bell.slash.fill"]
    private var followCard: FollowCard!
    private var index = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        confiTapGesture()
    }
    
    @IBAction func didClickBtnFollow(_ sender: Any) {
        self.delegate?.cancelFollowCard(index: self.index, followCard: self.followCard)
    }
    func setContent(index: Int, followCard: FollowCard) {
        self.index = index
        self.followCard = followCard
        let id = followCard.card.id
        let name = followCard.card.name
        let isNew =  followCard.isNew
        let sex = followCard.card.sex
        let notify = followCard.notifyMode
        
        var _description: NSMutableAttributedString = NSMutableAttributedString(string: "")
        if isNew {
            _description = NSMutableAttributedString(string: "有\(followCard.card.post.count)篇新文章", attributes: [NSAttributedString.Key.foregroundColor: UIColor.systemBlue])
        } else {
            _description = NSMutableAttributedString(string: "有\(followCard.card.post.count)篇文章")
        }
        let combination = NSMutableAttributedString()
        combination.append(NSMutableAttributedString(string: "@\(id) | "))
        combination.append(_description)
        
        self.lbID.text = String(id.first!).uppercased()
        self.lbName.text = name
        self.lbDescription.attributedText = combination
        self.viewNew.gradientBGEnable = isNew
        self.viewID.backgroundColor = sex == "M" ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 1) : #colorLiteral(red: 1, green: 0.5409764051, blue: 0.8473142982, alpha: 1)
        self.imageBell.image = UIImage(systemName: self.imageBellNameList[notify])
    }
    func setDelegate(_ delegate: FollowCardVCDelegate) {
        self.delegate = delegate
    }
    private func confiTapGesture() {
        let tapBell = UITapGestureRecognizer(target: self, action: #selector(didClickBell))
        self.viewBell.addGestureRecognizer(tapBell)
        let tapCard = UITapGestureRecognizer(target: self, action: #selector(didClickCard))
        self.viewToCardHomePage.addGestureRecognizer(tapCard)
    }
    @objc private func didClickBell() {
        self.delegate?.showBellModeView(index: index, followCard: self.followCard)
    }
    @objc private func didClickCard() {
        self.delegate?.toCardHome(followCard: self.followCard)
    }
}
