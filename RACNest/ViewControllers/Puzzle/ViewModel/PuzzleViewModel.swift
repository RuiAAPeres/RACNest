//
//  PuzzleViewModel.swift
//  RACNest
//
//  Created by Rui Peres on 31/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit
import ReactiveCocoa

protocol PuzzleBoardDataSource: class {
    
    var piecesViewModels: SignalProducer<([PuzzlePieceViewModel], PuzzlePiecePosition), NoError> { get }
}

extension PuzzleViewModel: PuzzleBoardDataSource { }

final class PuzzleViewModel {
    
    let piecesViewModels: SignalProducer<([PuzzlePieceViewModel], PuzzlePiecePosition), NoError>

    init(image: UIImage, dimension: PuzzleBoardDimension) {
        
        let scheduler = QueueScheduler(name: "puzzle.backgroundQueue")
        let producer = sliceImage(image, dimension: dimension).startOn(scheduler)
        
        let randomPiecePosition = randomPosition(dimension)
        let filter = filterPuzzlePiecePosition(randomPiecePosition)
        
        piecesViewModels = producer.filter(filter).map(PuzzlePieceViewModel.init).collect().map { ($0, randomPiecePosition) }
    }
}

private func randomPosition(dimension: PuzzleBoardDimension) -> PuzzlePiecePosition {
    
    let row = Int(arc4random_uniform(UInt32(dimension.numberOfRows)))
    let column = Int(arc4random_uniform(UInt32(dimension.numberOfColumns)))

    return PuzzlePiecePosition(row: row, column: column)
}

private func filterPuzzlePiecePosition(skippedPosition: PuzzlePiecePosition) -> (PuzzlePiecePosition, UIImage) -> Bool {
    
    return { (position, image) in
        return skippedPosition != position
    }
}

private func sliceImage(image: UIImage, dimension: PuzzleBoardDimension) -> SignalProducer<(PuzzlePiecePosition, UIImage), NoError> {
    
    return SignalProducer {o, d in
        
        let width = Int(image.size.width) / dimension.numberOfColumns
        let height = Int(image.size.height) / dimension.numberOfRows
        let imageSize = CGSize(width: width, height: height)
        
        for i in 0..<dimension.numberOfRows {
            for j in 0..<dimension.numberOfColumns {
                
                let x = i * width
                let y = j * height
                let frame = CGRect(origin: CGPoint(x: x, y: y), size: imageSize)
                let position = PuzzlePiecePosition(row: i, column: j)
                
                guard let newImage = CGImageCreateWithImageInRect(image.CGImage, frame) else { continue }
                
                o.sendNext((position, UIImage(CGImage: newImage)))
            }
        }
        o.sendCompleted()
    }
}
