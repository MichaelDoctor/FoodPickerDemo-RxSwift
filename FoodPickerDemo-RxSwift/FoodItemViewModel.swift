//
//  FoodItemViewModel.swift
//  FoodPickerDemo-RxSwift
//
//  Created by Michael Doctor on 2021-04-24.
//

import RxSwift
import RxCocoa

struct FoodItemViewModel {
    // publisher = allow observer to get notified that the data changed
    // collection of models
    var foods: BehaviorRelay<[FoodItem]> = BehaviorRelay(value: [])
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    // update food list
    func fetchItems() {
        var foodItems = [FoodItem]()
        do {
            foodItems = try context.fetch(FoodItem.fetchRequest())
        } catch {
            print("getAllItems error")
        }
        
        foods.accept(foodItems)
    }
}
