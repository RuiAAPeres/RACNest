//
//  SearchViewModel.swift
//  RACNest
//
//  Created by Rui Peres on 20/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import Foundation
import Result
import ReactiveSwift
import ReactiveCocoa

struct SearchViewModel {
    
    let searchText: MutableProperty<String> = MutableProperty("")
    let result: Property<[String]>
    
    init() {
        
        let scheduler = QueueScheduler(name: "search.backgroundQueue")
        let dataSourceGenerator = SearchViewModel.generateDataSource().start(on: scheduler)
        
        let producer = SignalProducer
            .combineLatest(searchText.producer, dataSourceGenerator)
            .throttle(0.3, on: scheduler)
            .map(SearchViewModel.wordsSubSet)
        
        result = Property(initial: [], then: producer)
    }
    
    static private func wordsSubSet(_ searchTerm: String, words: [String]) -> [String] {
        
        guard  searchTerm != "" else { return words }
        
        return words.filter {
            $0.range(of: searchTerm, options: .caseInsensitive) != nil
        }
    }
    
    static private func generateDataSource() -> SignalProducer<[String], NoError> {
        
        return SignalProducer { o, d in
            
            let path: String = Bundle.main.path(forResource: "words", ofType: "txt")!
            let string: String = try! String(contentsOfFile: path, encoding: String.Encoding.utf8)
            o.send(value: string.characters.split(separator: "\n").map(String.init))
            o.sendCompleted()
        }
    }
}
