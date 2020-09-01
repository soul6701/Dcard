//
//  SelectPronView.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/27.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

protocol SelectPronViewDelegate {
    func setValue(pron: String)
}
class SelectPronView: UIView {

    @IBOutlet var views: [UIView]!
    @IBOutlet weak var bottomspace: NSLayoutConstraint!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var view: UIView!
    private var disposeBag = DisposeBag()
    private lazy var tapGesList: [UITapGestureRecognizer] = {
        var list = [UITapGestureRecognizer]()
        (1...3).forEach { (i) in
            list.append(UITapGestureRecognizer())
        }
        return list
    }()
    private lazy var showAnimaor: UIViewPropertyAnimator = {
        self.bottomspace.constant += self.bounds.height / 3
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.layoutIfNeeded()
        }
        return animator
    }()
    private lazy var hideAnimaor: UIViewPropertyAnimator = {
        self.bottomspace.constant -= self.bounds.height / 3
        let animator = UIViewPropertyAnimator(duration: 0.5, curve: .easeInOut) {
            self.layoutIfNeeded()
        }
        animator.addCompletion { (position) in
            if position == .end {
                self.removeFromSuperview()
            }
        }
        return animator
    }()
    private var delegate: SelectPronViewDelegate?
    private var list = ["他", "她", "他們"]
    override func awakeFromNib() {
        self.view.layer.cornerRadius = 20
        self.view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        
        subsribe()
        
        self.views.enumerated().forEach { (index, view) in
            view.addGestureRecognizer(self.tapGesList[index])
        }
    }
    @IBAction func didClickBtnClose(_ sender: UIButton) {
        hide()
    }
    func show() {
        self.showAnimaor.startAnimation()
    }
    func hide() {
        self.hideAnimaor.startAnimation()
    }
    
    func setDelegate(delegate: SelectPronViewDelegate) {
        self.delegate = delegate
    }
}
// MARK: - SubscribeRX
extension SelectPronView {
    private func subsribe() {
        self.tapGesList.forEach { (ges) in
            ges.rx.event.bind { (ges) in
                if let view = ges.view {
                    view.backgroundColor = .systemGray3
                    self.views.forEach { (_view) in
                        _view.backgroundColor = _view == view ? .systemGray3 : .systemBackground
                    }
                }
                if let index = self.tapGesList.firstIndex(of: ges) {
                    self.delegate?.setValue(pron: self.list[index])
                }
                self.hide()
            }.disposed(by: self.disposeBag)
        }
    }
}
