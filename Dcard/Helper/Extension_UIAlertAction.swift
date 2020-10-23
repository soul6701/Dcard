//
//  Extension_UIAlertAction.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/16.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

///警告視窗屬性設置
extension UIAlertAction {
    var titleTextColor: UIColor? {
        get {
            return self.value(forKey: "titleTextColor") as? UIColor
        } set {
            self.setValue(newValue, forKey: "titleTextColor")
        }
    }
}
extension UIAlertController {
    func setMessageString(textSize: CGFloat, color: UIColor) {
        let message = NSMutableAttributedString(string: self.message!, attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)])
        self.setValue(message, forKey: "attributedMessage")
    }
    func setTitleString(textSize: CGFloat, color: UIColor) {
        let title = NSMutableAttributedString(string: self.title!, attributes: [NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.font: UIFont.systemFont(ofSize: textSize)])
        self.setValue(title, forKey: "attributedTitle")
    }
    //新增收藏分類
    static func showNewFavoriteCatolog(_ target: UIViewController, cancelHandler: @escaping () -> (), OKHandler: @escaping (_ text: String) -> (), disposeBag: DisposeBag) {
        var _tf: UITextField!
        let alertController = UIAlertController(title: "建立收藏分類", message: "為你的收藏分類命名", preferredStyle: .alert)
        alertController.addTextField { (tf) in
            _tf = tf
            _tf.becomeFirstResponder()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            cancelHandler()
        }
        let OKAction = UIAlertAction(title: "建立", style: .default) { (action) in
            OKHandler(_tf?.text ?? "")
        }
        alertController.addAction(cancelAction)
        alertController.addAction(OKAction)
        target.present(alertController, animated: true)
        
        let OKActionValid = _tf?.rx.text.orEmpty.map({ return !$0.isEmpty })
        OKActionValid?.bind(to: OKAction.rx.isEnabled).disposed(by: disposeBag)
    }
}
