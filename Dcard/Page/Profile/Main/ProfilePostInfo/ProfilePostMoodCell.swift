//
//  ProfilePostMoodCell.swift
//  Dcard
//
//  Created by Mason on 2020/10/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

fileprivate struct ProfilePostMoodCellModel {
    var icon: String = ""
    var count: Int = 0
}
public enum ProfilePostMoodCellMode: Int {
    case title = 0
    case heart
    case haha
    case angry
    case cry
    case surprise
    case respect
    
    var card: Card {
        return ModelSingleton.shared.userConfig.user.card
    }
    fileprivate var data: ProfilePostMoodCellModel {
        var data = ProfilePostMoodCellModel()
        
        switch self {
        case .title:
            break
        case .heart:
            data = ProfilePostMoodCellModel(icon: "❤️", count: card.mood.heart)
        case .haha:
            data = ProfilePostMoodCellModel(icon: "🤣", count: card.mood.haha)
        case .angry:
            data = ProfilePostMoodCellModel(icon: "😡", count: card.mood.angry)
        case .cry:
            data = ProfilePostMoodCellModel(icon: "😭", count: card.mood.cry)
        case .surprise:
            data = ProfilePostMoodCellModel(icon: "😮", count: card.mood.surprise)
        case .respect:
            data = ProfilePostMoodCellModel(icon: "🙇‍♂️", count: card.mood.respect)
        }
        return data
    }
}
class ProfilePostMoodCell: UITableViewCell {

    //標題
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var imageViewTitleIcon: UIImageView!
    
    //心情
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var imageViewEmoji: UIImageView!
    @IBOutlet weak var viewLine: customView!
    
    private var width: CGFloat {
        return self.bounds.width * 2 / 3
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(rank: Int) {
        let mood = ModelSingleton.shared.userConfig.user.card.mood
        let mode = rank == 0 ? .title : mood.sortedMoods.reversed()[rank - 1].0
        let data = mode.data
        
        if mode != .title {
            self.imageView?.image = data.icon.image()!
            self.lbCount.text = String(data.count)
            self.lbTitle.isHidden = true
            self.imageViewTitleIcon.isHidden = true
            self.lbCount.isHidden = false
            self.imageViewEmoji.isHidden = false
            self.viewLine.isHidden = false
            if mood.contrast {
                if mode == mood.largest {
                    makeSeperatorView(in: self.viewLine)
                    self.viewLine.snp.remakeConstraints { (maker) in
                        maker.width.equalTo(self.width)
                    }
                } else {
                    self.viewLine.snp.remakeConstraints { (maker) in
                        maker.width.equalTo((self.width) * (mood.scale[mode]!))
                    }
                }
            } else {
                self.viewLine.snp.remakeConstraints { (maker) in
                    maker.width.equalTo((self.width) * (mood.scale[mode]!))
                }
            }
        } else {
            self.lbTitle.isHidden = false
            self.imageViewTitleIcon.isHidden = false
            self.lbCount.isHidden = true
            self.imageViewEmoji.isHidden = true
            self.viewLine.isHidden = true
        }
    }
    private func makeSeperatorView(in view: customView) {
        let path = UIBezierPath()
        let Width: CGFloat = view.bounds.width
        let height: CGFloat = view.bounds.height
        path.move(to: CGPoint(x: Width - 22.5, y: 0))
        path.addLine(to: CGPoint(x: Width - 30, y: height))
        path.addLine(to: CGPoint(x: Width - 40, y: height))
        path.addLine(to: CGPoint(x: Width - 32.5, y: 0))
        path.close()
        let seperatorLayer = CAShapeLayer()
        seperatorLayer.path = path.cgPath
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = .white
        containerView.layer.mask = seperatorLayer
        view.addSubview(containerView)
    }
}
