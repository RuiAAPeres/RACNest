import UIKit
import ReactiveSwift
import Result

final class PuzzleBoardDataSource {
    
    let piecesViewModels: SignalProducer<([PuzzlePieceViewModel], PuzzlePiecePosition), NoError>

    init(image: UIImage, dimension: PuzzleBoardDimension) {
        
        let scheduler = QueueScheduler(name: "puzzle.backgroundQueue")
        let producer = sliceImage(image: image, dimension: dimension).start(on: scheduler)
        
        let randomPiecePosition = randomPosition(dimension: dimension)
        let filter = filterPuzzlePiecePosition(skippedPosition: randomPiecePosition)
        
        piecesViewModels = producer.filter(filter).map(PuzzlePieceViewModel.init).collect().map { ($0, randomPiecePosition) }
    }
}

private func randomPosition(dimension: PuzzleBoardDimension) -> PuzzlePiecePosition {
    
    let row = Int(arc4random_uniform(UInt32(dimension.numberOfRows)))
    let column = Int(arc4random_uniform(UInt32(dimension.numberOfColumns)))

    return PuzzlePiecePosition(row, column)
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
        
        for row in 0..<dimension.numberOfRows {
            for column in 0..<dimension.numberOfColumns {
                
                let x = column * width
                let y = row * height
                let frame = CGRect(origin: CGPoint(x: x, y: y), size: imageSize)
                let position = PuzzlePiecePosition(row, column)
                
                guard let newImage = image.cgImage?.cropping(to: frame) else { continue }


                o.send(value: (position, UIImage(cgImage: newImage)))
            }
        }
        o.sendCompleted()
    }
}
