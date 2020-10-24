//
//  ArticalVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/15.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

protocol ArticalVCDelegate {
    
}
class ArticalVC: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    private var tfPassword: UITextField?
    private var tfAddress: UITextField?
    private var articalList = [Post]()
    private var times = 1
    private var user: User {
        return ModelSingleton.shared.userConfig.user
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ToolbarView.shared.show(false)
        initView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        PrivacyView.shared.setDelegate(self)
        PrivacyView.shared.show(vc: self)
    }
    func setContent(articalList: [Post], title: String) {
        self.articalList = articalList
        self.navigationItem.title = title
    }
}
// MARK: - SetupUI
extension ArticalVC {
    private func initView() {
        confiTableView()
    }
    private func confiTableView() {
        self.tableView.register(UINib(nibName: "PostCell", bundle: nil), forCellReuseIdentifier: "PostCell")
    }
    private func showPasswordView() {
        var alertController = UIAlertController(title: "請輸入密碼", message: "請輸入您登入ChiaCard用的密碼，以查看受保護的內容", preferredStyle: .alert)
        alertController.addTextField { (tf) in
            tf.placeholder = "ChiaCard 登入密碼"
            tf.isSecureTextEntry = true
            tf.becomeFirstResponder()
            self.tfPassword = tf
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        let OKAction = UIAlertAction(title: "確認", style: .default) { (action) in
            if let password = self.tfPassword?.text, password == ModelSingleton.shared.userConfig.user.password {
                PrivacyView.shared.close()
            } else {
                alertController = UIAlertController(title: "驗證失敗", message: "請輸入正確密碼，並確認網路連線能力。", preferredStyle: .alert)
                let forgotPasswordAction = UIAlertAction(title: "忘記密碼", style: .default) { (action) in
                    alertController = UIAlertController(title: "重設密碼", message: "請輸入您忘記密碼的ChiaCard的帳號信箱，我們將會發送重置密碼信件給您。", preferredStyle: .alert)
                    alertController.addTextField { (tf) in
                        tf.text = ModelSingleton.shared.userConfig.user.address
                        tf.becomeFirstResponder()
                        self.tfAddress = tf
                    }
                    let cancelAction = UIAlertAction(title: "取消", style: .cancel)
                    let sendAction = UIAlertAction(title: "發送", style: .default) { (action) in
                        if self.tfAddress?.text == ModelSingleton.shared.userConfig.user.address {
                            ProfileManager.shared.showOKView(mode: .sendVefifymail) {
                                alertController.dismiss(animated: true, completion: nil)
                            }
                        }
                    }
                    alertController.addAction(cancelAction)
                    alertController.addAction(sendAction)
                    self.present(alertController, animated: true)
                }
                let OKAction = UIAlertAction(title: "好", style: .cancel, handler: nil)
                alertController.addAction(forgotPasswordAction)
                alertController.addAction(OKAction)
                self.present(alertController, animated: true)
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        self.present(alertController, animated: true)
    }
}
// MARK: - UITableViewDelegate
extension ArticalVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? self.articalList.count : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard indexPath.section == 0 else {
            let cell = UITableViewCell()
            cell.textLabel?.textColor = #colorLiteral(red: 0.6642242074, green: 0.6642400622, blue: 0.6642315388, alpha: 1)
            cell.textLabel?.text = "沒有更多囉！"
            cell.textLabel?.textAlignment = .center
            cell.separatorInset = .init(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude) //隱藏分隔線
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell", for: indexPath) as! PostCell
        cell.setContent(post: self.articalList[indexPath.row], mode: .profile)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return indexPath.section == 0 ? 120 : 180
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let vc = UIStoryboard.home.postVC
        let post = self.user.card.post[row]
        vc.setContent(post: post, commentList: [Comment()])
        vc.navigationItem.title = post.title
        vc.modalPresentationStyle = .formSheet
        self.navigationController?.pushViewController(vc, animated: true) {
            self.navigationController?.setNavigationBarHidden(false, animated: false)
        }
    }
}
// MARK: - ArticalVCDelegate
extension ArticalVC: ArticalVCDelegate {
//    func showBellModeView() {
//        ProfileManager.shared.showBellModeView()
//    }
}

// MARK: - PrivacyViewDelegate
extension ArticalVC: PrivacyViewDelegate {
    func didClickPassword() {
        if ModelSingleton.shared.preference.touchIDOn {
            ProfileManager.shared.showAuthenticationView(times: self.times) { (state) in
                switch state {
                case .success:
                    DispatchQueue.main.async {
                        PrivacyView.shared.close()
                    }
                case .fallback:
                    DispatchQueue.main.async {
                        self.showPasswordView()
                    }
                case .error:
                    break
                }
            }
        } else {
            showPasswordView()
        }
    }
}
