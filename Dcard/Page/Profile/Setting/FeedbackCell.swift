//
//  FeedbackCell.swift
//  Dcard
//
//  Created by admin on 2020/10/8.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol FeedbackCellDelegate {
    func saveHeart(_ value: Int)
}

class FeedbackCell: UITableViewCell {

    @IBOutlet weak var btnSend: UIButton!
    @IBOutlet var lbHearts: [UILabel]!
    @IBOutlet var viewHearts: [UIView]!
    private var delegate: FeedbackCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        initView()
    }
    @IBAction func didClickBtnSend(_ sender: UIButton) {
        self.delegate?.saveHeart(tag + 1)
    }
    func setContent(heart: Int) {
        for i in 0..<heart where heart != 0 {
            self.lbHearts[i].text = "❤️"
        }
        self.btnSend.isEnabled = heart != 0
    }
}
// MARK: - SetupUI
extension FeedbackCell {
    private func initView() {
        self.viewHearts.forEach { (view) in
            self.addGesture(to: view)
        }
    }
    private func addGesture(to view: UIView) {
        let ges = UITapGestureRecognizer(target: self, action: #selector(resetHeart(_:)))
        view.addGestureRecognizer(ges)
    }
    @objc private func resetHeart(_ sender: UITapGestureRecognizer) {
        self.lbHearts.forEach { (lb) in
            lb.text = "🤍"
        }
        if let tag = sender.view?.tag {
            for i in 0...tag {
                self.lbHearts[i].text = "❤️"
            }
        }
        self.btnSend.isEnabled = true
    }
}
