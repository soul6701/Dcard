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
        return ModelSingleton.shared.userCard
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
    @IBOutlet weak var lbEmoji: UILabel!
    @IBOutlet weak var lbCount: UILabel!
    @IBOutlet weak var viewLine: customView!
    
    static private var width: CGFloat = 0 //由最大心情數量決定線條寬度
    private var mode: ProfilePostMoodCellMode = .title
    private var mood: Mood {
        return ModelSingleton.shared.userCard.mood
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(rank: Int) {
        let mode = rank == 0 ? .title : mood.sortedMoods.reversed()[rank - 1].0
        let data = mode.data
        
        if mode != .title {
            self.lbEmoji.text = data.icon
            self.lbCount.text = String(data.count)
            self.lbTitle.isHidden = true
            self.imageViewTitleIcon.isHidden = true
            self.lbCount.isHidden = false
            self.lbEmoji.isHidden = false
            self.viewLine.isHidden = false
            if self.mood.contrast {
                if mode == self.mood.largest {
                    print("aaaaaa\(self.viewLine.frame.width)")
                    self.viewLine.layoutIfNeeded() //因為lable加入文字自適應寬度，為了新增分隔線，須立即更新layout
                    makeSeperatorView(in: self.viewLine)
                    ProfilePostMoodCell.width = self.lbCount.frame.minX - self.lbEmoji.frame.maxX
                } else {
                    self.viewLine.snp.remakeConstraints { (maker) in
                        maker.width.equalTo((ProfilePostMoodCell.width) * (self.mood.scale[mode]!))
                    }
                }
            } else {
                self.viewLine.snp.remakeConstraints { (maker) in
                    maker.width.equalTo((ProfilePostMoodCell.width) * (self.mood.scale[mode]!))
                }
            }
        } else {
            self.lbTitle.isHidden = false
            self.imageViewTitleIcon.isHidden = false
            self.lbCount.isHidden = true
            self.lbEmoji.isHidden = true
            self.viewLine.isHidden = true
        }
    }
    //加入分割線
    private func makeSeperatorView(in view: customView) {
        let path = UIBezierPath()
        let width: CGFloat = view.frame.width
        let height: CGFloat = view.frame.height
        path.move(to: CGPoint(x: width - 22.5, y: 0))
        path.addLine(to: CGPoint(x: width - 30, y: height))
        path.addLine(to: CGPoint(x: width - 40, y: height))
        path.addLine(to: CGPoint(x: width - 32.5, y: 0))
        path.close()
        let seperatorLayer = CAShapeLayer()
        seperatorLayer.path = path.cgPath
        let containerView = UIView(frame: view.bounds)
        containerView.backgroundColor = .white
        containerView.layer.mask = seperatorLayer
        view.addSubview(containerView)
    }
}
