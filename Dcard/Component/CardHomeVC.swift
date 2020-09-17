//
//  CardHomeVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class CardHomeVC: UIViewController {
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: "CardHomeVC", bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
}
// MARK: - SetupUI
extension CardHomeVC {
    private func initView() {
        confiTableview()
    }
    private func confiTableview() {
//        self.tableView.contentInset = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
//        self.tableView.scrollIndicatorInsets = UIEdgeInsets(top: 180, left: 0, bottom: 0, right: 0)
//        let view = UIView(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.width, height: 180))
//        view.backgroundColor = .black
    }
    
}
// MARK: - UITableViewDelegate
extension CardHomeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.backgroundColor = indexPath.section == 0 ? .blue : .yellow
        return cell
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "所有文章"
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 180 : 120
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? CGFloat.leastNonzeroMagnitude : 20
    }
}
