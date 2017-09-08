#### 4. Pincode 🔐

While for some forms like the one presented in [Example 1. Form 🐥](1_form.md) the validity of the input as well as the result as a whole rely only on the current input, there are also more complicated situations in which previous values are just as important as the current ones.

Take, for example, a form to change your pincode. First, you'll have to input your current pincode to authorize yourself, then you'll enter a new pincode that also needs to be confirmed by entering the same new pincode a second time. Whats more, you are not allowed to use the same pincode as you had before.

In this example, the most interesting bits are:

1. The use of `Action` to generate a stream of inputs.
2. The implementation of a state machine in `PincodeViewModel`.

Let's start with the `Action` first:

`PincodeViewModel` has a `MutableProperty` called `input` which will be bound to the input by the `PincodeViewController` (In this example, a simple `UITextField` is used for the input instead of fancy number buttons).
`enterCodeAction` is an `Action` that, invoked by tap on the button, will send the current value of `input` once.

```swift
enterCodeAction = Action(state: input, enabledIf: inputValid) { state, _ in
    SignalProducer(value: state)
}
```

Thus, `enterCodeAction.values` is a `Signal` on which for each tap on the buttn, the current input value is sent.


The second part is to turn the stream of input events into the the current state. To achieve this, the `scan` operator is used on the signal of input values. Maybe you are already familiar with the [`reduce`](https://developer.apple.com/documentation/swift/array/2298686-reduce) operator in the swift standard library which combines all values of a sequence, like an array, into a final accumluated value. In the context of ReactiveCocoa, `reduce` works the same way, just on signals. `scan` works almost the same as `reduce`, but while `reduce` produces only one final accumulated value, `scan` also produces each intermediary result.
This behavior of `scan` is important since we are not just interested in the final state of the form, but in each state after a new input.

```swift
let state = enterCodeAction.values.scan(State.initial) { (currentState, pincode) in
    let nextState: State
    switch currentState {
    case .initial:
        // Initially, the pin code entered has to match the current pincode
            nextState = (pincode == currentPincode) ?
            .oldPincodeCorrect(message: nil) :
            .error(reason: "Wrong pincode")
    ...
    ...
    default:
        // After the new pincode was confirmed or an error, nothing changes anymore
        nextState = currentState
    }
    return nextState
}
```

With each new value on the `enterCodeAction.values` signal, the code in `scan` is executed once with the `currentState` (started with the initial state) and the current `pincode` that was entered. Based on these two values, the next state has to be generated and returned. E.g. in the initial state, the input has to match the current pincode. If thats the case, the next step is to input a new input. Otherwise, the next state ist the error state (with an according message that can be shown to the user).
Cases for all the other possible states are implemented to handle all other transitions in the state machine.

What remains is to wire up the viewmodel to the interface in `PincodeViewController`.

---