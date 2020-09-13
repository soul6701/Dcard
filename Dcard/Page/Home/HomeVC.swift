//
//  ViewController.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class HomeVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    private var viewModel: HomeVMInterface!
    private let disposeBag = DisposeBag()
    private var currentForum: Forum?
    private var postList = [Post]()
    private var showList = [Post]()
    private var window: UIWindow {
        return UIApplication.shared.windows.first!
    }
    private lazy var btnBG: UIButton = {
        let button = UIButton(frame: self.view.frame)
        button.layer.zPosition = 6
        button.backgroundColor = .black
        button.alpha = 0.5
        button.addTarget(self, action: #selector(self.close), for: .touchUpInside)
        return button
    }()
    private var viewMenu: Drawer?
    private var logoView = [UIImageView]()
    private var user: User?
    private var exitTime: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeViewModel()
        initView()
        preloadUserdata()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        ToolbarView.shared.show(true)
        guard let currentForum = currentForum else {
//            LoadingView.shared.show(true)
            self.viewModel.getForums()
            return
        }
        //第一次進入頁面 或 距上次離開頁面已過60秒
        if self.exitTime == nil || Date().timeIntervalSince(self.exitTime ?? Date()) > 60 {
            self.viewModel.getPosts(alias: currentForum.alias)
        }
        //        viewModel.getRecentPost()
            
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.exitTime = Date()
    }
}
// MARK: - SubscribeViewModel
extension HomeVC {
    private func subscribeViewModel() {
        
        viewModel = HomeVM()
        viewModel.recentPostSubject.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            self.showList = self.postList
            self.tableView.reloadData()
        }, onError: { error in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: disposeBag)
        
        viewModel.commentSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (comments, index) in
            let vc = self.storyboard?.instantiateViewController(identifier: "PostVC") as! PostVC
            vc.setContent(post: self.showList[index], commentList: comments)
            vc.navigationItem.title = self.showList[index].title
            vc.modalPresentationStyle = .formSheet
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: disposeBag)
        
        viewModel.forumsSubject.observeOn(MainScheduler.instance).subscribe(onNext: { forums in
            self.confiDrawer(forums)
            if !forums.isEmpty {
//                self.viewModel.getPosts(alias: forums[0].alias)
//                self.currentForum = forums[0]
                let forums = forums.first { return $0.name == "穿搭"}
                self.viewModel.getPosts(alias: forums?.alias ?? "")
                self.currentForum = forums
                self.navigationItem.title = forums?.name ?? ""
            }
        }, onError: { error in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: disposeBag)
        
        viewModel.postsSubject.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            if let currentForum = self.currentForum, currentForum.name == "廢文" {
                self.showList = self.postList.filter({$0.school.contains("弘光")})
            } else {
                self.showList = self.postList
            }
            self.tableView.reloadData()
            LoadingView.shared.show(false)
            if !self.showList.isEmpty {
                self.view.layoutIfNeeded()
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            }
        }, onError: { error in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: disposeBag)
        
        viewModel.userDataSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (user) in
            self.user = user
            ToolbarView.shared.setAvatar(url: user.avatar)
        }, onError: { (error) in
            LoginManager.shared.showAlertView(errorMessage: error.localizedDescription, handler: nil)
        }).disposed(by: self.disposeBag)
        
    }
}

// MARK: - SetupUI
extension HomeVC {
    private func initView() {
        ToolbarView.shared.setDelegate(self)
        self.bottomSpace.constant = Size.bottomSpace
        
        confiTableView()
        confiNavBarItem()
    }
    private func confiNavBarItem() {
        let btnMenu = UIButton()
        btnMenu.setImage(UIImage(named: ImageInfo.menu), for: .normal)
        btnMenu.contentMode = .scaleAspectFit
        btnMenu.addTarget(self, action: #selector(self.showMenu), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnMenu)
        
        let btnLogout = UIButton()
        btnLogout.setImage(UIImage(named: ImageInfo.exit), for: .normal)
        btnLogout.contentMode = .scaleAspectFit
        btnLogout.imageEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
        btnLogout.addTarget(self, action: #selector(self.exit), for: .touchUpInside)
        navigationItem.setRightBarButtonItems([UIBarButtonItem(customView: btnLogout)], animated: false)
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    private func confiDrawer(_ forums: [Forum]) {
        guard let insets = UIApplication.shared.windows.first?.safeAreaInsets else {
            return
        }
        self.viewMenu = UINib(nibName: "Drawer", bundle: nil).instantiate(withOwner: nil, options: nil).first as? Drawer
        self.viewMenu?.frame = CGRect(x: -self.view.bounds.width / 3, y: insets.top, width: 200, height: self.view.bounds.height - insets.top)
        self.viewMenu?.layer.zPosition = 7
        self.viewMenu?.setContent(forumList: forums)
        self.viewMenu?.setDelegate(self)
    }
    @objc private func showMenu() {
        self.window.addSubview(self.btnBG)
        if let viewMenu = self.viewMenu {
            self.window.addSubview(viewMenu)
            UIView.animate(withDuration: 1, animations: {
                viewMenu.frame.origin.x += self.view.bounds.width / 3
            })
        }
    }
    @objc private func exit() {
        self.navigationController?.popViewController(animated: true)
    }
    @objc private func close() {
        UIView.animate(withDuration: 0.3, animations: {
            self.viewMenu?.frame.origin.x -= self.view.bounds.width / 3
        }) { _ in
            self.viewMenu?.removeFromSuperview()
            self.btnBG.removeFromSuperview()
        }
    }
}
// MARK: - PreloadData
extension HomeVC {
    private func preloadUserdata() {
        let user = ModelSingleton.shared.userConfig.user
        if user.uid != "" {
            self.viewModel.getUserData(uid: user.uid)
        }
    }
}
// MARK: - UITableViewDelegate
extension HomeVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.selectionStyle = .none
        cell.setContent(post: showList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.getComment(list: showList, index: indexPath.row)
    }
}
// MARK: - DrawerDelegate
extension HomeVC: DrawerDelegate {
    func checkOutPage(page: Forum) {
        self.currentForum = page
        self.navigationItem.title = page.name
        self.close()
        viewModel.getPosts(alias: page.alias)
    }
}
// MARK: - ToolbarViewDelegate
extension HomeVC: ToolbarViewDelegate {
    func setupPage(_ page: PageType) -> PageType {
        self.navigationController?.popToViewController(self, animated: false)
        switch page {
        case .Home:
            break
        case .Game:
            let vc = UIStoryboard(name: page.name, bundle: nil).instantiateInitialViewController() as! GameVC
            self.navigationController?.pushViewController(vc, animated: false)
        case .Card:
            let vc = UIStoryboard(name: page.name, bundle: nil).instantiateInitialViewController() as! CardVC
            self.navigationController?.pushViewController(vc, animated: false)
        case .Notify:
            let vc = UIStoryboard(name: page.name, bundle: nil).instantiateInitialViewController() as! NotifyVC
            self.navigationController?.pushViewController(vc, animated: false)
        case .Profile:
            let vc = UIStoryboard(name: page.name, bundle: nil).instantiateInitialViewController() as! ProfileVC
            self.navigationController?.pushViewController(vc, animated: false)
        }
        return page
    }
}

