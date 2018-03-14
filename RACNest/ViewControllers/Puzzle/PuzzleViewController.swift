import UIKit

private let dimension = PuzzleBoardDimension(numberOfRows: 3, numberOfColumns: 3)

final class PuzzleViewController: UIViewController {

    private let board = PuzzleBoard(boardDimension:dimension, image: UIImage(named: "japan_forest")!)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(board)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        board.center = view.center
    }
}
