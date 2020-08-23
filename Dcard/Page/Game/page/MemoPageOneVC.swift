//
//  MemoPageOneVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum MemoPageOneCellMode: Int {
    case income = 0
    case expend = 1
    case net = 2
    case member = 3
    case heart = 4
    case book = 5
    case mood = 6
    case fitness = 7
}

class MemoPageCellConponent {
    var image: String
    var name: String
    
    init(image: String, name: String) {
        self.image = image
        self.name = name
    }
}
class MemoPageOneVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    
    
    private var memberList = ["巧虎", "琪琪", "桃樂比", "玲玲"]
    private var thankList = ["司機大哥推薦道地美食", "餐廳額外招待", "系隊贏得比賽"]
    private var improveList = ["作業遲交", "沈溺手機", "面對主管態度輕浮"]
    private var starList = [false, false, false, false, false]
    private var list: [[String]] {
        var _list = [[String]]()
        _list.append(memberList)
        _list.append(thankList)
        _list.append(improveList)
        return _list
    }
    private var showList = [false, false, false, false, false, false, false, false]
    private var income = 0
    private var expend = 0
    private var net = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
    }
    
}
extension MemoPageOneVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MemoPageCell", bundle: nil), forCellReuseIdentifier: "cell1")
    }
    private func calculate() {
        self.net = self.income - self.expend
        self.tableView.reloadRows(at: [IndexPath(row: 2, section: 0)], with: .none)
    }
    func setContent() {
        
    }
}
extension MemoPageOneVC: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 3
        case 1:
            return 4
        default:
            return 1
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        let row = indexPath.row
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell1", for: indexPath) as? MemoPageCell else {
            return UITableViewCell()
        }
        cell.setDelegate(self)
        cell.selectionStyle = .none
        
        var data = [Any]()
        var mode: MemoPageOneCellMode = .income
        
        mode = section == 0 ? MemoPageOneCellMode.init(rawValue: row)! : section == 1 ? MemoPageOneCellMode.init(rawValue: 3 + row)! : MemoPageOneCellMode.init(rawValue: 7 + row)!
        if mode == .net {
            cell.setDisabled()
            cell.setResult(money: self.net)
        }
        if mode != .mood {
            cell.setHideViewStar()
        }
        if !(mode == .income || mode == .expend || mode == .net) {
            cell.setHideTf()
        }
        if mode == .member || mode == .heart || mode == .book {
            data = list[row]
        }
        if mode == .mood {
            data = self.starList
        }
        cell.setContent(data: data, mode: mode, show: showList[mode.rawValue])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = indexPath.section
        let row = indexPath.row
        if section == 1 {
            return showList[row + 3] ? 300 : 50
        }
        if section == 2 {
            return showList[row + 7] ? 300 : 50
        }
        return 50
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = indexPath.section
        let row = indexPath.row
        if section == 1 {
            self.showList[row + 3] = !self.showList[row + 3]
        }
        if section == 2 {
            self.showList[row + 7] = !self.showList[row + 7]
        }
        if section != 0 {
            self.tableView.reloadData()
        }
    }
}

extension MemoPageOneVC: MemoPageCellDelegate {
    
    func setIncome(money: Int) {
        self.income = money
        calculate()
    }
    func setExpend(money: Int) {
        self.expend = money
        calculate()
    }
    func setStar(star: [Bool]) {
        self.starList = star
    }
    func showSelection() {
        let fitness = ["胸推", "二頭彎舉", "引體向上", "深蹲", "硬舉", "核心"]
        let alert = UIAlertController(title: "請選擇項目", message: "", preferredStyle: .actionSheet)
        fitness.forEach { (string) in
            alert.addAction(UIAlertAction(title: string, style: .default, handler: { _ in
                let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 2)) as! MemoPageCell
                cell.setFitness(item: string)
            }))
        }
        present(alert, animated: true)
    }
}
