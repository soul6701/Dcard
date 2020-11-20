//
//  Mood.swift
//  Dcard
//
//  Created by Mason on 2020/11/20.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

public struct Mood {
    public enum EmotionType: String, CaseIterable {
        case heart
        case haha
        case angry
        case cry
        case surprise
        case respect
        
        var imageText: String {
            var text: String = ""
            switch self {
            case .heart:
                text = "❤️"
            case .haha:
                text = "🤣"
            case .angry:
                text = "😡"
            case .cry:
                text = "😭"
            case .surprise:
                text = "😮"
            case .respect:
                text = "🙇‍♂️"
            }
            return text
        }
    }
    public var heart: [String] = []
    public var haha: [String] = []
    public var angry: [String] = []
    public var cry: [String] = []
    public var surprise: [String] = []
    public var respect: [String] = []
}
