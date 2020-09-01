//
//  LoginNAV.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/8/30.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

protocol LoginInfo {
    var lastName: String { get }
    var firstName: String { get }
    var sex: String { get }
    var sexOption: Int { get }
    var sexName: String { get }
    var sexNameOption: String { get }
    var birthday: String { get }
    var code: String { get }
    var alias: String { get }
    var phone: String { get }
    var address: String { get }
    var password: String { get }
    var avatar: UIImage? { get }
    var _delegate: LoginVCDelegate? { get }
}
import UIKit

class LoginNAV: UINavigationController, LoginInfo {
    
    private(set) var _delegate: LoginVCDelegate?
    private(set) var lastName: String = ""
    private(set) var firstName: String = ""
    private(set) var sex: String = ""
    private(set) var sexOption: Int = 0
    private(set) var sexName: String = ""
    private(set) var sexNameOption: String = ""
    private(set) var birthday: String = ""
    private(set) var code: String = "86"
    private(set) var alias: String = "TW"
    private(set) var phone: String = ""
    private(set) var address: String = ""
    private(set) var password: String = ""
    private(set) var avatar: UIImage? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    func setLoginInfo(lastname: String) {
        self.lastName = lastname
    }
    func setLoginInfo(firstName: String) {
        self.firstName = firstName
    }
    func setLoginInfo(sex: String) {
        self.sex = sex
    }
    func setLoginInfo(sexOption: Int) {
        self.sexOption = sexOption
    }
    func setLoginInfo(sexName: String) {
        self.sexName = sexName
    }
    func setLoginInfo(sexNameOption: String) {
        self.sexNameOption = sexNameOption
    }
    func setLoginInfo(birthday: String) {
        self.birthday = birthday
    }
    func setLoginInfo(code: String) {
        self.code = code
    }
    func setLoginInfo(alias: String) {
        self.alias = alias
    }
    func setLoginInfo(phone: String) {
        self.phone = phone
    }
    func setLoginInfo(address: String) {
        self.address = address
    }
    func setLoginInfo(password: String) {
        self.password = password
    }
    func setLoginInfo(avatar: UIImage) {
        self.avatar = avatar
    }
    func setDelegate(delegate: LoginVCDelegate) {
        self._delegate = delegate
    }
}
