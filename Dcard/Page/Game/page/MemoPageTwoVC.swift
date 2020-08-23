//
//  MemoPageTwoVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/18.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

class MemoPageTwoVC: UIViewController {

    @IBOutlet weak var txtContent: UITextView!
    private var delegate: MemoPageVCDelegate?
    private var content = ""
    private var isEditable = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initView()
    }
    @IBAction func onClickEdit(_ sender: UIButton) {
        isEditable = !isEditable
        self.txtContent.isEditable = isEditable
    }
    @IBAction func onClickOK(_ sender: UIButton) {
        self.delegate?.saveDiary(content: txtContent.text)
    }
    @IBAction func onClickCamera(_ sender: UIButton) {
        
    }
    func setDelegate(_ delegate: MemoPageVCDelegate) {
        self.delegate = delegate
    }
    func setContent(content: String) {
        self.content = content
    }
    private func initView() {
        self.txtContent.isEditable = isEditable
        self.txtContent.text = self.content
        let imageAttachment = NSTextAttachment(image: UIImage(named: ImageInfo.launchImage)!)
        self.txtContent.attributedText = NSAttributedString(attachment: imageAttachment)
    }
}
