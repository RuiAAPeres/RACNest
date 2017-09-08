import UIKit
import ReactiveSwift
import ReactiveCocoa

class PincodeViewController: UIViewController {

    @IBOutlet weak var pincodeField: UITextField!
    @IBOutlet weak var enterButton: UIButton!
    @IBOutlet weak var helpLabel: UILabel!

    private var viewModel: PincodeViewModel = PincodeViewModel(currentPincode: "0000")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.input <~ pincodeField.reactive.continuousTextValues.filterMap { $0 }
        pincodeField.reactive.text <~ viewModel.input
        enterButton.reactive.pressed = CocoaAction(viewModel.enterCodeAction)
        
        helpLabel.reactive.text <~ viewModel.state.producer.map {
            switch $0 {
            case .initial:
                return "Enter your current pincode (Hint: its 0000)"
            case .oldPincodeCorrect(let message):
                return message ?? "Enter your new pincode"
            case .confirmationPending(_):
                return "Confirm your new pincode"
            case .newPincodeConfirmed(_):
                return "Done!"
            case .error(let reason):
                return reason
            }
        }
        
        helpLabel.reactive.textColor <~ viewModel.state.producer.map {
            switch $0 {
            case .error(_):
                return .red
            default:
                return .darkGray
            }
        }
        
        enterButton.reactive.title <~ viewModel.state.producer.map {
            switch $0 {
            case .initial, .oldPincodeCorrect:
                return "Enter"
            case .confirmationPending(_):
                return "Confirm"
            case .newPincodeConfirmed(_):
                return "Done"
            case .error(_):
                return "Done"
            }
        }
        
        viewModel.state.signal.take { (state) -> Bool in
            switch state {
            case .newPincodeConfirmed(_), .error(_):
                return false
            default:
                return true
            }
        }.observeCompleted {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.navigationController?.popViewController(animated: true)
            }
        }
        
        pincodeField.becomeFirstResponder()
    }
}
