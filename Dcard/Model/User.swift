//
//  User.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/1.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation

public struct User {
    
    public let uid: String
    public let lastName: String
    public let firstName: String
    public let birthday: String
    public let sex: String
    public var phone: String
    public var address: String
    public var password: String
    public var avatar: String
    public var friend: [String]
    public var isVerified: Bool
    public var facebookIsConnected: Bool
    public var googleIsConnected: Bool
    public var appleIsConnected: Bool
    public var country: Country
    
    init(uid: String = "", lastName: String = "", firstName: String = "", birthday: String = "", sex: String = "", phone: String = "", address: String = "", password: String = "", avatar: String = "", friend: [String] = [String](), isVerified: Bool = true, facebookIsConnected: Bool = true, googleIsConnected: Bool = true, appleIsConnected: Bool = false, country: Country = Country(name: "台灣", alias: "TW", code: "+86")) {
        self.uid = uid
        self.lastName = lastName
        self.firstName = firstName
        self.birthday = birthday
        self.sex = sex
        self.phone = phone
        self.address = address
        self.password = password
        self.avatar = avatar
        self.friend = friend
        self.isVerified = isVerified
        self.facebookIsConnected = facebookIsConnected
        self.googleIsConnected = googleIsConnected
        self.appleIsConnected = appleIsConnected
        self.country = country
    }
}
