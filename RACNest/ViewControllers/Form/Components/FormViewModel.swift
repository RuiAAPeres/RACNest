import ReactiveCocoa
import ReactiveSwift
import Result

struct FormViewModel {

    let authenticateAction: Action<Void, Void, NoError>

    let username: MutableProperty<String>
    let password: MutableProperty<String>
    
    init(credentialsValidationRule: @escaping (String, String) -> Bool = validateCredentials) {
        
        let username = UserDefaults.value(forKey: .Username)
        let password = UserDefaults.value(forKey: .Password)
        
        let usernameProperty = MutableProperty(username)
        let passwordProperty = MutableProperty(password)

        let isFormValid = MutableProperty(credentialsValidationRule(username, password))
        isFormValid <~ SignalProducer.combineLatest(usernameProperty.producer, passwordProperty.producer).map(credentialsValidationRule)

        let authenticateAction = Action<Void, Void, NoError>(enabledIf: isFormValid) { _ in
            return SignalProducer { o, d in

                let username = usernameProperty.value 
                let password = passwordProperty.value 

                UserDefaults.setValue(value: username, forKey: .Username)
                UserDefaults.setValue(value: password, forKey: .Password)

                o.sendCompleted()
            }
        }

        self.username = usernameProperty
        self.password = passwordProperty
        self.authenticateAction = authenticateAction
    }

}

private func validateCredentials(username: String, password: String) -> Bool {
    
    let usernameRule = username.characters.count > 5
    let passwordRule = password.characters.count > 10
    
    return usernameRule && passwordRule
}
