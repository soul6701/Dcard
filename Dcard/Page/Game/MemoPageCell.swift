//
//  MemoPageCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum MemoPageCellMode: String {
    case income = "income"
    case expend = "expend"
    case net = "net"
    case member = "member"
    case heart = "heart"
    case book = "book"
    case mood = "mood"
    case fitness = "fitness"
}
protocol MemoPageCellDelegate {
    func setIncome(money: Int)
    func setExpend(money: Int)
    func openList(indexPath: IndexPath)
    func showSelection()
}
class MemoPageCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnOpen: UIButton!
    @IBOutlet weak var pro: NSLayoutConstraint!
    @IBOutlet weak var imageRow: UIImageView!
    @IBOutlet weak var txtEnter: UITextField!
    @IBOutlet weak var lbRow: UILabel!
    @IBOutlet weak var viewStar: UIStackView!
    @IBOutlet var imageStar: [UIImageView]!
    
    private var memberList = ["巧虎", "琪琪", "桃樂比", "玲玲"]
    private var thankList = ["司機大哥推薦道地美食", "早餐店阿姨叫我帥哥", "餐廳額外招待", "系隊贏得比賽"]
    private var improveList = ["作業遲交", "沈溺手機", "面對主管態度輕浮"]
    private var fitnessList = [String]()
    
    private var list = [String]()
    private var starList = [false, false, false, false, false]
    private var mode: MemoPageCellMode = .income
    private var delegate: MemoPageCellDelegate?
    private var indexPath = IndexPath()
    private var fitness = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        initView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func txtSetValue(_ sender: UITextField) {
        guard let txt = sender.text else {
            return
        }
        let num = !txt.isEmpty ? Int(txt)! : 0
        if mode == .income {
            self.delegate?.setIncome(money: num)
        } else {
            self.delegate?.setExpend(money: num)
        }
    }
    @IBAction func onClickOpen(_ sender: UIButton) {
        self.delegate?.openList(indexPath: self.indexPath)
    }
    
    func setDelegate(_ delegate: MemoPageCellDelegate) {
        self.delegate = delegate
    }
    
    func setContent(conponents: MemoPageCellConponent, indexPath: IndexPath) {
        self.imageRow.image = UIImage(named: conponents.image)
        self.lbRow.text = conponents.name
        self.indexPath = indexPath
        self.tableView.isHidden = !conponents.show
            
        self.btnOpen.isHidden = indexPath.section == 0 ? true : false
        if let mode = MemoPageCellMode.init(rawValue: conponents.image) {
            self.mode = mode
            
            switch mode {
            case .member:
                self.list = self.memberList
            case .heart:
                self.list = self.thankList
            case .book:
                self.list = self.improveList
            case .fitness:
                self.list = self.fitnessList
            default:
                break
            }
        }
    }
    func setHideTxt() {
        self.txtEnter.isHidden = true
        self.pro.constant = 100
    }
    func setHideBtn() {
        self.btnOpen.isHidden = true
    }
    func setDisabled() {
        self.txtEnter.isEnabled = false
        self.txtEnter.placeholder = "0"
    }
    func setResult(money: Int) {
        if money != 0 {
            self.txtEnter.text = "\(money)"
        } else {
            self.txtEnter.text = ""
        }
    }
    func setHideViewStar() {
        self.viewStar.isHidden = true
    }
    func setFitness(item: String) {
        self.fitness = item
        self.tableView.reloadData()
    }
}
extension MemoPageCell {
    private func initView() {
        self.txtEnter.delegate = self
        confiImageStar()
        confiTableview()
    }
    private func confiTableview() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.register(UINib(nibName: "MemoPageOneHeader", bundle: nil), forHeaderFooterViewReuseIdentifier: "MemoPageOneHeader")
    }
    private func confiImageStar() {
        
        for (index, value) in imageStar.enumerated() {
            let ges = UITapGestureRecognizer(target: self, action: #selector(setHighlight(_:)))
            ges.numberOfTapsRequired = 1
            value.isUserInteractionEnabled = true
            value.isHighlighted = starList[index]
            value.addGestureRecognizer(ges)
        }
    }
    @objc private func setHighlight(_ sender: UIGestureRecognizer) {
        if let tag = sender.view?.tag {
            for i in 0..<tag + 1 {
                starList[i] = !starList[i]
            }
        }
        reloadViewStar()
    }
    private func reloadViewStar() {
        for i in 0..<imageStar.count {
            imageStar[i].isHighlighted = starList[i]
            starList[i] = false
        }
    }
}
extension MemoPageCell: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mode == .heart || mode == .book || mode == .member || mode == .fitness {
            return list.count
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if mode == .heart || mode == .book || mode == .member || mode == .fitness {
            cell.textLabel?.text = self.list[indexPath.row]
        }
        cell.textLabel?.textAlignment = .right
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "MemoPageOneHeader") as! MemoPageOneHeader
        view.setDelegate(self)
        if mode == .fitness {
            view.setToFitness(item: self.fitness)
        }
        return view
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}

extension MemoPageCell: MemoPageOneHeaderDelegate {
    func showSelection() {
        self.delegate?.showSelection()
    }
    func addMember(name: String) {
        self.list.append(name)
        if mode == .fitness {
            self.fitnessList.append(name)
        }
        self.tableView.reloadData()
    }
}
extension MemoPageCell: UITextFieldDelegate {
    //限制只能輸入數字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = string.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length {
            let char = (string as NSString).character(at: loopIndex)
            return !(char < 48 || char > 57)
        }
        return true
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let txt = textField.text else {
            return false
        }
        let num = !txt.isEmpty ? Int(txt)! : 0
        if mode == .income {
            self.delegate?.setIncome(money: num)
        } else {
            self.delegate?.setExpend(money: num)
        }
        return true
    }
}
