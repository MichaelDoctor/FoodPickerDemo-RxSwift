//
//  ViewController.swift
//  FoodPickerDemo-RxSwift
//
//  Created by Michael Doctor on 2021-04-24.
//

import UIKit

class ViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        private var foods = [FoodItem]()
        
        override func viewDidLoad() {
            super.viewDidLoad()
            title = "Food Picker"
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTapped))
            
            getAllItems()
        }
        
        // table view setup
        
        // The int that is sent from this function tells the UITableView how many rows it needs to have in a section
        override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return foods.count
        }
        
        // Uses identifier we set on the cell. Allows us to put data into cells based on our foods data.
        override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            // returns a UITableViewCell object with the identifier we set
            let cell = tableView.dequeueReusableCell(withIdentifier: "Food Cell", for: indexPath)
            // Get specific foodItem using indexPath.row <- used alot
            let food = foods[indexPath.row]
            // look at Main.storyboard
            cell.textLabel?.text = food.name
            return cell
        }
        
        // does something when the cell is touchedUpInside
        override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            // Create a the ViewController in Main.storyboard
            if let detailViewController = storyboard?.instantiateViewController(identifier: "Food Detail") as? DetailViewController {
                // set the item property in DetailViewController.swift
                detailViewController.item = foods[indexPath.row]
                // Switch from ViewController to DetailViewController
                navigationController?.pushViewController(detailViewController, animated: true)
            }
        }
        
        override func viewWillAppear(_ animated: Bool) {
            // Everytime this view appears, get the updated items
            getAllItems()
        }
        
        // navbar items
        @objc func addTapped() {
            let alert = UIAlertController(title: "New Food", message: "Enter new food choice", preferredStyle: .alert)
            alert.addTextField(configurationHandler: nil)
            alert.addAction(UIAlertAction(title: "Submit", style: .default){
                [weak self] _ in
                guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else { return }
                self?.createItem(name: text)
            })
            present(alert, animated: true)
        }
        
        @objc func playTapped() {
            let alert: UIAlertController
            // Check if its empty
            if foods.count > 0 {
                let food = foods.randomElement()?.name
                alert = UIAlertController(title: food, message: "Try eating \(food!)", preferredStyle: .alert)
            } else {
                alert = UIAlertController(title: "Empty", message: "Please add choices before running", preferredStyle: .alert)
            }
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
        }
        
        // core data
        func getAllItems() {
            do {
                foods = try context.fetch(FoodItem.fetchRequest())
                
                // anything related to UI and that is not in viewDidLoad must be put into the main thread
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch {
                print("getAllItems error")
            }
        }
        
        func createItem(name: String) {
            let newItem = FoodItem(context: context)
            newItem.name = name
            
            do {
                try context.save()
                getAllItems()
            } catch {
                print("createItem Error")
            }
        }


}

