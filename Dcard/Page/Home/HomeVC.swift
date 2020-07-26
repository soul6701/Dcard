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
    private var viewModel: RecentPostInterface!
    private var disposeBag = DisposeBag()
//    private var forumArray = [Forum]()
    private var currentForum: Forum?
    private var postList = [Post]()
    private var showList = [Post]()
    private var window: UIWindow!
    private var btnBg = UIButton()
    private var viewMenu: Drawer?
    private var logoView = [UIImageView]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        subscribeSubject()
        confiTableView()
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        ToolbarView.shared.show(true)
        guard let currentForum = currentForum else {
            viewModel.getForums()
            return
        }
        //        viewModel.getRecentPost()
        viewModel.getPosts(alias: currentForum.alias)
    }
}
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
extension HomeVC {
    private func subscribeSubject() {
        
        viewModel = HomeVM()
        viewModel.recentPostSubject.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            self.showList = self.postList
            self.tableView.reloadData()
        }, onError: { error in
            print(error)
        }).disposed(by: disposeBag)
        
        viewModel.commentSubject.observeOn(MainScheduler.instance).subscribe(onNext: { (comments, index) in
            let vc = self.storyboard?.instantiateViewController(identifier: "PostVC") as! PostVC
            vc.setContent(post: self.showList[index], commentList: comments)
            vc.navigationItem.title = self.showList[index].title
            vc.modalPresentationStyle = .formSheet
            self.navigationController?.pushViewController(vc, animated: true)
        }, onError: { error in
            print(error)
        }).disposed(by: disposeBag)
        
        viewModel.forumsSubject.observeOn(MainScheduler.instance).subscribe(onNext: { forums in
//            self.forumArray = forums
            self.confiDrawer(forums)
            if !forums.isEmpty {
                self.viewModel.getPosts(alias: forums[0].alias)
                self.currentForum = forums[0]
            }
        }, onError: { error in
            print(error)
        }).disposed(by: disposeBag)
        
        viewModel.postsSubject.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            if let currentForum = self.currentForum, currentForum.name == "廢文" {
                self.showList = self.postList.filter({$0.school.contains("弘光")})
            } else {
                self.showList = self.postList
            }
            self.tableView.reloadData()
            if !self.showList.isEmpty {
                self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .top)
            }
        }, onError: { error in
            print(error)
        }).disposed(by: disposeBag)
    }
}
extension HomeVC {
    private func initView() {
        window = UIApplication.shared.windows.first!
        let btnMenu = UIButton()
        btnMenu.setImage(UIImage(named: "menu"), for: .normal)
        btnMenu.addTarget(self, action: #selector(showMenu), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnMenu)
    }
    private func confiTableView() {
        tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func confiDrawer(_ forums: [Forum]) {
        guard let insets = UIApplication.shared.windows.first?.safeAreaInsets else {
            return
        }
        viewMenu = UINib(nibName: "Drawer", bundle: nil).instantiate(withOwner: nil, options: nil).first as? Drawer
        viewMenu?.frame = CGRect(x: -self.view.bounds.width / 3, y: insets.top, width: 200, height: self.view.bounds.height - insets.top)
        viewMenu?.layer.zPosition = 7
        viewMenu?.setContent(forumList: forums)
        viewMenu?.setDelegate(delegate: self)
        
        btnBg.layer.zPosition = 6
        btnBg.frame = view.frame
        btnBg.backgroundColor = .black
        btnBg.alpha = 0.5
        btnBg.addTarget(self, action: #selector(close), for: .touchUpInside)
    }
    @objc private func showMenu() {
        window.addSubview(btnBg)
        if let viewMenu = viewMenu {
            window.addSubview(viewMenu)
            UIView.animate(withDuration: 1, animations: {
                viewMenu.frame.origin.x += self.view.bounds.width / 3
            })
        }
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
extension HomeVC: DrawerDelegate {
    func checkOutPage(page: Forum) {
        self.currentForum = page
        self.navigationItem.title = page.name
        close()
        viewModel.getPosts(alias: page.alias)
    }
}

