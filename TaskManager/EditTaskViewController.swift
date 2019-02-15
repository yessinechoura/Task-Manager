//
//  EditViewController.swift
//  TaskManager
//
//  Created by Yessine on 2/13/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {

    let cellId = "preperty.cell"
    let tableView = UITableView()
    var numberOfRowns: Int!
    var propertySelected: Int!
    var placeHolderText: String!
    var delegate: EditDelegate!
    let textField = UITextField()
    var category: Category?
    var task: Task?
    var categories: [Category] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupTableView()
        
        // Creating date picker in case we are updating the competion date
        if propertySelected == 2 {
            let datePicker = UIDatePicker()
            view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        }
    }
    
    /// Called when the date is changed from the date picker
    
    @objc func dateChanged(_ sender: UIDatePicker) {
        delegate.taskCompletionDateChanged(sender.date)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        
        // If the view is disappearing we should notifiy about the task name or category change
        switch propertySelected {
        case 0:
            delegate.taskNameChanged(textField.text ?? "")
        case 3:
            delegate.categoryNameChanged(textField.text ?? "")
        default:
            break
        }
    }
    
    
    /// This function is for configuring the table view
    
    /**
     This function puts the table view in place using Auto Layout, it also configures its delegates and adds a background color
     */
    
    func setupTableView() {
        
        view.addSubview(tableView)
        
        // Delegate
        tableView.delegate = self
        tableView.dataSource = self
        
        //Background color
        tableView.backgroundColor = Colors.lightGray
        
        // Applying auto layout constraints for the table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        navigationController?.popViewController(animated: true)
        return true
    }
}

// TableView
extension EditViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRowns
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)
        
        // Settings for the cell
        cell.selectionStyle = .none
        
        switch propertySelected {
        
        // Creating a text field in case w're updating a name
        case 0, 3:
            textField.frame = cell.contentView.bounds
            textField.delegate = self
            textField.returnKeyType = .done
            cell.contentView.addSubview(textField)
            textField.translatesAutoresizingMaskIntoConstraints = false
            textField.widthAnchor.constraint(equalTo: cell.contentView.widthAnchor, multiplier: 0.9).isActive = true
            textField.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            textField.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
            textField.placeholder = placeHolderText
            textField.text = category?.name ?? task?.title
            
        // Listing categories in case w're chaging a task's category
        case 1:
            let category = categories[indexPath.row]
            cell.textLabel?.text = category.name
            cell.imageView?.image =  UIColor.init(hex: category.color ?? "")!.circle(radius: 15)
            cell.imageView?.layer.cornerRadius = 7.5
            cell.imageView?.clipsToBounds = true
            cell.accessoryType = category.name == task?.category?.name ? .checkmark : .none
            
        // Listing colors in case w're creating a category
        case 4:
            cell.textLabel?.text = "Color \(indexPath.row + 1)"
            cell.imageView?.image = UIColor.init(hex: Colors.allColors[indexPath.row])!.circle(radius: 15)
            cell.imageView?.layer.cornerRadius = 7.5
            cell.imageView?.clipsToBounds = true
            cell.accessoryType = category?.color == Colors.allColors[indexPath.row] ? .checkmark : .none
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch propertySelected {
        
        // Selecting a new category for a task
        case 1:
            delegate.taskCategoryChanged(categories[indexPath.row])
            navigationController?.popViewController(animated: true)
            
        // Selecting a new color for a new category
        case 4:
            delegate.categoryColorChanged(indexPath.row)
            navigationController?.popViewController(animated: true)
        default:
            break
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        
        // Add a footer for every section in the tableview just to add more spacing
        return UIView()
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Add a header for every section in the tableview just to add more spacing
        return UIView()
    }
}


// Defining a new protocol to notify different VC when there's a change
protocol EditDelegate {
    
    func categoryNameChanged(_ name: String)
    
    func categoryColorChanged(_ index: Int)
    
    func taskNameChanged(_ name: String)
    
    func taskCategoryChanged(_ category: Category)
    
    func taskCompletionDateChanged(_ completionDate: Date)
}

// Defining an empty corp for each method because not all of them will be used in each VC who will be a delegate
extension EditDelegate {
   
    func categoryNameChanged(_ name: String) {}
    
    func categoryColorChanged(_ index: Int) {}
    
    func taskNameChanged(_ name: String) {}
    
    func taskCategoryChanged(_ category: Category) {}
    
    func taskCompletionDateChanged(_ completionDate: Date) {}
}
