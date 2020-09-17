//
//  MailVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol MailVCDelegate {
    
}
enum MailMode: Int {
    case all = 0
    case notyetReply
}
class MailVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    private var mailList = [Mail]()
    private var notyetReplyMailList: [Mail] {
        return self.mailList.filter({ return $0.message.first!.user == true})
    }
    private lazy var segmentedControl: UISegmentedControl = {
        let items = ["全部", "未回覆"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.layer.cornerRadius = 5.0
        segmentedControl.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.widthAnchor.constraint(equalToConstant: self.view.bounds.width / 3).isActive = true
        segmentedControl.addTarget(self, action: #selector(selectAllOrNotyetReply(_:)), for: .valueChanged)
        return segmentedControl
    }()
    private lazy var btnNavRight: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "square.grid.2x2.fill"), style: .plain, target: self, action: #selector(showAll))
        barButtonItem.tintColor = .white
        return barButtonItem
    }()
    private var mode: MailMode = .all {
        didSet {
            self.tableView.reloadData()
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ToolbarView.shared.show(false)
        initView()
    }
}
// MARK: - SetupUI
extension MailVC {
    private func initView() {
        confiNav()
        confiTableView()
        
        let users = [("靜香", "https://inmywordz.com/wp-content/uploads/20180320205746_43.jpg"), ("胖虎", "https://upload.wikimedia.org/wikipedia/zh/a/a4/Gigante.png"), ("小夫", "https://inmywordz.com/wp-content/uploads/20180318115342_25.jpg"), ("哆啦A夢", "https://encrypted-tbn0.gstatic.com/images?q=tbn%3AANd9GcTr_MSRwLun_otpF9dm0MqWHyyFqMaT6dtk6g&usqp=CAU"), ("小衫", "https://inmywordz.com/wp-content/uploads/20171122123158_40.jpg"), ("好物研究員", "https://i.imgur.com/IRNrRdA.jpg"), ("版務小天使",  "https://stickershop.line-scdn.net/stickershop/v1/product/1239735/LINEStorePC/main.png;compress=true")]
        var myCardList = [Card]()
        (0...6).forEach { (i) in
            myCardList.append(Card(id: "", post: [], name: users[i].0, photo: users[i].1, sex: "", introduce: "", country: "", school: "", department: "", article: "", birthday: "", love: ""))
        }
        
        var mailList = [Mail]()
        (0...6).forEach { (i) in
            var messageList = [Message]()
            let message = ["我先洗澡", "我是胖虎我是孩子王", "胖虎不要", "小咪約我看電影😳😳😳", "大雄👉👈其實我喜歡的是你😘", "欸欸你快看我新發的限動", "最近轉涼，要特別注意身體喔"]
            let messageCount = Int.random(in: 1...100)
            messageList.append(Message(user: Bool.random(), text: message[i], date: ["2020/09/15", "2021/02/21", "1900/04/21", "2100/05/11", "2020/08/02", "2001/01/30"].randomElement()!))
            (1...messageCount).forEach {(i) in
                messageList.append(Message(user: Bool.random(), text: ["睡了嗎", "早安", "最近轉涼，要特別注意身體喔", "週末要看電影嗎？", "欸欸你快看我新發的限動", "我先洗澡", "不要太晚睡～", "噁男88", "🙄🙄🙄", "我是胖虎我是孩子王"].randomElement()!, date: ["2020/09/15", "2021/02/21", "1900/04/21", "2100/05/11", "2020/08/02", "2001/01/30"].randomElement()!))
            }
            mailList.append(Mail(card: myCardList[i], message: messageList, isNew: Bool.random()))
        }
        self.mailList = mailList
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "MailCell", bundle: nil), forCellReuseIdentifier: "MailCell")
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: self.view.frame.width * 1 / 4, bottom: 0, right: 0)
    }
    private func confiNav() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationItem.titleView = self.segmentedControl
        self.navigationItem.setRightBarButton(self.btnNavRight, animated: false)
    }
    @objc private func showAll() {
        
    }
    @objc private func selectAllOrNotyetReply(_ sender: UISegmentedControl) {
        self.mode = MailMode(rawValue: self.segmentedControl.selectedSegmentIndex) ?? .all
    }
}
// MARK: - UITableViewDelegate
extension MailVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.mode == .all ? self.mailList.count : self.notyetReplyMailList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MailCell", for: indexPath) as! MailCell
        let mailList = self.mode == .all ? self.mailList : self.notyetReplyMailList
        cell.setContent(mail: mailList[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
