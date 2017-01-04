//
//  GenericTableCell.swift
//  RACNest
//
//  Created by Rui Peres on 13/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit

extension GenericTableCell: Reusable {}

final class GenericTableCell: UITableViewCell {
    
    private let cellDescriptionLabel = UILabel(frame: CGRect.zero)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        contentView.addSubview(cellDescriptionLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(_ presentable: TextPresentable) {
        
        cellDescriptionLabel.attributedText = presentable.text
        accessoryType = .disclosureIndicator
    }
    
    override func layoutSubviews() {
        let verticalPadding = 5
        let leftPadding = 16
        
        cellDescriptionLabel.frame = CGRect(x: leftPadding, y: verticalPadding, width: Int(contentView.frame.width) - leftPadding, height: Int(contentView.frame.height) - (verticalPadding * 2))
    }
}
