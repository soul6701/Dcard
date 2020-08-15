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
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setContent(date: Date, marked: Bool, inMonth: Bool) {
        let color: UIColor = inMonth ? .black : .lightGray
        self.isUserInteractionEnabled = inMonth ? true : false
        self.lbDay.attributedText = NSAttributedString(string: "\(date.day)", attributes: [NSAttributedString.Key.foregroundColor: color])
        self._show = marked
        self.imageMemo.isHidden = !self._show
        
        if Date.calendar.isDateInToday(date) {
            drawCircle()
        }
    }
    func show() {
        self._show = !self._show
        self.imageMemo.isHidden = !self._show
    }
    
    private func drawCircle() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.frame = CGRect(x: 0, y: 0, width: self.contentView.bounds.width * 0.8, height: self.contentView.bounds.width * 0.8)
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = 3
        shapeLayer.strokeColor = UIColor.white.cgColor
        let arcCenter: CGPoint = self.contentView.center
        let radius: CGFloat = self.contentView.bounds.width / 2
        let path = UIBezierPath(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2 * Float.pi), clockwise: true)
        shapeLayer.path = path.cgPath
        self.contentView.layer.addSublayer(shapeLayer)
    }
}
