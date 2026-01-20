//
//  EATFont.swift
//  Wallpaper
//
//  Created by Copper on 2021/1/25.
//

import UIKit

let SCREEN_BOUNDS = UIScreen.main.bounds
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height
let SCREEN_SCALE = min(SCREEN_WIDTH / 393.0, SCREEN_HEIGHT / 852.0)

class EATFont: NSObject {

    /*
     Cinzel-Regular
     Cinzel-Medium
     Cinzel-SemiBold
     Cinzel-Bold
     Cinzel-ExtraBold
     Cinzel-Black

     VogueAvantGarde-Book
     VogueAvantGarde-Light
     VogueAvantGarde-Demi
     VogueAvantGarde-Bold
     VogueAvantGarde-Heavy
     */

    @objc static func eat_CinzelRegular(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-Regular", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }

    @objc static func eat_CinzelMedium(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }

    @objc static func eat_CinzelSemiBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    @objc static func eat_CinzelBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    @objc static func eat_CinzelExtraBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-ExtraBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
    
    @objc static func eat_CinzelBlack(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Cinzel-Black", size: size) ?? UIFont.systemFont(ofSize: size, weight: .black)
    }

    @objc static func eat_VogueAvantGardeBook(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VogueAvantGarde-Book", size: size) ?? UIFont.systemFont(ofSize: size, weight: .regular)
    }
    
    @objc static func eat_VogueAvantGardeLight(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VogueAvantGarde-Light", size: size) ?? UIFont.systemFont(ofSize: size, weight: .light)
    }

    @objc static func eat_VogueAvantGardeDemi(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VogueAvantGarde-Demi", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    @objc static func eat_VogueAvantGardeBold(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VogueAvantGarde-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }

    @objc static func eat_VogueAvantGardeHeavy(_ size: CGFloat) -> UIFont {
        return UIFont(name: "VogueAvantGarde-Heavy", size: size) ?? UIFont.systemFont(ofSize: size, weight: .heavy)
    }
}
