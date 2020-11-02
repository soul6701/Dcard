//
//  FollowCardVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol FollowCardVCDelegate {
    func showBellModeView(followCard: FollowCard)
    func cancelFollowCard(followCard: FollowCard)
    func toCardHome(followCard: FollowCard)
}
class FollowCardVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private let disposeBag = DisposeBag()
    private var cardViewModel: CardVMInterface!
    private var postViewModel: PostVMInterface!
    private var post = [[Post]]()
    private var followCardList = [FollowCard]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    private var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
        confiViewModel()
        subscribeViewModel()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToolbarView.shared.show(false)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    func setContent(title: String) {
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension FollowCardVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "FollowCardCell", bundle: nil), forCellReuseIdentifier: "FollowCardCell")
    }
}
// MARK: - subScribeViewModel
extension FollowCardVC {
    private func confiViewModel() {
        self.cardViewModel = CardVM()
        self.postViewModel = PostVM()
    }
    private func subscribeViewModel() {
        self.postViewModel.getPostInfoSubject.subscribe(onNext: { (result) in
            //
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.cardViewModel.getfollowCardInfoSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            self.followCardList = result.data
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
        self.cardViewModel.updateCardInfoSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (result) in
            if result.data {
                LoginManager.shared.showOKView(mode: .create, handler: nil)
                self.tableView.reloadData()
            }
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
    }
}
// MARK: - UITableViewDelegate
extension FollowCardVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.followCardList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            return cell
        }
        let row = indexPath.row
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCardCell", for: indexPath) as! FollowCardCell
        cell.setContent(index: row, followCard: followCardList[indexPath.row], post: [])
        cell.setDelegate(self)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 60 : 120
    }
}
// MARK: - FollowCardVCDelegate
extension FollowCardVC: FollowCardVCDelegate {
    func showBellModeView(followCard: FollowCard) {
        ProfileManager.shared.showBellModeView(delegate: self, notifyMode: followCard.notifyMode)
    }
    func cancelFollowCard(followCard: FollowCard) {
        ProfileManager.shared.showCancelFollowCardView(self, title: "取追追蹤" + "「" + followCard.card.name + "」？") {
//            self.cardViewModel.updateCardInfo(followCard: followCard)
            ProfileManager.shared.showOKView(mode: .cancelFollowCard, handler: nil)
        }
    }
    func toCardHome(followCard: FollowCard) {
        let vc = CardHomeVC()
        vc.setContent(followCard: followCard, mode: .other)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension FollowCardVC: SelectNotifyViewDelegate {
    func setNewValue(_ newNotifymode: Int) {
        self.followCardList[self.selectedIndex].notifyMode = newNotifymode
        self.tableView.reloadData()
    }
}
