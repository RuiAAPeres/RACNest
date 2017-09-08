import UIKit

final class MainViewModel: NSObject {
    
    let items: [MainCellItem]
    
    override init() {
        
        let item1 = MainCellItem(title: "1. Form 🐥", identifier: .Form)
        let item2 = MainCellItem(title: "2. Search 🔍", identifier: .Search)
        let item3 = MainCellItem(title: "3. Pincode 🔐", identifier: .Pincode)

        items = [item1, item2, item3]

        super.init()
    }
}

extension MainViewModel: UITableViewDataSource {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: GenericTableCell = tableView.dequeueReusableCell(indexPath: indexPath)

        cell.configure(presentable: items[indexPath.row])

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
}
