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
            data = ProfilePostMoodCellModel(icon: "❤️", count: card.mood.heart.count)
        case .haha:
            data = ProfilePostMoodCellModel(icon: "🤣", count: card.mood.haha.count)
        case .angry:
            data = ProfilePostMoodCellModel(icon: "😡", count: card.mood.angry.count)
        case .cry:
            data = ProfilePostMoodCellModel(icon: "😭", count: card.mood.cry.count)
        case .surprise:
            data = ProfilePostMoodCellModel(icon: "😮", count: card.mood.surprise.count)
        case .respect:
            data = ProfilePostMoodCellModel(icon: "🙇‍♂️", count: card.mood.respect.count)
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
    private var mood: Mood = ModelSingleton.shared.userCard.mood
    public var sortedMoods: [(ProfilePostMoodCellMode, [String])] {
        var list = [(ProfilePostMoodCellMode, [String])]()
        list.append((.heart, self.mood.heart))
        list.append((.haha, self.mood.haha))
        list.append((.angry, self.mood.angry))
        list.append((.cry, self.mood.cry))
        list.append((.surprise, self.mood.surprise))
        list.append((.respect, self.mood.respect))
        list.sort { return $0.1.count < $1.1.count }
        return list
    }
    public var largest: ProfilePostMoodCellMode {
        return self.sortedMoods.last!.0
    }
    public var secondLargest: ProfilePostMoodCellMode {
        return self.sortedMoods[self.sortedMoods.count - 2].0
    }
    
    //計算心情數比例
    public var contrast: Bool {
        let largest = self.sortedMoods.first { return $0.0 == self.largest }!
        let secondLargest = self.sortedMoods.first { return $0.0 == self.secondLargest }!
        let difference = largest.1.count.findMultipleBaseTen() - secondLargest.1.count.findMultipleBaseTen()
        return difference >= 1 || difference == 0 && (secondLargest.1.count == 0 ? true : (largest.1.count / secondLargest.1.count > 2))
    }
    public var scale: [ProfilePostMoodCellMode: CGFloat] {
        return calculateScale(self.contrast ? self.sortedMoods.dropLast() : self.sortedMoods)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    func setContent(rank: Int) {
        let mode = rank == 0 ? .title : self.sortedMoods.reversed()[rank - 1].0
        let data = mode.data
        
        if mode != .title {
            self.lbEmoji.text = data.icon
            self.lbCount.text = String(data.count)
            self.lbTitle.isHidden = true
            self.imageViewTitleIcon.isHidden = true
            self.lbCount.isHidden = false
            self.lbEmoji.isHidden = false
            self.viewLine.isHidden = false
            if self.contrast {
                if mode == self.largest {
                    print("aaaaaa\(self.viewLine.frame.width)")
                    self.viewLine.layoutIfNeeded() //因為lable加入文字自適應寬度，為了新增分隔線，須立即更新layout
                    makeSeperatorView(in: self.viewLine)
                    ProfilePostMoodCell.width = self.lbCount.frame.minX - self.lbEmoji.frame.maxX
                } else {
                    self.viewLine.snp.remakeConstraints { (maker) in
                        maker.width.equalTo((ProfilePostMoodCell.width) * (self.scale[mode]!))
                    }
                }
            } else {
                self.viewLine.snp.remakeConstraints { (maker) in
                    maker.width.equalTo((ProfilePostMoodCell.width) * (self.scale[mode]!))
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
extension ProfilePostMoodCell {
    private func calculateScale(_ list: [(ProfilePostMoodCellMode, [String])]) -> [ProfilePostMoodCellMode: CGFloat] {
        var scale = [ProfilePostMoodCellMode: CGFloat]()
        let countList: [Int] = list.map { return $0.1.count }
        let total = countList.reduce(0) { return $0 + $1 }
        list.forEach { (mode, list) in
            scale[mode] = total != 0 ? CGFloat(Double(list.count) / Double(total)) : 0
        }
        return scale
    }
}
