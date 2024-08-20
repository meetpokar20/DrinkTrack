//
//  MainViewController.swift
//  DrinkTrack
//
//  Created by Rebootcs on 19/08/24.
//

import Foundation
import UIKit
import CoreData

class MainViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addWaterButton: UIButton!
    
    var waterLogs: [WaterLog] = []
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWaterLogs()
    }
    
    @IBAction func addWaterTapped(_ sender: UIButton){
        let alert = UIAlertController(title: "Add Water Intake", message: " Enter amount in milliliters", preferredStyle: .alert)
        alert.addTextField{(textField) in
            textField.placeholder = "Amount (ml)"
            textField.keyboardType = .decimalPad
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) {[unowned self] (_) in
            guard let amountText = alert.textFields?.first?.text,
                  let amount = Double(amountText) else { return }
            let newLog = WaterLog(context: self.context)
            newLog.amount = amount
            newLog.date = Date()
            self.waterLogs.append(newLog)
            self.saveWaterLogs()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func saveWaterLogs(){
        do{
            try context.save()
            loadWaterLogs()
        } catch{
            print("Error saving water logs: \(error)")
        }
    }
    
    func loadWaterLogs(){
        let request: NSFetchRequest<WaterLog> = WaterLog.fetchRequest()
       
        // Sort the results by date, in decending order
        let sort = NSSortDescriptor(key: "date", ascending: false)
        request.sortDescriptors = [sort]
        
        do{
            waterLogs = try context.fetch(request)
            tableView.reloadData()
        } catch{
            print("Error loading water logs: \(error)")
        }
    }
}

extension MainViewController: UITableViewDataSource, UITableViewDelegate{
   
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return waterLogs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WaterLogCell", for: indexPath)
        let waterLog = waterLogs[indexPath.row]
        
        cell.textLabel?.text = "\(Int(waterLog.amount)) ml"
        
        if let date = waterLog.date{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .short
//            cell.detailTextLabel?.text = DateFormatter.localizedString(from: waterLog.date!, dateStyle: .short, timeStyle: .short)
            cell.detailTextLabel?.text = dateFormatter.string(from: date)
        }
        return cell
    }
    
    //Adding Edit and Delete actions using UIContextualAction
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        //Delete Action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") {[unowned self](action, view, completionHandler)  in
            waterLogs.remove(at: indexPath.row)
            saveWaterLogs()
            completionHandler(true)
        }
        
        //edit Action
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [unowned self] (action, view, completionHandler) in
            let waterLog = waterLogs[indexPath.row]
            
            let alert = UIAlertController(title: "Edit Water intake", message: "Update amount in milliliters", preferredStyle: .alert)
            alert.addTextField { (textField) in
                textField.text = "\(Int(waterLog.amount))"
                textField.keyboardType = .decimalPad
            }
            
            let updateAction = UIAlertAction(title: "Update", style: .default) {[unowned self] (_) in
                guard let amountText = alert.textFields?.first?.text,
                let amount = Double(amountText) else { return }
                waterLog.amount = amount
                saveWaterLogs()
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(updateAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
            completionHandler(true)
        }
        
        editAction.backgroundColor = .systemBlue
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction,editAction])
        return configuration
    }
}
