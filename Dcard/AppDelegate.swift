//
//  AppDelegate.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/6/17.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import UIKit
import IQKeyboardManagerSwift
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    ///當前界面支持的方向（默認情況下只能豎屏，不能橫屏顯示）
    var interfaceOrientations:UIInterfaceOrientationMask = .portrait {
        didSet{
            //強制設置成直屏
            if interfaceOrientations == .portrait {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
            }else if !interfaceOrientations.contains(.portrait) { //強制設置成橫屏
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue,
                                          forKey: "orientation")
            }
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        print("height: \(UIScreen.main.bounds.height) width: \(UIScreen.main.bounds.width)")
        Thread.sleep(forTimeInterval: 1)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldShowToolbarPlaceholder = false
        IQKeyboardManager.shared.enableAutoToolbar = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        IQKeyboardManager.shared.disabledToolbarClasses = [ChatRoomVC.self, CreateAccountVC.self, SelectCountryVC.self, SetSexVC.self, SetPasswordVC.self]
        IQKeyboardManager.shared.disabledTouchResignedClasses = [ChatRoomVC.self, SelectCountryVC.self]
        FirebaseApp.configure()
        
        UINavigationBar.appearance().tintColor = UIColor.white
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
//        Auth.auth().createUser(withEmail: "soul6701@gmail.com", password: "123456789") { (user, error) in
//            guard let user = user, error == nil else {
//                NSLog("\n🔥🔥🔥🔥🔥🔥🔥🔥🔥創建帳戶失敗!" + error!.localizedDescription + "🔥🔥🔥🔥🔥🔥🔥🔥🔥\n")
//                return
//            }
//            let ref: DatabaseReference = Database.database().ref
//            let full_name = ["First-name": "lin" , "Last-name": "mason"]
//            ref.child("users").child(user.user.uid).setValue(["username": full_name])
//            NSLog("😆😆😆😆😆😆😆😆😆創建帳戶成功!😆😆😆😆😆😆😆😆😆")
//        }
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    //由外部進入APP
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        //
        return true
    }
}

