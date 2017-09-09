#### 1. Form 🐥

Handling forms, is the most common example showed to FRP beginners. In just a few lines of code, you are exposed to composition, transformations and observers. 

In this case, the most interesting bits are:

1. The setup between the `FormViewController` and the `FormViewModel`.
2. The `FormViewModel` inner logic. 

Let's start with the setup at `FormViewController`'s `viewDidLoad`:

```swift
usernameField.text = viewModel.username.value
passwordField.text = viewModel.password.value

viewModel.username <~ usernameField.reactive.continuousTextValues.filterMap { $0 }
viewModel.password <~ passwordField.reactive.continuousTextValues.filterMap { $0 }

loginButton.reactive.pressed = CocoaAction(viewModel.authenticateAction)
```
In the first two lines, we set the initial values for the `UITextField`. Since the `viewModel.username` and `viewMode.password` are both [`MutableProperties`](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/f77534c77434f2112ce663f998c71ab1098335b2/ReactiveCocoa/Swift/Property.swift#L88#L172), we get their current value, by accessing the `value` property.

Next, we bind the on going `UITextField`'s `text` property change, to the viewModel's properties. This is done via two things:

1. The `reactive.continuousTextValues`, who exposes a `Signal<String?, NoError>`, which is not more than a stream of values (in this case the text being changed while it's being typed). By using `filterMap`, we skip potential nil values and thus turn this a `Signal<String, NoError`.
2. The `<~` operator, which binds the `Signal`'s last streamed value to the `MutableProperty`'s inner value. You can check the implementation [here](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/f77534c77434f2112ce663f998c71ab1098335b2/ReactiveCocoa/Swift/Property.swift#L279#L292), being the important bit [this](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/f77534c77434f2112ce663f998c71ab1098335b2/ReactiveCocoa/Swift/Property.swift#L260#L261).

The last piece:

```swift
loginButton.reactive.pressed = CocoaAction(viewModel.authenticateAction)
```

Binds the `viewModel.authenticate` action to the `loginButton`'s pressed. This entails two things:

1. The obvious one: When the button is tapped, the `authenticate` action is executed.
2. The less obvious one: `UIButton`'s `enabled` property is tied to the lifecycle of the authentication action. What this means is simple: until the action completes or fails, the button will be disabled. Once the action is done, the button is enabled again.

The second part is inside the `FormViewModel`:

```swift
let username = NSUserDefaults.value(forKey: .Username)
let password = NSUserDefaults.value(forKey: .Password)

self.username = MutableProperty(username)
self.password = MutableProperty(password)

let isFormValid = MutableProperty(credentialsValidationRule(username, password))
isFormValid <~ combineLatest(self.username.producer, self.password.producer).map(credentialsValidationRule)

let authenticateAction = Action<Void, Void, NoError>(enabledIf: isFormValid) { ... }
```

In the first two lines, we just fetch the values we already have saved in the UserDefaults (in a real project, you should save sensitive data in the Keychain). Finally in the 3rd and 4th lines, we create two `MutableProperty` with their initial values (the username and password respectively).

The 5th and 6th we do two things:

1. A `MutableProperty` is created, telling us if the form is currently valid. This validation (`credentialsValidationRule`) is nothing more than a function `(String, String) -> Bool`. 
2. This is where we start having a glimpse of how powerful FRP is. The `combineLatest` will take two producers and return another. The later will emit values, when both of its inner producers have sent at least one value. What this basically means is: until you typed something in both the `UsernameTextField` and the `PasswordTextFiel`, nothing will happen. After that we just validate the username and password. Let's have a look at a type level, so it makes a bit more sense:

```swift
self.username = MutableProperty(username)                                                  // MutableProperty<String, NoError>
self.password = MutableProperty(password)                                                  // MutableProperty<String, NoError>

let usernameProducer = self.username.producer                                              // SignalProducer<String, NoError>
let passwordProducer = self.password.producer                                              // SignalProducer<String, NoError>

let combinedValuesProduce = combineLatest(self.username.producer, self.password.producer)  // SignalProducer<(String, String), NoError>
let valideCredentialsProducer = combinedValues.map(credentialsValidationRule)              // SignalProducer<Bool, NoError>
``` 

The final bit `validCredentials <~ ...` just binds the producer's stream of values to the `validCredentials` inner value. This `MutableProperty`, is one of the pieces that dictates if the `loginButton` (from the `FormViewController`) is enabled or not.

Finally the `authenticationAction` function, which seems a bit complicate, but really isn't:

```swift
let authenticateAction = Action<Void, Void, NoError>(enabledIf: isFormValid) { _ in
    return SignalProducer { o, d in

        let username = usernameProperty.value 
        let password = passwordProperty.value 

        UserDefaults.setValue(value: username, forKey: .Username)
        UserDefaults.setValue(value: password, forKey: .Password)

        o.sendCompleted()
    }
}
```

So what's happening here?

1. Create an action that will be enabled depending on the state of the form (via the `isFormValid`). 
2. Do the necessary work, in this case update the `NSUserDefaults`, when the action is executed. As you might have guessed, this will happen when the `UIButton` is tapped.

The `SignalProducer` creation will be something I will address another time, for now it's important to understand the concepts from a higher level, once this becomes natural, or obvious, we will address the details. There is also the question about what the hell is this ` Action<Void, Void, NoError>`, which I will also address another time. For now you can think of that as a task that:

1. Takes no input to be executed (`Void`)
2. Has no output, after being executed (`Void`)
3. Doesn't emit any error (`NoError`)

----
