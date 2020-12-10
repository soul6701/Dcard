//
//  Loading.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/4.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import SafariServices

class LoadingView: UIView {
    
    @IBOutlet weak var lbPercent: UILabel!
    @IBOutlet weak var imageProgress: UIImageView!
    @IBOutlet weak var viewProgress: UIProgressView!
    @IBOutlet weak var trailingSpace: NSLayoutConstraint!
    private static var _shared: LoadingView?
    private var count = 0
    private var complete = 100
    private var distance: CGFloat = 0
    private var timer: Timer?
    lazy private var lbHint: UILabel = {
        let label = UILabel()
        let text = "Please agree for Terms & Conditions."
        label.text = text
        label.textColor =  UIColor.black
        let underlineAttriString = NSMutableAttributedString(string: text)
        let range1 = (text as NSString).range(of: "Terms & Conditions.")
                underlineAttriString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.font, value: UIFont.systemFont(ofSize: 15, weight: .bold), range: range1)
        underlineAttriString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.green, range: range1)
        underlineAttriString.addAttribute(.backgroundColor, value: UIColor.blue, range: range1)
        label.attributedText = underlineAttriString
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target:self, action: #selector(tap(_:))))
        return label
    }()
    lazy private var lbTerms: UILabel = {
        let label = UILabel()
        label.text = "test"
        label.textColor = .red
        label.isHidden = true
        return label
    }()
    static var shared: LoadingView {
        if _shared == nil {
            _shared = UINib(nibName: "LoadingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? LoadingView
        }
        return _shared!
    }
    deinit {
        timer?.invalidate()
    }
    override func layoutSubviews() {
        self.distance = imageProgress.bounds.width
        if self.imageProgress.frame.minX < self.viewProgress.frame.minX + self.imageProgress.frame.size.width {
            self.trailingSpace.constant = 0
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addSubview(lbHint)
        lbHint.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        addSubview(lbTerms)
        lbTerms.snp.makeConstraints { (make) in
            make.top.equalTo(lbHint.snp.bottom)
            make.centerX.equalTo(lbHint.snp.centerX)
        }
        
        addAnimation()
        self.imageProgress.loadGif(name: "熊貓")

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true, block: { (timer) in
            self.viewProgress.setProgress(Float(self.count) / Float(self.complete), animated: true)
            self.trailingSpace.constant -= 3
            self.count += 1
            self.lbPercent.text = "\(Int(floor(Float(self.count) / Float(self.complete) * 100)))%"
            if self.count == 100 {
                self.show(false)
                timer.invalidate()
            }
        })
    }
    @objc private func tap(_ ges: UITapGestureRecognizer) {
        lbTerms.isHidden.toggle()
    }
    func show(_ willShow: Bool) {
        if willShow {
            let window = UIApplication.shared.windows.first!
            self.layer.zPosition = 6
            window.addSubview(self)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([self.leadingAnchor.constraint(equalTo: window.leadingAnchor), self.trailingAnchor.constraint(equalTo: window.trailingAnchor), self.topAnchor.constraint(equalTo: window.topAnchor), self.bottomAnchor.constraint(equalTo: window.bottomAnchor)])
        } else {
            removeFromSuperview()
        }
    }
}
extension LoadingView {
    // 繪製動畫
    private func addAnimation() {
        let viewSize: CGFloat = 100
        let animationDuration: Double = 3
        let dotSize: CGFloat = 10
        let dotCount = 3
        let dotLayer: CAShapeLayer = CAShapeLayer()
        dotLayer.frame       = CGRect(origin: CGPoint(x: viewSize / CGFloat(dotCount) / 2 - dotSize / 2, y: dotSize), size: CGSize(width: dotSize, height: dotSize))
        dotLayer.path        = UIBezierPath(ovalIn: dotLayer.bounds).cgPath
        dotLayer.fillColor   = UIColor.white.cgColor
        
        let dotReplicatorLayer: CAReplicatorLayer = CAReplicatorLayer() //複製器
        dotReplicatorLayer.addSublayer(dotLayer)
        dotReplicatorLayer.instanceCount = dotCount //複製數
        dotReplicatorLayer.instanceDelay = animationDuration / Double(dotCount) //每個實例的動畫延遲
        dotReplicatorLayer.instanceTransform = CATransform3DMakeTranslation((viewSize) / CGFloat(dotCount), 0, 0) //所有實例的分佈
        
        let view = UIView()
        addSubview(view)
        view.snp.makeConstraints { (make) in
            make.top.equalTo(lbTerms.snp.bottom).offset(30)
            make.size.equalTo(100)
            make.centerX.equalToSuperview()
        }
        view.layer.addSublayer(dotReplicatorLayer)
        view.backgroundColor = .red
        let downY = 100 - dotSize
        let positionAnimation = CAKeyframeAnimation(keyPath: "position.y")
        positionAnimation.duration = animationDuration
        positionAnimation.beginTime = CACurrentMediaTime() + 0.5
        positionAnimation.repeatCount = .infinity
        positionAnimation.values = [dotSize, downY, downY / 2, dotSize] //動畫位置
        positionAnimation.keyTimes = [0.0, 0.33, 0.66, 1.0] //動畫發生的時間點陣列 ( 0 -> 1) 與動畫位置對應
        dotLayer.add(positionAnimation, forKey: "positionAnimation")
        
        
        let scaleAnimation = CAKeyframeAnimation(keyPath: "transform")
        let startingScale = CATransform3DScale(dotLayer.transform, 0, 0, 0)
        let overshootScale = CATransform3DScale(dotLayer.transform, 2, 2, 2)
        let undershootScale = CATransform3DScale(dotLayer.transform, 1.5, 1.5, 1.5)
        let endingScale = dotLayer.transform
        scaleAnimation.duration = animationDuration
        scaleAnimation.beginTime = CACurrentMediaTime() + 0.5
        scaleAnimation.repeatCount = .infinity
        scaleAnimation.values = [startingScale, overshootScale, undershootScale, endingScale]
        scaleAnimation.calculationMode = .cubicPaced //無視keytimes Linear：預設差值 Discrete:逐幀顯示 Paced:勻速 Cubic: keytimes曲線平滑 CubicPaced:keyValue之間平滑差值 無視keyTimes
        scaleAnimation.timingFunctions = [CAMediaTimingFunction(name: .easeIn), CAMediaTimingFunction(name: .easeInEaseOut), CAMediaTimingFunction(name: .linear), CAMediaTimingFunction(name: .easeOut)]
        dotLayer.add(scaleAnimation, forKey: "scaleAnimation")
        
        

        //遮罩
//        let bezierPath = UIBezierPath()
//        bezierPath.move(to: CGPoint(x: 25, y: 25))
//        bezierPath.addLine(to: CGPoint(x: 75, y: 25))
//        bezierPath.addLine(to: CGPoint(x: 75, y: 75))
//        bezierPath.addLine(to: CGPoint(x: 25, y: 75))
//        bezierPath.close()
        
        let _view = UIView()
        _view.backgroundColor = .gray
        self.addSubview(_view)
        _view.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.bottom).offset(30)
            make.size.equalTo(viewSize)
            make.centerX.equalToSuperview()
        }
       

        
        
//        let mask = CAShapeLayer()
//        mask.frame = CGRect(x: 0, y: 0, width: viewSize, height: viewSize)
//        mask.path = bezierPath.cgPath
//        mask.backgroundColor = UIColor.white.cgColor
////        mask.fillColor = UIColor.green.cgColor
//        mask.strokeColor = UIColor.blue.cgColor
//        _view.layer.addSublayer(mask)
        
        
        
        
       
    }
    
}
