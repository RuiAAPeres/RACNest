//
//  FormViewModel.swift
//  RACNest
//
//  Created by Rui Peres on 16/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import Foundation
import ReactiveSwift
import ReactiveCocoa
import Result

struct FormViewModel {

    let authenticateAction: Action<Void, Void, NoError>

    let username: MutableProperty<String>
    let password: MutableProperty<String>
    
    init(credentialsValidationRule: @escaping (String, String) -> Bool = validateCredentials) {
        
        let username = Foundation.UserDefaults.value(forKey: .username)
        let password = Foundation.UserDefaults.value(forKey: .password)
        
        let usernameProperty = MutableProperty(username)
        let passwordProperty = MutableProperty(password)

        let isFormValid = MutableProperty(credentialsValidationRule(username, password))
        isFormValid <~ SignalProducer
            .combineLatest(usernameProperty.producer, passwordProperty.producer)
            .map(credentialsValidationRule)

        let authenticateAction = Action<Void, Void, NoError>(enabledIf: isFormValid, { _ in
            return SignalProducer { o, d in

                let username = usernameProperty.value
                let password = passwordProperty.value

                Foundation.UserDefaults.setValue(username, forKey: .username)
                Foundation.UserDefaults.setValue(password, forKey: .password)

                o.sendCompleted()
            }
        })

        self.username = usernameProperty
        self.password = passwordProperty
        self.authenticateAction = authenticateAction
    }

}

private func validateCredentials(_ username: String, password: String) -> Bool {
    
    let usernameRule = username.characters.count > 5
    let passwordRule = password.characters.count > 10
    
    return usernameRule && passwordRule
}
