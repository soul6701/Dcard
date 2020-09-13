//
//  DescriptionVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/25.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class DescriptionVC: UIViewController {

    @IBOutlet weak var imageTitle: UIImageView!
    @IBOutlet weak var lbTitle: UILabel!
    @IBOutlet weak var tvContent: UITextView!
    
    private var content = ""
    private var _title = ""
    private var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    func setContent(title: String, content: String, image: UIImage = UIImage()) {
        self._title = title
        self.content = content
        self.image = image
    }
    private func initView() {
        self.imageTitle.image = self.image
        self.lbTitle.text = self._title
        self.tvContent.text = self.content
        
        let btnClose = UIButton()
        btnClose.setAttributedTitle(NSAttributedString(string: "關閉", attributes: [NSAttributedString.Key.foregroundColor: UIColor.black]), for: .normal)
        btnClose.addTarget(self, action: #selector(close), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: btnClose)
    }
    @objc private func close() {
        self.dismiss(animated: true, completion: nil)
    }
}
