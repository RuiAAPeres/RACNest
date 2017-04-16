#### 3. Search 🔍

For a beginner in the FRP paradigm, throttling is a foreign concept. A quick way  to understand it in the real world is via a search. Let's imagine that you are searching something and everytime you tap the keyboard a new server is initiated. This can be quite expensive and complex to implement. So:

1. Character "A" is inputted. 
2. New server call starts.
3. Character "B" is inputted.
4. Cancel the current on going server call and initiate a new one

The problem with this approach is that it doesn't take into account the frequency at which a new letter is inputted. Not only that, it's a waste of resources.

Throttling solves this problem by creating an interval between each input. Imagine that the user is inputting a new letter every 0.1s. If we set throttling with an interval of 0.5s, only at the 5th letter the search will commence. This makes more sense than going back and forth with new requests and cancelling the previous one. 

----

In our example (that can be found [here](https://github.com/RuiAAPeres/RACNest/tree/master/RACNest/ViewControllers/Search)), we make use of the `throttle` operator to achieve what was described above. Let's start with the `SearchViewController`:

```swift
viewModel.result.producer.observeOn(QueueScheduler.mainQueueScheduler).startWithNext {[weak self] _ in
    self?.tableView.reloadData()
}
```

In this case we are just reloading the `UITableView` every time a new set of results comes. As a side note, [RxSwift provides](https://github.com/ReactiveX/RxSwift/blob/b00d35a5ef13dbcf57257f47fb14a60a2c924d19/RxCocoa/iOS/UITableView%2BRx.swift) a more integrate approach to this kind of problems. 

In the second bit, we are setting the new search term:

```swift
func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    viewModel.searchText.value = searchText
}
```

Let's now have a look at the `SearchViewModel`, more specifically, to how we are building the [data source](https://github.com/RuiAAPeres/RACNest/blob/master/RACNest/ViewControllers/Search/DataSource/words.txt):

```swift
static private func generateDataSource() -> SignalProducer<[String], NoError> {
  
    return SignalProducer {observable, disposable in
            
        let path: String = NSBundle.mainBundle().pathForResource("words", ofType: "txt")!       // 1
        let string: String = try! String(contentsOfFile: path, encoding: NSUTF8StringEncoding)  // 2
        let words = string.characters.split("\n").map(String.init)                              // 3
            
        observable.sendNext(words)                                                              // 4                   
        observable.sendCompleted()                                                              // 5
    }
}
```

The weird part is how a `SignalProducer` is created, the rest is pretty standard:

1. Get the path to the `words.txt` file that's located in our main bundle.
2. Create a string with the file's content.
3. Split them into an array of words.

So the `SignalProducer` has you have guessed, is a struct that takes a closure to be initialized. The closure itself is of type `(Signal<Value, Error>.Observer, CompositeDisposable) -> ())`. So what the hell does this means to you?

You can think of the first parameter, the `observable`, as the entity that will control the flow of the `SignalProducer`. As you can see on comment `4`, we are sending the words array down the stream and on line `5` complete it. If there was a case where we would handle an error, we would just:

```
observable.sendFailure(error)
```

The second parameter is an instance conforming to the `Disposable` protocol. [From the documentation](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/fd64bf6ea7a83dec13fe42244db470fd9641a9a1/Documentation/FrameworkOverview.md#disposables): 

> When starting a signal producer, a disposable will be returned. This disposable can be used by the caller to cancel the work that has been started (e.g. background processing, network requests, etc.), clean up all temporary resources, then send a final Interrupted event upon the particular signal that was created.

In our example, we don't really use it, since once the reading starts, we can't really interrupt it. A good use case would be [this](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/FoundationExtensions.swift#L33#L49). 

Let's now go for the fun part the `SearchViewModel` initializer:

```swift
init() {
        
    let scheduler = QueueScheduler(name: "search.backgroundQueue")                     // 1
    let dataSourceGenerator = SearchViewModel.generateDataSource().startOn(scheduler)  // 2
        
    let producer = combineLatest(searchText.producer, dataSourceGenerator)             // 3
        .throttle(0.3, onScheduler: scheduler)                                         // 4
        .map(SearchViewModel.wordsSubSet)                                              // 5
                                                                                           // 6
    result = AnyProperty(initialValue: [], producer: producer)                         // 7
}
```

Let's go line by line:

1. A new `QueueScheduler` is created. A scheduler is a serial execution queue, where the work will be processed. In our case this will serve as a background queue. 
2. We define that our data source creation, when it starts, should be done in the previously defined scheduler. **The generation hasn't started yet**.
3. We [combine](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/SignalProducer.swift#L513#L522) the `searchText.producer` with our data source. What this means is: we will move to step 4 and 5, once they both sent at least one value. This is useful because, we will wait until the data source has been calculated. The `searchText` by default will already have a value, since we have defined it as `MutableProperty("")` (being the `""` its first value). So if the user hasn't searched for anything yet, the function `SearchViewModel.wordsSubSet` will get as input `("", ["a", "lot", "of", "words"]) // (String, [String])`.
4. Finally the reason for this example: the ([`throttle`](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/SignalProducer.swift#L714#L721)). If you haven't skim any text, this should be fairly easy to understand: `throttle` will make sure a given amount of time passes (in our case 0.3s) before sending a new value. If multiple values were sent, it will go with last one. Bottom line: if the user is a quick typer, we will only process her input every 0.3s. ✨
5. Finally, we just pass the `SearchViewModel.wordsSubSet` to the `map` function, so we can find which words match the user's search. The `map` transformation will be in the form of `(String, [String]) -> [String]`.
6. **None of what I described so far has started!**
7. We initialize our `result`. The initial value is just an empty array (`[]`), since we don't have anything ready. The second bit, is all our efforts from step 1 to 5. Every time a new array comes (a filtered array based on the search), the `result.value` is updated. 

Ok, so where does this all starts? With the `AnyProperty`'s initilization. We then observe all these changes in the `SearchViewController` and call `reloadData()`.

----

**Note: The next part is just a downward spiral into madness. If I have missed something, or I am completely wrong, please let me know!**

We start by checking the `AnyProperty` initializer: 

```swift
public init(initialValue: Value, producer: SignalProducer<Value, NoError>) {
	let mutableProperty = MutableProperty(initialValue)
	mutableProperty <~ producer
	self.init(mutableProperty)
}
```

Let's have a look at that innocuous `<~`: 

```swift
public func <~ <P: MutablePropertyType>(property: P, producer: SignalProducer<P.Value, NoError>) -> Disposable {
	var disposable: Disposable!

	producer.startWithSignal { signal, signalDisposable in
		property <~ signal
		disposable = signalDisposable

		property.producer.startWithCompleted {
			signalDisposable.dispose()
		}
	}

	return disposable
}
```

And finally (I promise), the `startWithSignal`:

```swift
public func startWithSignal(@noescape setUp: (Signal<Value, Error>, Disposable) -> ()) {
	let (signal, observer) = Signal<Value, Error>.pipe()

	// Disposes of the work associated with the SignalProducer and any
	// upstream producers.
	let producerDisposable = CompositeDisposable()

	// Directly disposed of when start() or startWithSignal() is disposed.
	let cancelDisposable = ActionDisposable {
		observer.sendInterrupted()
		producerDisposable.dispose()
	}

	setUp(signal, cancelDisposable)

	if cancelDisposable.disposed {
		return
	}

	let wrapperObserver: Signal<Value, Error>.Observer = Observer { event in
		observer.action(event)

		if event.isTerminating {
			// Dispose only after notifying the Signal, so disposal
			// logic is consistently the last thing to run.
			producerDisposable.dispose()
		}
	}

	startHandler(wrapperObserver, producerDisposable)
}
```

A couple of things here:

1. Most of the work being done is related to cleanup and making sure everything is disposed correctly. 
2. We hook up our handler (the `setUp`, which is coming from the `<~` implementation).
	1. The property update via the `property <~ signal`, which pretty much just updates the `property.value` when a new value comes ([via Next](https://github.com/ReactiveCocoa/ReactiveCocoa/blob/master/ReactiveCocoa/Swift/Property.swift#L261)).
	2. The `AnyProperty` internally makes use of a `MutableProperty` to do the heavy lifting. 
3. We finally start the work associated with our initial search + data source generation in the `startHandler`. 


Since RAC is something I am using everyday I find these explorations very useful. Thanks to [Nacho Soto](https://github.com/NachoSoto) for the explanation! 
