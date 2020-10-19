//
//  PostVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

class PostVC: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var excerptView: UITextView!
    @IBOutlet weak var btnShowComment: UIButton!
    @IBOutlet weak var bottomSpace: NSLayoutConstraint!
    
    private var post: Post?
    private var commentList: [Comment]?
    private var isEmpty = false
    private var viewSetting = UIView()
    private var viewBg = UIView()
    private var window: UIWindow!
    
    private var show: Bool! {
        didSet {
            show ? self.btnShowComment.setImage(UIImage(named: ImageInfo.down), for: .normal) : self.btnShowComment.setImage(UIImage(named: ImageInfo.up), for: .normal)
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(post: Post, commentList: [Comment]) {
        self.post = post
        self.commentList = commentList
        if commentList.isEmpty {
            isEmpty = true
        }
    }
}
extension PostVC {
    private func initView() {
        show = false
        ToolbarView.shared.show(false)
        guard let post = post, commentList != nil else {
            return
        }
        self.btnShowComment.isHidden = isEmpty
        self.window = UIApplication.shared.windows.first!
        self.excerptView.isEditable = false
        self.excerptView.text = post.excerpt
        
        self.tableView.register(UINib(nibName: "CommentCell", bundle: nil), forCellReuseIdentifier: "cell")
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    @IBAction func show(_ sender: UIButton) {
        self.show = !self.show
        self.bottomSpace.constant += self.show ? (self.commentList!.count <= 1 ? 200 : 400) : (self.commentList!.count <= 1 ? -200 : -400)
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
}
extension PostVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return commentList!.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentCell
        cell.selectionStyle = .none
        cell.setContent(comment: commentList![indexPath.row], view: view)
        cell.setDelegate(delegate: self)
        return cell
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 200
    }
}
extension PostVC: showSettingView {
    func showView(location: CGPoint, floor: Int) {
        guard let view = UINib(nibName: "SettingView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? SettingView else {
            return
        }
        guard let height = navigationController?.navigationBar.bounds.height else {
            return
        }
        self.viewBg = UIView(frame: CGRect(x: 0, y: Int(height + window.safeAreaInsets.top), width: Int(self.view.bounds.width), height: Int(self.view.bounds.height - height - window.safeAreaInsets.top)))
        self.viewBg.backgroundColor = .black
        self.viewBg.alpha = 0.5
        let tap = UITapGestureRecognizer(target: self, action: #selector(close))
        self.viewBg.addGestureRecognizer(tap)
        
        view.setContent(floor: floor)
        self.viewSetting = view
        self.viewSetting.frame = CGRect(x: location.x - 150, y: location.y - 80, width: 150, height: 80)
        
        self.window.addSubview(self.viewBg)
        self.window.addSubview(self.viewSetting)
    }
    @objc private func close() {
        self.viewBg.removeFromSuperview()
        self.viewSetting.removeFromSuperview()
    }
}
