import UIKit

struct SearchCellItem {
    let title: String
    let textBeingSearched: String
}

extension SearchCellItem: TextPresentable {
    var text: NSAttributedString {
        
        let attributedString = NSMutableAttributedString(string: title, attributes: [.foregroundColor: UIColor.gray])
        
        let range = (title as NSString).range(of: textBeingSearched)
        attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range)
        
        return attributedString
    }
}
