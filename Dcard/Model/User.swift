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
    public var card: Card
    
    init(uid: String = "", lastName: String = "", firstName: String = "", birthday: String = "", sex: String = "", phone: String = "", address: String = "", password: String = "", avatar: String = "", friend: [String] = [String](), isVerified: Bool = true, facebookIsConnected: Bool = true, googleIsConnected: Bool = true, appleIsConnected: Bool = false, country: Country = Country(name: "台灣", alias: "TW", code: "+86"), card: Card = Card(id: "a_a", post: [], name: "野比大雄", photo: "https://firebasestorage.googleapis.com/v0/b/dcard-test-478e3.appspot.com/o/user%2Fa_a.png?alt=media&token=61936705-d591-43ac-ae87-96e77328e809", sex: "男性", introduce: """
於8月7日出生，住所在日本東京都練馬區月見台鈴木原道，但時代雖然改變，卻一直以居於東京小學生的身份出現，永遠都是十歲（在漫畫中，一直都是小學四年級生，在大山版動畫早期是四年級生（而且常因「胖虎、狗跟水溝」而受苦），中後期與水田版動畫變成五年級生），為家中獨生子，與父母及哆啦A夢同住。
""", country: "日本", school: "私立臺灣肥宅學院", department: "邊緣人養成學系", article: "", birthday: "8月7日 獅子座", love: "只愛靜香")) {
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
        self.card = card
    }
}
