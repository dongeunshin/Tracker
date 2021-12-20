
import UIKit
import JJFloatingActionButton

class ManagedObjectViewController: UIViewController {
    
    var list = [ItemEntity]()
    let categories: [String] = ["All", "Food", "Medicine", "Cosmetics", "Other"]
    let reuseIdentifier = "cellId"
    var token: NSObjectProtocol!
    @IBOutlet weak var listTableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    var interval = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        categoryCollectionView.allowsSelection = true
        categoryCollectionView.allowsMultipleSelection = false

        let actionButton = JJFloatingActionButton()
        actionButton.buttonColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        actionButton.addItem(title: "Add Item", image: UIImage(named: "First")?.withRenderingMode(.alwaysTemplate)) { item in
            let ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ComposeNav")
            ViewController?.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            self.present(ViewController!, animated: true, completion: nil)
        }

//        actionButton.addItem(title: "Setting", image: UIImage(named: "Second")?.withRenderingMode(.alwaysTemplate)) { item in
//                  // do something
//        }

        actionButton.display(inViewController: self)
        
        token = NotificationCenter.default.addObserver(forName: TextFIeldViewController.newItemDidInsert, object: nil, queue: .main, using: { [weak self] (noti) in
            let indexPathForFirstRow1 = IndexPath(row: 1, section: 0)
            self?.collectionView((self?.categoryCollectionView)!, didDeselectItemAt: indexPathForFirstRow1)
            let indexPathForFirstRow2 = IndexPath(row: 2, section: 0)
            self?.collectionView((self?.categoryCollectionView)!, didDeselectItemAt: indexPathForFirstRow2)
            let indexPathForFirstRow3 = IndexPath(row: 3, section: 0)
            self?.collectionView((self?.categoryCollectionView)!, didDeselectItemAt: indexPathForFirstRow3)
            let indexPathForFirstRow4 = IndexPath(row: 4, section: 0)
            self?.collectionView((self?.categoryCollectionView)!, didDeselectItemAt: indexPathForFirstRow4)
            let indexPathForFirstRow = IndexPath(row: 0, section: 0)
            self?.collectionView((self?.categoryCollectionView)!, didSelectItemAt: indexPathForFirstRow)
            self?.list = DataManager.shared.fatchItem()
            self?.listTableView.reloadData()
        })
    }
    deinit {
        NotificationCenter.default.removeObserver(token)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let indexPathForFirstRow = IndexPath(row: 0, section: 0)
        collectionView(categoryCollectionView, didSelectItemAt: indexPathForFirstRow)
    }
}

    extension ManagedObjectViewController: UITableViewDataSource {
        
       func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
       }
       
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "customCell", for: indexPath) as! ItemTableViewCell
        let item = list[indexPath.row]
        cell.nameLabel.text = item.name
        cell.quantityLabel.text = "Quantity: \(item.quantity)"

        let foodDate: Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM.dd.yyyy"
        foodDate = item.eDay!
        let dateRangeStart = Date()
        let components = Calendar.current.dateComponents([.day], from: dateRangeStart, to: foodDate)
        cell.dDayLabel.text = "\(components.day ?? 0) day(s) left"
        cell.dDayLabel.font = .italicSystemFont(ofSize: 18)
        let day = components.day ?? 0
        if (-1 < day) && (day <= 3)  {
            cell.dDayLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        }else if(day < 0){
            cell.dDayLabel.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
            cell.dDayLabel.text = "\(components.day ?? 0) day(s) past"
        }else{
            cell.dDayLabel.textColor = UIColor.black
        }
        return cell
    }
       
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let item = list.remove(at: indexPath.row)
            DataManager.shared.delete(entity: item)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        default:
            break
        }
    }
}


extension ManagedObjectViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = list[indexPath.row]
        if let nav = storyboard?.instantiateViewController(withIdentifier: "ComposeNav") as? UINavigationController, let composeVC = nav.viewControllers.first as? TextFIeldViewController{
            composeVC.target = item
            present(nav, animated: true, completion: nil)
        }
    }
}
extension ManagedObjectViewController:UICollectionViewDataSource, UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "categoryCell", for: indexPath as IndexPath) as! MyCollectionViewCell
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 15
        cell.layer.borderWidth = 1.0
        cell.categoryLabel.text = categories[indexPath.item]
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath) as! MyCollectionViewCell
        cell.contentView.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        categoryCollectionView.selectItem(at: indexPath as IndexPath, animated: true, scrollPosition: .centeredHorizontally)
        print("#1", indexPath, #function)
        switch cell.categoryLabel.text {
        case "All":
            listTableView.tableFooterView = UIView(frame: CGRect.zero)
            list = DataManager.shared.fatchItem()
            listTableView.reloadData()
        case "Food":
            let predicate = NSPredicate(format: "category == %d", 0)
            listTableView.tableFooterView = UIView(frame: CGRect.zero)
            list = DataManager.shared.fatchItem(predicate: predicate)
            listTableView.reloadData()
        case "Medicine":
            let predicate = NSPredicate(format: "category == %d", 2)
            listTableView.tableFooterView = UIView(frame: CGRect.zero)
            list = DataManager.shared.fatchItem(predicate: predicate)
            listTableView.reloadData()
        case "Cosmetics":
            let predicate = NSPredicate(format: "category == %d", 1)
            listTableView.tableFooterView = UIView(frame: CGRect.zero)
            list = DataManager.shared.fatchItem(predicate: predicate)
            listTableView.reloadData()
        case "Other":
            let predicate = NSPredicate(format: "category == %d", 3)
            listTableView.tableFooterView = UIView(frame: CGRect.zero)
            list = DataManager.shared.fatchItem(predicate: predicate)
            listTableView.reloadData()
        default:
            fatalError()
        }
    }
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)
        cell?.contentView.backgroundColor = .none
    }
    func  collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        guard let list = collectionView.indexPathsForSelectedItems else {
            return true
        }
        return !list.contains(indexPath)
    }
    func collectionView(_ collectionView: UICollectionView, shouldDeselectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}
extension ManagedObjectViewController: UIPickerViewDataSource {
   func numberOfComponents(in pickerView: UIPickerView) -> Int {
      return 1
   }
   
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
      return 60
   }
}

extension ManagedObjectViewController: UIPickerViewDelegate {
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
      return "\(row + 1) days"
   }
   
   func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
      interval = row + 1
   }
}

