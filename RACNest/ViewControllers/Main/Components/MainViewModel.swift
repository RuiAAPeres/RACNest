//
//  MainViewModel.swift
//  RACNest
//
//  Created by Rui Peres on 13/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit

final class MainViewModel: NSObject {
    
    let items: [MainCellItem]
    
    override init() {
        
        let item1 = MainCellItem(title: "1. Form 🐥", identifier: .form)
        let item2 = MainCellItem(title: "2. Search 🔍", identifier: .search)

        items = [item1, item2]

        super.init()
    }
}

extension MainViewModel: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell: GenericTableCell = tableView.dequeueReusableCell(indexPath: indexPath)

        cell.configure(items[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}


