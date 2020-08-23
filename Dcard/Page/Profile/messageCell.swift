//
//  messageCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum messageCellType {
    case left
    case right
}

class messageCell: UITableViewCell {

    @IBOutlet weak var viewRightMessage: UIView!
    @IBOutlet weak var viewLeftMessage: UIView!
    @IBOutlet weak var txtViewLeft: UITextView!
    @IBOutlet weak var txtViewRight: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        confiMessageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    //避免單元格重複使用，導致畫面消失，須明確重設內容
    func setContent(context: String, mode: messageCellType) {
        self.viewRightMessage.isHidden = mode == .left
        self.viewLeftMessage.isHidden = !(mode == .left)
        self.txtViewRight.text = (self.viewLeftMessage.isHidden) ? context : ""
        self.txtViewLeft.text = !(self.viewLeftMessage.isHidden) ? context : ""
    }
}
extension messageCell {
    private func confiMessageView() {
        self.viewLeftMessage.layer.cornerRadius = 20
        self.viewRightMessage.layer.cornerRadius = 20
        self.txtViewLeft.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.txtViewRight.textContainerInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        self.txtViewLeft.isEditable = false
        self.txtViewRight.isEditable = false
    }
}
