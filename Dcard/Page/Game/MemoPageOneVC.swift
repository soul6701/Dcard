//
//  MemoPageOneVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class MemoPageCellConponent {
    var image: String
    var name: String
    var show: Bool
    
    init(image: String, name: String, show: Bool = false) {
        self.image = image
        self.name = name
        self.show = show
    }
}
class MemoPageOneVC: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private let sectionOneList: [MemoPageCellConponent] = [MemoPageCellConponent(image: "income", name: "收入"), MemoPageCellConponent(image: "expend", name: "支出"), MemoPageCellConponent(image: "net", name: "淨賺")]
    private let sectionTwoList: [MemoPageCellConponent] = [MemoPageCellConponent(image: "member", name: "相遇的人"), MemoPageCellConponent(image: "heart", name: "感恩的事"), MemoPageCellConponent(image: "book", name: "可以做得更好"), MemoPageCellConponent(image: "mood", name: "自我評價")]
    private let sectionThreeList: [MemoPageCellConponent] = [MemoPageCellConponent(image: "fitness", name: "健身")]
    private var list: [[MemoPageCellConponent]] {
        var _list = [[MemoPageCellConponent]]()
        _list.append(sectionOneList)
        _list.append(sectionTwoList)
        _list.append(sectionThreeList)
        return _list
    }
    
    private var income = 0
    private var expend = 0
    private var net = 0
    private var fitness = ""
    
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
}
extension MemoPageOneVC: UITableViewDelegate, UITableViewDataSource {
    
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return sectionOneList.count
        case 1:
            return sectionTwoList.count
        default:
            return sectionThreeList.count
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
        cell.setContent(conponents: list[section][row], indexPath: indexPath)
        
        if section == 0 {
            if row == 2 {
                cell.setDisabled()
                cell.setResult(money: self.net)
            }
            cell.setHideViewStar()
        } else {
            if row == 3 {
                cell.setHideBtn()
            } else {
                cell.setHideViewStar()
            }
            cell.setHideTxt()
            
            if section == 2 {
                cell.setFitness(item: fitness)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return list[indexPath.section][indexPath.row].show ? 300 : 50
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
    func openList(indexPath: IndexPath) {
        self.list[indexPath.section][indexPath.row].show = !self.list[indexPath.section][indexPath.row].show
        self.tableView.reloadData()
    }
    func showSelection() {
        let fitness = ["胸推", "二頭彎舉", "引體向上", "深蹲", "硬舉", "核心"]
        let alert = UIAlertController(title: "請選擇項目", message: "", preferredStyle: .actionSheet)
        fitness.forEach { (string) in
            alert.addAction(UIAlertAction(title: string, style: .default, handler: { _ in
                self.fitness = string
                self.tableView.reloadRows(at: [IndexPath(row: 0, section: 2)], with: .none)
            }))
        }
        present(alert, animated: true)
        
    }
}
