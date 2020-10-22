//
//  SelectNotifyView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int)
}
class SelectNotifyView: UIView {

    @IBOutlet var imageCheckMark: [UIImageView]!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    @IBOutlet var lbs: [UILabel]!
    @IBOutlet var views: [UIView]!
    @IBOutlet weak var viewTitle: UIView!
    private var currentNotifymode: Int!
    private var _window: UIWindow {
        return UIApplication.shared.windows.first!
    }
    private var disposeBag = DisposeBag()
    private lazy var tapGesList: [UITapGestureRecognizer] = {
        var list = [UITapGestureRecognizer]()
        (1...3).forEach { (i) in
            list.append(UITapGestureRecognizer())
        }
        return list
    }()
    private lazy var showAnimaor: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.bottomSpace.constant += 250
            self.layoutIfNeeded()
        }
        return animator
    }()
    private lazy var hideAnimaor: UIViewPropertyAnimator = {
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.bottomSpace.constant -= 250
            self.layoutIfNeeded()
        }
        animator.addCompletion { (position) in
            if position == .end {
                self.removeFromSuperview()
            }
        }
        return animator
    }()
    private var delegate: SelectNotifyViewDelegate?
    override func awakeFromNib() {
        self.viewTitle.layer.cornerRadius = 20
        self.viewTitle.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        subsribe()
        
        self.views.enumerated().forEach { (index, view) in
            view.addGestureRecognizer(self.tapGesList[index])
        }
    }
    @IBAction func didClickBtnClose(_ sender: UIButton) {
        hide()
    }
    func show() {
        self.frame = _window.frame
        _window.addSubview(self)
        
        DispatchQueue.main.async {
            self.showAnimaor.startAnimation()
        }
    }
    func hide() {
        DispatchQueue.main.async {
            self.hideAnimaor.startAnimation()
        }
    }
    
    func setDelegate(_ delegate: SelectNotifyViewDelegate) {
        self.delegate = delegate
    }
    func setContent(notifymode: Int) {
        self.currentNotifymode = notifymode
        for i in 0..<3 {
            self.views[i].tintColor = i == notifymode ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.8982769692) : .systemGray
            self.lbs[i].textColor = i == notifymode ? #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.8982769692) : .systemGray
            self.imageCheckMark[i].isHidden = i != notifymode
        }
    }
}
// MARK: - SubscribeRX
extension SelectNotifyView {
    private func subsribe() {
        self.tapGesList.forEach { (ges) in
            ges.rx.event.bind { (ges) in
                self.lbs.forEach({ $0.textColor = .systemGray })
                self.views.forEach({ $0.tintColor = .systemGray })
                self.imageCheckMark.forEach({ $0.isHidden = true })
                if let index = self.tapGesList.firstIndex(of: ges) {
                    self.lbs[index].textColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.8982769692)
                    self.views[index].tintColor = #colorLiteral(red: 0, green: 0.5898008943, blue: 1, alpha: 0.8982769692)
                    self.imageCheckMark[index].isHidden = false
                    self.delegate?.setNewValue(index)
                }
                self.hide()
            }.disposed(by: self.disposeBag)
        }
    }
}
