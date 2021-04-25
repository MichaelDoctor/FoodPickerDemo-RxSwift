//
//  ViewController.swift
//  FoodPickerDemo-RxSwift
//
//  Created by Michael Doctor on 2021-04-24.
//

import UIKit
import RxSwift
import RxCocoa

class ViewController: UITableViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // RxSwift
    private var bag = DisposeBag()
    private var viewModel = FoodItemViewModel()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Food Picker"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTapped))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playTapped))
        
        bindTableData()
    }
    
    // RxSwift
    // tells UI to update itself if data changes
    func bindTableData() {
        tableView.dataSource = nil
        
        // replaces cellForRowAt and numberOfRowsInSection
        viewModel.foods.bind(to: tableView.rx.items(cellIdentifier: "Food Cell", cellType: UITableViewCell.self)){
            row, model, cell in
            cell.textLabel?.text = model.name
        }.disposed(by: bag) // disposed deals memory managements
        
        // replaces didSelectRowAt
        tableView.rx.modelSelected(FoodItem.self).bind { foodItem in
            // Create a the ViewController in Main.storyboard
            if let detailViewController = self.storyboard?.instantiateViewController(identifier: "Food Detail") as? DetailViewController {
                // set the item property in DetailViewController.swift
                detailViewController.item = foodItem
                // Switch from ViewController to DetailViewController
                self.navigationController?.pushViewController(detailViewController, animated: true)
            }
        }.disposed(by: bag)
        
        // fetch items
        viewModel.fetchItems()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // Everytime this view appears, get the updated items
        viewModel.fetchItems()
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
        if viewModel.foods.value.count > 0 {
            let food = viewModel.foods.value.randomElement()?.name
            alert = UIAlertController(title: food, message: "Try eating \(food!)", preferredStyle: .alert)
        } else {
            alert = UIAlertController(title: "Empty", message: "Please add choices before running", preferredStyle: .alert)
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func createItem(name: String) {
        let newItem = FoodItem(context: context)
        newItem.name = name
        
        do {
            try context.save()
            viewModel.fetchItems()
        } catch {
            print("createItem Error")
        }
    }
    
    
}

