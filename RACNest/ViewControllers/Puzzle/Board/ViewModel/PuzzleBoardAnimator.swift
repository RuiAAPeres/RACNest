import Result
import ReactiveSwift

private func newPPP(_ row: Int, _ column: Int) -> PuzzlePiecePosition {
    return PuzzlePiecePosition(row, column)
}

struct PuzzleBoardAnimator {

    private let dimension: PuzzleBoardDimension

    init(dimension: PuzzleBoardDimension) {
        self.dimension = dimension
    }

    func movePieceRandomly(pieces: [PuzzlePieceViewModel], skippedPosition: PuzzlePiecePosition) -> SignalProducer<([PuzzlePieceViewModel], PuzzlePiecePosition), NoError> {

        return createPieceMovementProducer(pieces: pieces, skippedPosition: skippedPosition)
            .chain(times: 50, transformation: createPieceMovementProducer)
    }

    private func createPieceMovementProducer(pieces: [PuzzlePieceViewModel], skippedPosition: PuzzlePiecePosition) -> SignalProducer<([PuzzlePieceViewModel], PuzzlePiecePosition), NoError> {

        let positionToBeMovedTo = self.randomPosition(positions: self.candidates(skippedPosition: skippedPosition))

        let associatedViewModel = pieces.filter { $0.currentPiecePosition.value == positionToBeMovedTo}.first!
        let newSkippedPosition = associatedViewModel.currentPiecePosition.value

        associatedViewModel.currentPiecePosition.value = skippedPosition

        return SignalProducer(value: (pieces, newSkippedPosition)) .delay(0.3, on: QueueScheduler.main)
    }

    private func randomPosition(positions: [PuzzlePiecePosition]) -> PuzzlePiecePosition {

        let index = Int(arc4random_uniform(UInt32(positions.count)))
        return positions[index]
    }

    private func candidates(skippedPosition: PuzzlePiecePosition) -> [PuzzlePiecePosition] {

        let maxBoardRow = dimension.numberOfRows - 1
        let maxBoardColumn = dimension.numberOfColumns - 1

        switch (skippedPosition.row, skippedPosition.column) {

        // top left corner
        case (0, 0):
            return [newPPP(0,1), newPPP(1,0)]
        // top right corner
        case (maxBoardRow, 0):
            return [newPPP(maxBoardRow - 1, 0), newPPP(maxBoardRow, 1)]
        // bottom left corner
        case (0, maxBoardColumn) :
            return [newPPP(0, maxBoardColumn - 1), newPPP(1, maxBoardColumn)]
        // botom right corner
        case (maxBoardRow, maxBoardColumn) :
            return [newPPP(maxBoardRow - 1, maxBoardColumn), newPPP(maxBoardRow, maxBoardColumn - 1)]
        // Top Edge && Bottom Edge
        case (let aRow, let aColumn) where aRow == 0 || aRow == maxBoardRow:
            let rowOffset = aRow == 0 ? 1 : -1
            return [newPPP(aRow, aColumn - 1), newPPP(aRow, aColumn + 1), newPPP(aRow + rowOffset, aColumn)]
        // Left and Right Edge
        case (let aRow, let aColumn) where aColumn == 0 || aColumn == maxBoardColumn:
            let columnOffset = aColumn == 0 ? 1 : -1
            return [newPPP(aRow - 1, aColumn), newPPP(aRow + 1, aColumn), newPPP(aRow, aColumn + columnOffset)]
        // All other cases
        case (let aRow, let aColumn):
            return [newPPP(aRow - 1, aColumn), newPPP(aRow + 1, aColumn), newPPP(aRow, aColumn + 1), newPPP(aRow, aColumn - 1)]
        }
    }
}
