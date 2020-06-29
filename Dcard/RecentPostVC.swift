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

class RecentPostVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var viewModel: RecentPostInterface!
    private var disposeBag = DisposeBag()
    private var postList = [Post]()
    private var showList = [Post]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        confiViewModel()
        confiTableView()
    }
    private func confiTableView() {
        tableView.register(UINib(nibName: "RecentPostCell", bundle: nil), forCellReuseIdentifier: "RecentPostCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func confiViewModel() {
        viewModel = RecentPostVM()
        viewModel.recentPost.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            self.tableView.reloadData()
        }, onError: { error in
            print(error)
            }).disposed(by: disposeBag)
        viewModel.whysoserious.observeOn(MainScheduler.instance).subscribe(onNext: { posts in
            self.postList = posts
            self.showList = self.postList.filter({$0.gender == "F"})
            self.tableView.reloadData()
        }, onError: { error in
            print(error)
            }).disposed(by: disposeBag)
        
//        viewModel.getRecentPost()
        viewModel.getWhysoserious()
    }
}
extension RecentPostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return showList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentPostCell", for: indexPath) as! RecentPostCell
        cell.setContent(post: showList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
}

