//
//  SearchCellItem.swift
//  RACNest
//
//  Created by Rui Peres on 21/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit

struct SearchCellItem {
    let title: String
    let textBeingSearched: String
}

extension SearchCellItem: TextPresentable {
    var text: NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: title, attributes: [NSForegroundColorAttributeName: UIColor.gray])
        
        let range = (title as NSString).range(of: textBeingSearched)
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.blue, range: range)
        
        return attributedString
    }
}
