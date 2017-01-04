//
//  UserDefaults.swift
//  RACNest
//
//  Created by Rui Peres on 17/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import Foundation

enum UserDefaults: String {
    
    case username = "username"
    case password = "password"
}

extension Foundation.UserDefaults {
    
    static func value(forKey key: UserDefaults) -> String {
        
        return standard.object(forKey: key.rawValue) as? String ?? ""
    }
    
    static func setValue(_ value: String, forKey key: UserDefaults) {
        
        standard.setValue(value, forKey: key.rawValue)
    }
}
