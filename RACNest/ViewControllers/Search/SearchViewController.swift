//
//  SearchViewController.swift
//  RACNest
//
//  Created by Rui Peres on 20/01/2016.
//  Copyright © 2016 Rui Peres. All rights reserved.
//

import UIKit
import ReactiveSwift

final class SearchViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!

    fileprivate let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerReusableCell(GenericTableCell.self)
                
        viewModel.result.producer.observe(on: QueueScheduler.main).startWithValues { [weak self] text in
            self?.tableView.reloadData()
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.searchText.value = searchText
    }
}

extension SearchViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.result.value.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell: GenericTableCell = tableView.dequeueReusableCell(indexPath: indexPath)

        let searchResultItem = viewModel.result.value[indexPath.row]
        let searchCellItem = SearchCellItem(title: searchResultItem, textBeingSearched: viewModel.searchText.value)
        
        cell.configure(searchCellItem)
        
        return cell
    }
}
