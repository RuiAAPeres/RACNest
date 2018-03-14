import UIKit
import ReactiveSwift

struct PuzzlePiecePosition {
    let row: Int
    let column: Int
    
    init(_ row: Int, _ column: Int) {
        self.row = row
        self.column = column
    }
}

extension PuzzlePiecePosition: Hashable {
    var hashValue: Int {
        return "\(row),\(column)".hash
    }

    static func ==(lhs: PuzzlePiecePosition, rhs: PuzzlePiecePosition) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

typealias MovePiece = (PuzzlePiece, PuzzlePiecePosition) -> Void

final class PuzzlePiece: UIView {
    
    private let puzzleImageView: UIImageView = UIImageView()
    private let viewModel: PuzzlePieceViewModel
    private let moveAnimation: MovePiece
    
    init(size: CGSize, moveAnimation: @escaping MovePiece, viewModel: PuzzlePieceViewModel) {
        
        self.viewModel = viewModel
        self.moveAnimation = moveAnimation
        
        super.init(frame: CGRect(origin: .zero, size: size))
        
        addSubview(puzzleImageView)
        self.puzzleImageView.image = viewModel.image
        
        viewModel.currentPiecePosition.producer.startWithValues { piecePosition in
            moveAnimation(self, piecePosition)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func layoutSubviews() {
        puzzleImageView.frame = bounds
    }
}
