//
//  CardInfoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/5.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum CellType: Int {
    case article = 1
    case country
    case introduce
    
    var titel: String {
        switch self {
        case .article:
            return "我的文章"
        case .country:
            return "國家"
        case .introduce:
            return "簡介"
        }
    }
}

class CardInfoVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var card: Card?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    
    func setContent(card: Card) {
        self.card = card
    }
}
extension CardInfoVC {
    private func initView() {
        confiNav()
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "CardInfoCell", bundle:
            nil), forCellReuseIdentifier: "CardInfoCell")
        self.tableView.register(UINib(nibName: "CardInfoTitleCell", bundle:
        nil), forCellReuseIdentifier: "CardInfoTitleCell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.layer.cornerRadius = 15
    }
    private func confiNav() {
        self.navigationController?.navigationBar.backgroundColor = #colorLiteral(red: 0, green: 0.3285208941, blue: 0.5748849511, alpha: 0.7834974315)
        self.navigationItem.setHidesBackButton(false, animated: false)
        let titleView = UILabel()
        titleView.attributedText = NSAttributedString(string: "今日 Dcard", attributes: [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont.systemFont(ofSize: 22, weight: .bold)])
        self.navigationItem.titleView = titleView
        let btnHint = UIBarButtonItem(image: UIImage(named: ImageInfo.semibold_s), style: .done, target: self, action: #selector(alert))
        btnHint.imageInsets = UIEdgeInsets(top: 2, left: 2, bottom: -2, right: -2)
        self.navigationItem.setRightBarButton(btnHint, animated: true)
    }
    @objc private func alert() {
        
    }
}
extension CardInfoVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        4
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        if row != 0 {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CardInfoCell") as? CardInfoCell {
                if row == 1 {
                    cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.article ?? "")
                } else if row == 2 {
                    cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.country ?? "")
                } else {
                    cell.setContent(title: CellType(rawValue: row)?.titel ?? "", content: card?.introduce ?? "")
                }
                return cell
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier: "CardInfoTitleCell") as? CardInfoTitleCell {
                cell.setContent(photo: card?.photo ?? "", sex: card?.sex ?? "", school: card?.school ?? "")
                return cell
            }
        }
        return UITableViewCell()
    }
}
