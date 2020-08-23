//
//  MemoPageCell.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol MemoPageCellDelegate {
    func setIncome(money: Int)
    func setExpend(money: Int)
    func setStar(star: [Bool])
    func showSelection()
}
class MemoPageCell: UITableViewCell {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var btnOpen: UIButton!
    @IBOutlet weak var pro: NSLayoutConstraint!
    @IBOutlet weak var imageRow: UIImageView!
    @IBOutlet weak var tfEnter: UITextField!
    @IBOutlet weak var lbRow: UILabel!
    @IBOutlet weak var viewStar: UIStackView!
    @IBOutlet var imageStar: [UIImageView]!
    
    private let itemList: [MemoPageCellConponent] = [MemoPageCellConponent(image: ImageInfo.income, name: "收入"), MemoPageCellConponent(image: ImageInfo.expend, name: "支出"), MemoPageCellConponent(image: ImageInfo.net, name: "淨賺"), MemoPageCellConponent(image: ImageInfo.member, name: "相遇的人"), MemoPageCellConponent(image: ImageInfo.heart, name: "感恩的事"), MemoPageCellConponent(image: ImageInfo.book, name: "可以做得更好"), MemoPageCellConponent(image: ImageInfo.mood, name: "自我評價"), MemoPageCellConponent(image: ImageInfo.fitness, name: "健身")]
    private var fitnessList = [String]()
    private var list = [String]()
    private var starList = [false, false, false, false, false]
    private var mode: MemoPageOneCellMode = .income
    private var delegate: MemoPageCellDelegate?
    private var fitness = ""
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codeu
        initView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tfSetValue(_ sender: UITextField) {
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
    func setDelegate(_ delegate: MemoPageCellDelegate) {
        self.delegate = delegate
    }
    
    func setContent(data: [Any], mode: MemoPageOneCellMode, show: Bool) {
        self.mode = mode
        self.imageRow.image = UIImage(named: itemList[mode.rawValue].image)
        self.lbRow.text = itemList[mode.rawValue].name
        self.tableView.isHidden = !show
        self.btnOpen.isHidden = mode == .income || mode == .expend || mode == .net || mode == .mood
        if mode == .heart || mode == .book || mode == .member {
            self.list = (data as! [String])
        }
        if mode == .mood {
            self.starList = (data as! [Bool])
        }
    }
    func setHideTf() {
        self.tfEnter.isHidden = true
        self.pro.constant = 100
    }
    func setDisabled() {
        self.tfEnter.isEnabled = false
        self.tfEnter.placeholder = "0"
    }
    func setResult(money: Int) {
        if money != 0 {
            self.tfEnter.text = "\(money)"
        } else {
            self.tfEnter.text = ""
        }
    }
    func setHideViewStar() {
        self.viewStar.isHidden = true
    }
    func setFitness(item: String) {
        (self.tableView.headerView(forSection: 0) as! MemoPageOneHeader).setToFitness(item: item)
    }
}
extension MemoPageCell {
    private func initView() {
        self.tfEnter.delegate = self
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
                self.starList[i] = !self.starList[i]
            }
        }
        self.delegate?.setStar(star: self.starList)
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
            view.setToFitness(item: "")
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
