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
    var followIssueVC: FollowIssueVC {
        return self.storyboard.instantiateViewController(withIdentifier: "FollowIssueVC") as! FollowIssueVC
    }
    var followCardVC: FollowCardVC {
        return self.storyboard.instantiateViewController(withIdentifier: "FollowCardVC") as! FollowCardVC
    }
    var articalVC: ArticalVC {
        return self.storyboard.instantiateViewController(withIdentifier: "ArticalVC") as! ArticalVC
    }
    var mailVC: MailVC {
        return self.storyboard.instantiateViewController(withIdentifier: "MailVC") as! MailVC
    }
}
struct CardPage {
    let storyboard = UIStoryboard(name: "Card", bundle: nil)
    var cardInfoVC: CardInfoVC {
        return self.storyboard.instantiateViewController(withIdentifier: "CardInfoVC") as! CardInfoVC
    }
}
extension UIStoryboard {
    static let profile = ProfilePage()
    static let card = CardPage()
}
