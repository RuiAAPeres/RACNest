import UIKit
import ReactiveSwift

final class PuzzlePieceViewModel {
    
    let currentPiecePosition: MutableProperty<PuzzlePiecePosition>
    let originalPiecePosition: PuzzlePiecePosition
    let image: UIImage

    init(originalPiecePosition: PuzzlePiecePosition, image: UIImage) {
        self.originalPiecePosition = originalPiecePosition
        self.currentPiecePosition = MutableProperty(originalPiecePosition)
        self.image = image
    }
}
