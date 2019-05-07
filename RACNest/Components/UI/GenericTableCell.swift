import UIKit

extension GenericTableCell: Reusable {}

final class GenericTableCell: UITableViewCell {
    
    private let cellDescriptionLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(cellDescriptionLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(presentable: TextPresentable) {
        
        cellDescriptionLabel.attributedText = presentable.text
        accessoryType = .disclosureIndicator
    }
    
    override func layoutSubviews() {
        let verticalPadding = 5
        let leftPadding = 16
        
        cellDescriptionLabel.frame = CGRect(x: leftPadding, y: verticalPadding, width: Int(contentView.frame.width) - leftPadding, height: Int(contentView.frame.height) - (verticalPadding * 2))
    }
}
