//
//  DayCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/13.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class DayCell: UICollectionViewCell {

    @IBOutlet weak var lbDay: UILabel!
    @IBOutlet weak var imageMemo: UIImageView!
    var _show = false
    private lazy var shapeLayer: CAShapeLayer = {
        let shapeLayer = CAShapeLayer()
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 2
        shapeLayer.strokeColor = UIColor.white.cgColor
        let arcCenter: CGPoint = self.contentView.center
        let radius: CGFloat = self.contentView.bounds.width / 2
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Float.pi), clockwise: true)
        shapeLayer.path = path.cgPath
        return shapeLayer
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setContent(date: Date, marked: Bool, inMonth: Bool) {
        let color: UIColor = inMonth ? .black : .lightGray
        self.isUserInteractionEnabled = inMonth ? true : false
        self.lbDay.attributedText = NSAttributedString(string: "\(date.day)", attributes: [NSAttributedString.Key.foregroundColor: color])
        self._show = marked
        self.imageMemo.isHidden = !self._show
        
        if Date.calendar.isDateInToday(date) {
            self.contentView.layer.addSublayer(self.shapeLayer)
        } else {
            self.shapeLayer.removeFromSuperlayer()
        }
    }
    func show() {
        self._show = !self._show
        self.imageMemo.isHidden = !self._show
    }
}
