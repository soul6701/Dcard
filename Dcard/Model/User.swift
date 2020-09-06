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
    public let password: String
    public var avatar: String
    
    init(uid: String = "", lastName: String = "", firstName: String = "", birthday: String = "", sex: String = "", phone: String = "", address: String = "", password: String = "", avatar: String = "") {
        self.uid = uid
        self.lastName = lastName
        self.firstName = firstName
        self.birthday = birthday
        self.sex = sex
        self.phone = phone
        self.address = address
        self.password = password
        self.avatar = avatar
    }
}
