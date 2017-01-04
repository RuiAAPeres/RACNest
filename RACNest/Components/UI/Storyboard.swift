//
//  Storyboard.swift
//  RACNest
//
//  Created by Rui Peres on 16/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit

protocol StoryboardViewControllerType : RawRepresentable { }

extension UIStoryboard {
    
    static func defaultStoryboard() -> UIStoryboard {
        return UIStoryboard(name: "Main", bundle: nil)
    }
    
    func instantiateViewController<S : StoryboardViewControllerType>(withIdentifier identifier: S) -> UIViewController where S.RawValue == String {
        return instantiateViewController(withIdentifier: identifier.rawValue)
    }
}
