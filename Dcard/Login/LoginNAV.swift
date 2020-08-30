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
    var phone: String { get }
    var address: String { get }
    var password: String { get }
}
import UIKit

class LoginNAV: UINavigationController, LoginInfo {
    
    var lastName: String {
        return _lastName
    }
    var firstName: String {
        return _firstName
    }
    var sex: String {
        return _sex
    }
    var sexOption: Int {
        return _sexOption
    }
    var sexName: String {
        return _sexName
    }
    var sexNameOption: String {
        return _sexNameOption
    }
    var birthday: String {
        return _birthday
    }
    var phone: String {
        return _phone
    }
    var address: String {
        return _address
    }
    var password: String {
        return _password
    }
    
    private var _lastName: String = ""
    private var _firstName: String = ""
    private var _sex: String = ""
    private var _sexOption: Int = 0
    private var _sexName: String = ""
    private var _sexNameOption: String = ""
    private var _birthday: String = ""
    private var _phone: String = ""
    private var _address: String = ""
    private var _password: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    func setLoginInfo(lastname: String) {
        self._lastName = lastname
    }
    func setLoginInfo(firstName: String) {
        self._firstName = firstName
    }
    func setLoginInfo(sex: String) {
        self._sex = sex
    }
    func setLoginInfo(sexOption: Int) {
        self._sexOption = sexOption
    }
    func setLoginInfo(sexName: String) {
        self._sexName = sexName
    }
    func setLoginInfo(sexNameOption: String) {
        self._sexNameOption = sexNameOption
    }
    func setLoginInfo(birthday: String) {
        self._birthday = birthday
    }
    func setLoginInfo(phone: String) {
        self._phone = phone
    }
    func setLoginInfo(address: String) {
        self._address = address
    }
    func setLoginInfo(password: String) {
        self._password = password
    }
}
