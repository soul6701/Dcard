//
//  APIInfo.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/21.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit

enum HttpMethod: String {
    case POST = "POST"
    case GET = "GET"
    case PUT = "PUT"
    case DELETE = "DELETE"
}

class APIInfo {
    static var ServiceDomain = "https://dcard.tw/"
    static var URL_Domain: String {
        return "\(ServiceDomain)_api/"
    }
    static var post = "posts"
    static var whysoserious = "forums/whysoserious/posts"
}
