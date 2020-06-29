//
//  ViewController.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class RecentPostVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        confiTableView()
    }
    func confiTableView() {
        tableView.register(RecentPostCell.self, forCellReuseIdentifier: "cell")
        tableView.delegate = self
    }

}
extension RecentPostVC

