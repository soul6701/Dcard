//
//  Extension_String.swift
//  Dcard
//
//  Created by Mason on 2020/10/24.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

extension String {
    func image() -> UIImage? {
        let size = CGSize(width: 30, height: 30)
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        UIColor.clear.set()
        let rect = CGRect(origin: .zero, size: size)
        UIRectFill(rect)
        (self as AnyObject).draw(in: rect, withAttributes: [.font: UIFont.systemFont(ofSize: 28)])
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func match(_ pattern: String, options: NSRegularExpression.Options) -> [String] {
        let regex = try! NSRegularExpression(pattern: pattern, options: options)
        let result = regex.matches(in: self, options: [], range: NSRange(location: 0, length: self.count))
        return result.map { return String(self[Range($0.range, in: self)!])}
    }
}
