//
//  PostVC.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

class PostVC: UIViewController {

    @IBOutlet weak var excerptView: UITextView!
    var post: Post?
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let post = post else {
            return
        }
        excerptView.isEditable = false
        excerptView.text = post.excerpt
    }
    func setContent(post: Post) {
        self.post = post
    }
}
