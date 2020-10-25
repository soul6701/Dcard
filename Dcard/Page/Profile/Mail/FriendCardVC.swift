//
//  FriendCardVC.swift
//  Dcard
//
//  Created by admin on 2020/10/7.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import ScrollableSegmentedControl

private enum SegmentedControlType: Int {
    case chatRoom = 0
    case cardInfo
}
class FriendCardVC: UIViewController {
    
    private var width: CGFloat {
        return self.navigationController!.navigationBar.frame.width / 2
    }
    private var height: CGFloat {
        return self.navigationController!.navigationBar.frame.height
    }
    private var centerX: CGFloat {
        return self.navigationController!.navigationBar.center.x
    }
    private var chatRoomVC: ChatRoomVC!
    private var cardInfoVC: CardInfoVC!
    private var selectedVC: UIViewController!
    private var selectedIndex = 0
    lazy private var control: ScrollableSegmentedControl = {
        let control = ScrollableSegmentedControl(frame: CGRect(x: 0, y: 0, width: width, height: height))
        control.segmentStyle = .textOnly
        control.insertSegment(withTitle: "聊天室", at: 0)
        control.insertSegment(withTitle: "自介", at: 1)
        control.underlineSelected = true
        control.segmentContentColor = .lightGray
        control.selectedSegmentContentColor = .black
        control.backgroundColor = .clear
        control.fixedSegmentWidth = true
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(didClickControl(_:)), for: .valueChanged)
        return control
    }()
    lazy private var titleView: UIView = {
        let titleView = UIView(frame: CGRect(x: centerX - width / 2, y: 0, width: width, height: height))
        titleView.addSubview(self.control)
        return titleView
    }()
    private var mail: Mail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(mail: Mail) {
        self.mail = mail
    }
}
// MARK: - SetupUI
extension FriendCardVC {
    private func initView() {
        confiNav()
        confiAllVC()
    }
    private func confiNav() {
        self.navigationItem.titleView = self.titleView
    }
    private func confiAllVC() {
        guard let mail = self.mail else { return }
        chatRoomVC = ChatRoomVC()
        chatRoomVC.setContent(mail: mail)
        cardInfoVC = UIStoryboard.card.cardInfoVC
        cardInfoVC.setContent(card: mail.card, isUser: false, isFriend: true)
        didClickControl(self.control)
    }
}
// MARK: - private Fun
extension FriendCardVC {
    @objc func didClickControl(_ sender: ScrollableSegmentedControl) {
        if self.selectedIndex != sender.selectedSegmentIndex || selectedVC == nil {
            self.selectedIndex = sender.selectedSegmentIndex
            
            self.selectedVC?.removeFromParent()
            self.selectedVC?.view.removeFromSuperview()
            
            let type: SegmentedControlType = SegmentedControlType.init(rawValue: selectedIndex)!
            switch type {
            case .chatRoom:
                self.selectedVC = chatRoomVC
            case .cardInfo:
                self.selectedVC = cardInfoVC
            }
            self.addChild(selectedVC)
            self.view.setFixedView(selectedVC.view)
            selectedVC.didMove(toParent: self)
        }
    }
}
