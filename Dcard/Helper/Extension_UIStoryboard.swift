//
//  Extension_UIStoryboard.swift
//  Dcard
//
//  Created by Mason_Lin on 2020/9/9.
//  Copyright © 2020 Mason_Lin. All rights reserved.
//

import Foundation
import UIKit

struct ProfilePage {
    let storyboard = UIStoryboard(name: "Profile", bundle: nil)
    var favoriteVC: FavoriteVC {
        return self.storyboard.instantiateViewController(withIdentifier: "FavoriteVC") as! FavoriteVC
    }
}
extension UIStoryboard {
    static let profile = ProfilePage()
}
