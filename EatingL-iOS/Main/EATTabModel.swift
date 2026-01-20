//
//  EATTabModel.swift
//  PulseE-iOS
//
//  Created by star on 2022/1/18.
//

import UIKit

enum EATMainTab: Int, Codable, CaseIterable {
    case editor = 0
    case styles = 1
    case me = 2
}

extension EATMainTab {

    var title: String {
        switch self {
        case .editor: return "EATEditor".eat_Localized()
        case .styles: return "EATStyles".eat_Localized()
        case .me: return "EATMe".eat_Localized()
        }
    }

    var icon: String {
        switch self {
        case .editor: return "tab_editor"
        case .styles: return "tab_styles"
        case .me: return "tab_me"
        }
    }

    var iconSelected: String {
        switch self {
        case .editor: return "tab_editor_s"
        case .styles: return "tab_styles_s"
        case .me: return "tab_me_s"
        }
    }
    
    var iconBadge: String {
        switch self {
        case .me: return "tab_me_point"
        default: return icon
        }
    }

    var titleColor: UIColor {
        return UIColor("#FFFFFF")
    }

    var titleSelectedColor: UIColor {
        return UIColor("#E0AA7C")
    }

    var titleFont: UIFont {
        return EATFont.eat_VogueAvantGardeDemi(10)
    }

    var titleSelectedFont: UIFont {
        return EATFont.eat_VogueAvantGardeDemi(10)
    }
}
