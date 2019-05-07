import ReactiveCocoa
import ReactiveSwift

struct SearchViewModel {
    
    let searchText: MutableProperty<String> = MutableProperty("")
    let result: Property<[String]>
    
    init() {
        
        let scheduler = QueueScheduler(name: "search.backgroundQueue")
        let dataSourceGenerator = SearchViewModel.generateDataSource().start(on: scheduler)

        let producer = SignalProducer.combineLatest(searchText.producer, dataSourceGenerator)
            .throttle(0.3, on: scheduler)
            .map(SearchViewModel.wordsSubSet)
        
        result = Property(initial: [], then: producer)
    }

    static private func wordsSubSet(searchTerm: String, words: [String]) -> [String] {
        
        guard searchTerm != "" else { return words }
        
        return words.filter {
            $0.range(of: searchTerm, options: .caseInsensitive, range: nil, locale: nil) != nil
        }
    }
    
    static private func generateDataSource() -> SignalProducer<[String], NoError> {
        
        return SignalProducer {o, d in
            
            let path: String = Bundle.main.path(forResource: "words", ofType: "txt")!
            let string: String = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)

            o.send(value: string.split(separator: "\n").map(String.init))
            o.sendCompleted()
        }
    }
}
