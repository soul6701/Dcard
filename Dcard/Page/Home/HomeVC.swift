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
    private var viewModel: RecentPostInterface!
    private var disposeBag = DisposeBag()
    private var currentForum: Forum?
    private var postList = [Post]()
    private var showList = [Post]()
    private var window: UIWindow!
    private var btnBg = UIButton()
    private var viewMenu: Drawer?
    private var logoView = [UIImageView]()
    private var uid: String!
    private var user: User?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeViewModel()
        initView()
        preloadUserdata()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         self.navigationController?.navigationBar.isHidden = false
        ToolbarView.shared.show(true)
        guard let currentForum = currentForum else {
            LoadingView.shared.show(true)
            viewModel.getForums()
            return
        }
        //        viewModel.getRecentPost()
        viewModel.getPosts(alias: currentForum.alias)
    }
    func setUid(uid: String) {
        self.uid = uid
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
                self.viewModel.getPosts(alias: forums[1].alias)
                self.currentForum = forums[1]
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
//            LoadingView.shared.show(false)
            if !self.showList.isEmpty {
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
        ToolbarView.shared.setDelegate(delegate: self)
        self.window = UIApplication.shared.windows.first!
        self.bottomSpace.constant = 80
        
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: btnLogout)
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
        self.viewMenu?.setDelegate(delegate: self)
        
        self.btnBg.layer.zPosition = 6
        self.btnBg.frame = view.frame
        self.btnBg.backgroundColor = .black
        self.btnBg.alpha = 0.5
        self.btnBg.addTarget(self, action: #selector(self.close), for: .touchUpInside)
    }
    @objc private func showMenu() {
        self.window.addSubview(btnBg)
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
            self.btnBg.removeFromSuperview()
        }
    }
}
// MARK: - PreloadData
extension HomeVC {
    private func preloadUserdata() {
        self.viewModel.getUserData(uid: self.uid)
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
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard let currentForum = currentForum else {
            return
        }
        if scrollView.contentOffset.y < 0 {
//            viewModel.getWhysoserious()
            viewModel.getPosts(alias: currentForum.alias)
        }
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
    func setupPage(_ page: PageType?) {
        
        var vc = UIViewController()
        guard let page = page else {
            return
        }
        switch page {
        case .Game:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! GameVC
        case .Catalog:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! CatalogVC
        case .Home:
            if let nav = self.navigationController {
                for vc in nav.viewControllers where vc is HomeVC {
                    self.navigationController?.popToViewController(vc, animated: false)
                }
            }
            return
        case .Notify:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! NotifyVC
        case .Profile:
            vc = UIStoryboard(name: page.rawValue, bundle: nil).instantiateInitialViewController() as! ChatRoomVC
        }
        self.navigationController?.pushViewController(vc, animated: false)
    }
}

