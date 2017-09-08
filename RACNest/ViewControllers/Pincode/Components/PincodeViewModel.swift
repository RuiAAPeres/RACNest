import ReactiveCocoa
import ReactiveSwift
import Result

struct PincodeViewModel {
    enum State {
        case initial
        case oldPincodeCorrect(message: String?)
        case confirmationPending(pincode: String)
        case newPincodeConfirmed(pincode: String)
        case error(reason: String)
    }
    
    let enterCodeAction: Action<Void, String, NoError>
    let input: MutableProperty<String> = MutableProperty("")
    let state: Property<State>
    
    init(currentPincode: String) {
        let inputValid: (String) -> Bool = {
            !$0.isEmpty && Int($0) != nil
        }
        enterCodeAction = Action(state: input, enabledIf: inputValid) { state, _ in
            SignalProducer(value: state)
        }
        
        // Reset the input after each action
        input <~ enterCodeAction.values.map { _ in return "" }

        let state = enterCodeAction.values.scan(State.initial) { (currentState, pincode) in
            let nextState: State
            switch currentState {
            case .initial:
                // Initially, the pin code entered has to match the current pincode
                 nextState = (pincode == currentPincode) ?
                    .oldPincodeCorrect(message: nil) :
                    .error(reason: "Wrong pincode")
            case .oldPincodeCorrect:
                // If the old pincode was entered correct, the next input will be the new pincode
                nextState = (pincode == currentPincode) ?
                    .oldPincodeCorrect(message: "You cant use your current pincode again, please enter a new pincode") :
                    .confirmationPending(pincode: pincode)
            case .confirmationPending(let newPincode):
                // The confirmation has to match the new pincode
                nextState = (newPincode == pincode) ?
                    .newPincodeConfirmed(pincode: newPincode) :
                    .error(reason: "Confirmation does not match")
            default:
                // After the new pincode was confirmed or an error, nothing changes anymore
                nextState = currentState
            }
            return nextState
        }
        self.state = Property(initial: .initial, then: state)
    }
}
