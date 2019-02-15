//
//  TaskViewController.swift
//  TaskManager
//
//  Created by Yessine on 2/13/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit
import CoreData

class TaskViewController: UIViewController {

    let cellId = "task.preperty.cell"
    let propertiesTableView = UITableView()
    let firstSection = ["Name", "Category", "Completion Date"]
    var categories: [Category]!
    var selectedTask = Task()
    let categoryEntity = "CategoryEntity"
    let taskEntity = "TaskEntity"
    var delegate: TaskDelegate!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        setupView()
    }
    
    func setupView() {
        // Setting up add and settings buttons
        setupNavigationBar()
        
        // Setting up the table view
        setupPropertiesTableView()
    }
    
    
    /// This function helps setup the navigation bar
    
    /**
     This function sets the navigation controller name and configures both the save button and cancel button with text and actions
     */
    
    func setupNavigationBar() {
        
        title = "Task"
        
        let saveBarButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveAction))
        self.navigationItem.rightBarButtonItem = saveBarButton
        
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = cancelBarButton
    }
    
    
    /// This function triggers when save is pushed
    
    /**
     This function figures out if we are updating or creating a new task and does whatever is needed in both situation by updating the local storage or adding a new element to it
     */
    
    @objc func saveAction() {
        if selectedTask.title?.isEmpty ?? true || selectedTask.category == nil  {
            // Error
            if UserDefaults.standard.bool(forKey: "notification") {
                showSimpleAlert(alertMessage: "You pick a title and select a category!")
            }
        } else {
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            
            if selectedTask.id != nil {
                
                // Updating
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
                request.returnsObjectsAsFaults = false
                do {
                    let result = try managedContext.fetch(request)
                    // Storing currency rates in a global variable
                    for data in result as! [NSManagedObject] {
                        if let id = data.value(forKey: "id") as? String {
                            if id == selectedTask.id {
                                data.setValue(selectedTask.title, forKey: "title")
                                data.setValue(selectedTask.category?.id, forKey: "categoryId")
                                data.setValue(selectedTask.completed, forKey: "completed")
                                
                                if let completionDate = selectedTask.completionDate {
                                    data.setValue(completionDate, forKey: "completionDate")
                                }
                                
                                do {
                                    try managedContext.save()
                                    print("saved")
                                    delegate.taskUpdated(task: selectedTask)
                                    dismiss(animated: true, completion: nil)
                                    
                                } catch let error {
                                    print("Error: ", error)
                                }
                            }
                        }
                    }
                    
                } catch let error {
                    print("Error: ", error)
                }
            } else {
                
                // Creating
                let entity = NSEntityDescription.entity(forEntityName: taskEntity, in: managedContext)
                let taskObject = NSManagedObject(entity: entity!, insertInto: managedContext)
                
                taskObject.setValue(UserDefaults.standard.integer(forKey: "taskId").description, forKey: "id")
                taskObject.setValue(selectedTask.title, forKey: "title")
                taskObject.setValue(selectedTask.category?.id, forKey: "categoryId")
                taskObject.setValue(false, forKey: "completed")
                if let completionDate = selectedTask.completionDate {
                    taskObject.setValue(completionDate, forKey: "completionDate")
                }
                
                do {
                    try managedContext.save()
                    print("saved")
                    selectedTask.id = UserDefaults.standard.integer(forKey: "taskId").description
                    UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "taskId") + 1, forKey: "taskId")
                    delegate.taskCreated(newTask: selectedTask)
                    dismiss(animated: true, completion: nil)
                    
                } catch let error {
                    print("Error: ", error)
                }
            }
        }
    }
    
    
    /// Dismissing the view controller if the cancel button is pushed
    
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// This function is for configuring the table view
    
    /**
     This function puts the table view in place using Auto Layout, it also configures its delegates and adds a background color
     */
    
    func setupPropertiesTableView() {
        
        view.addSubview(propertiesTableView)
        
        // Delegate
        propertiesTableView.delegate = self
        propertiesTableView.dataSource = self
        
        // Background color
        propertiesTableView.backgroundColor = Colors.lightGray
        
        // Register cell
        propertiesTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        // Applying auto layout constraints for the table view
        propertiesTableView.translatesAutoresizingMaskIntoConstraints = false
        propertiesTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        propertiesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        propertiesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        propertiesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    
    /// This function triggers when delete button is pushed
    
    /**
     This function deletes the chosen task from local storage and notifies the main view controller
     */
    
    @objc func deleteTaskAction() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for index in 0...result.count - 1 {
                let data = result[index] as! NSManagedObject
                if let id = data.value(forKey: "id") as? String, id == selectedTask.id {
                    context.delete(data)
                    delegate.taskDeleted(idTask: id)
                    dismiss(animated: true, completion: nil)
                    break
                }
            }
            
        } catch {
            
            print("Failed")
        }
        do {
            try context.save()
        } catch _ {
        }
    }
}

// TableView
extension TaskViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // If w're creating a new task we can't delete it or mark as completed so there will be only 1 section and if w're updating there should be 3 sections
        return selectedTask.id == nil ? 1 : 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return section == 0 ? 3 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)

        // Settings for the cell
        cell.selectionStyle = .none
        
        
        switch indexPath.section {
            
        // First section of the table view
        case 0:
            cell.textLabel?.text = firstSection[indexPath.row]
            cell.accessoryType = .disclosureIndicator
            
            switch indexPath.row {
            
            // First element is the name
            case 0:
                cell.detailTextLabel?.text = selectedTask.title
                
            // Second element is the category
            case 1:
                cell.detailTextLabel?.text = selectedTask.category?.name
                
            // Third element is the completion date
            case 2:
                if let taskCompletionDate = selectedTask.completionDate {
                    // Formatting the date
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateStyle = .medium // Example: Feb 12, 2019
                    let formattedDate = dateFormatter.string(from: taskCompletionDate)
                    cell.detailTextLabel?.text = formattedDate
                }
            default:
                break
            }
            
        // Second section of the table view, completed check box
        case 1:
            cell.textLabel?.text = "Completed"
            cell.accessoryType = selectedTask.completed ? .checkmark : .none
            
        // Third section of the table view, deleting the task
        case 2:
            let deleteButton = UIButton(type: .system)
            deleteButton.tintColor = .red
            deleteButton.setTitle("Delete", for: .normal)
            deleteButton.addTarget(self, action: #selector(deleteTaskAction), for: .touchUpInside)
            cell.contentView.addSubview(deleteButton)
            deleteButton.translatesAutoresizingMaskIntoConstraints = false
            deleteButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            deleteButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
                
            // If we wish to edit something we should specify a property number so we can know what to do in the EditVC because it can be called other editing purposes
            // We also should specify some other variables like the number of row in the table view and the title of the VC
            case 0:
                let editTaskViewController = EditViewController()
                editTaskViewController.title = "Task Title"
                editTaskViewController.delegate = self
                editTaskViewController.task = selectedTask
                editTaskViewController.numberOfRowns = 1
                editTaskViewController.propertySelected = 0
                editTaskViewController.placeHolderText = "Title"
                navigationController?.pushViewController(editTaskViewController, animated: true)
                
            // If we wish to edit something we should specify a property number so we can know what to do in the EditVC because it can be called other editing purposes
            // We also should specify some other variables like the number of row in the table view and the title of the VC
            case 1:
                let editTaskViewController = EditViewController()
                editTaskViewController.title = "Task Category"
                editTaskViewController.delegate = self
                editTaskViewController.numberOfRowns = categories.count
                editTaskViewController.task = selectedTask
                editTaskViewController.categories = categories
                editTaskViewController.propertySelected = 1
                navigationController?.pushViewController(editTaskViewController, animated: true)
                
            // If we wish to edit something we should specify a property number so we can know what to do in the EditVC because it can be called other editing purposes
            // We also should specify some other variables like the number of row in the table view and the title of the VC
            case 2:
                let editTaskViewController = EditViewController()
                editTaskViewController.title = "Task Completion Date"
                editTaskViewController.delegate = self
                editTaskViewController.numberOfRowns = 0
                editTaskViewController.task = selectedTask
                editTaskViewController.propertySelected = 2
                navigationController?.pushViewController(editTaskViewController, animated: true)
            default:
                break
            }
            
            
        // This allows us to mark the task as completed
        case 1:
            selectedTask.completed = !selectedTask.completed
            tableView.cellForRow(at: indexPath)?.accessoryType = selectedTask.completed ? .checkmark : .none
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

// Edit Delegate, handles every change the user made in the task
extension TaskViewController: EditDelegate {
    
    // Updating the task category
    
    func taskCategoryChanged(_ category: Category) {
        selectedTask.category = category
        propertiesTableView.cellForRow(at: IndexPath(row: 1, section: 0))?.detailTextLabel?.text = category.name
    }
    
    //Updating the task name
    
    func taskNameChanged(_ name: String) {
        selectedTask.title = name
        propertiesTableView.cellForRow(at: IndexPath(row: 0, section: 0))?.detailTextLabel?.text = name
    }
    
    // Updating the task completin date
    
    func taskCompletionDateChanged(_ completionDate: Date) {
        selectedTask.completionDate = completionDate
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium // Example: Feb 12, 2019
        let formattedDate = dateFormatter.string(from: completionDate)
        propertiesTableView.cellForRow(at: IndexPath(row: 2, section: 0))?.detailTextLabel?.text = formattedDate
    }
}

// Definning a new protocol to notifiy the MainVC when a task is created, updated or deleted
protocol TaskDelegate {
    
    func taskCreated(newTask: Task)
    
    func taskUpdated(task: Task)
    
    func taskDeleted(idTask: String)
}
