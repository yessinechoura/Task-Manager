//
//  MainViewController.swift
//  TaskManager
//
//  Created by Yessine on 2/12/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit
import CoreData

class MainViewController: UIViewController {

    var categories: [Category] = []
    var completedTasks: [Task] = []
    var uncompletedTasks: [Task] = []
    let cellId = "task.cell"
    let tasksTableView = UITableView()
    let categoryEntity = "CategoryEntity"
    let taskEntity = "TaskEntity"
    var selectedIndexPath: IndexPath!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Creating the view
        setupView()
        
        // Fetching categories from CoreData
        fetchCategories()
    
        // Fetching taks stored in CoreData
        fetchTasks()
    }
    
    func setupView() {
        // Setting up add and settings buttons
        setupNavigationBar()
        
        // Setting up the table view
        setupTasksTableView()
    }
    
    
    /// This function helps setup the navigation bar
    
    /**
     This function sets the navigation controller name and configures both the add button and settings button with images and actions
     */
    
    func setupNavigationBar() {
        
        title = "Task Manager"
        
        let addTaskBarButton = UIBarButtonItem(image: UIImage(named: "nav_bar_ic_add"), style: .plain, target: self, action: #selector(addTaskAction))
        self.navigationItem.rightBarButtonItem = addTaskBarButton
        
        let settingsBarButton = UIBarButtonItem(image: UIImage(named: "nav_bar_ic_settings"), style: .plain, target: self, action: #selector(settingsAction))
        self.navigationItem.leftBarButtonItem = settingsBarButton
    }
    
    
    /// This function triggers when the add button is pushed
    
    @objc func addTaskAction() {
        if categories.isEmpty {
            if UserDefaults.standard.bool(forKey: "notification") {
                showSimpleAlert(alertMessage: "You should create categories first!")
            }
            return
        }
        presentTaskViewController()
    }
    
    
    /// This function triggers when the settings button is pushed
    
    @objc func settingsAction() {
    
        let settingsViewController = SettingsViewController()
        settingsViewController.delegate = self
        let settingsNavigationController = UINavigationController(rootViewController: settingsViewController)
        settingsNavigationController.modalTransitionStyle = .coverVertical
        settingsNavigationController.modalPresentationStyle = .overCurrentContext
        self.present(settingsNavigationController, animated: true, completion: nil)
    }
    
    
    /// This function is for configuring the table view
    
    /**
     This function puts the table view in place using Auto Layout, it also configures its delegates and adds a background color
     */
    
    func setupTasksTableView() {
        
        view.addSubview(tasksTableView)
        
        // Delegates
        tasksTableView.delegate = self
        tasksTableView.dataSource = self
        
        // Background color
        tasksTableView.backgroundColor = Colors.lightGray
        
        // Applying auto layout constraints for the table view, leading, top, trailing and bottom
        tasksTableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tasksTableView.translatesAutoresizingMaskIntoConstraints = false
        tasksTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tasksTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tasksTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tasksTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    
    /// This function is for presenting the TaskViewController, when a Task is selected or simply when creating a new Task
    
    /**
     This function creates a new TaskVC, configures its delegate with some presenting animation
     */
    
    func presentTaskViewController(task: Task? = nil ) {
        let taskViewController = TaskViewController()
        taskViewController.selectedTask = task ?? Task()
        taskViewController.delegate = self
        taskViewController.categories = categories
        let taskNavigationController = UINavigationController(rootViewController: taskViewController)
        taskNavigationController.modalTransitionStyle = .coverVertical
        taskNavigationController.modalPresentationStyle = .overCurrentContext
        self.present(taskNavigationController, animated: true, completion: nil)
    }
}

// TableView
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        // We have 2 sections, completed tasks and uncompleted ones
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // The first section is for the uncompleted ones so if the sections is 0 the we should use uncompleted array
        return section == 0 ? uncompletedTasks.count : completedTasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)
        
        // Settings for the cell
        cell.selectionStyle = .none
        
        // Current task
        let task = indexPath.section == 0 ? uncompletedTasks[indexPath.row] : completedTasks[indexPath.row]
        
        // Adding the task name to the title and its category color
        cell.textLabel?.text = task.title
        cell.imageView?.image = UIColor.init(hex: task.category?.color ?? "FFFFFF")!.circle(radius: 15)
        cell.imageView?.layer.cornerRadius = 7.5
        cell.imageView?.clipsToBounds = true
        
        if let taskCompletionDate = task.completionDate {
            // Formatting the date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium // Example: Feb 12, 2019
            let formattedDate = dateFormatter.string(from: taskCompletionDate)
            cell.detailTextLabel?.text = formattedDate
        }
        
        cell.accessoryType =  task.completed ? .checkmark : .disclosureIndicator
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // Storing the selected index for updating purposes
        selectedIndexPath = indexPath
        
        // Presenting the TaskViewController with a selected Task
        presentTaskViewController(task: indexPath.section == 0 ? uncompletedTasks[indexPath.row] : completedTasks[indexPath.row])
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        // Deleting a Task using the swipe to delete
        // This search the task in CoreData and deletes it after that it updates the table view
        if editingStyle == .delete {
            
            let selectedTask = indexPath.section == 0 ? uncompletedTasks[indexPath.row] : completedTasks[indexPath.row]
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                for index in 0...result.count {
                    let data = result[index] as! NSManagedObject
                    if data.value(forKey: "id") as? String == selectedTask.id {
                        context.delete(data)
                        break
                    }
                }
                
            } catch {
                
                print("Failed")
            }
            do {
                try context.save()
                
                if indexPath.section == 0 {
                    uncompletedTasks.remove(at: indexPath.row)
                } else {
                    completedTasks.remove(at: indexPath.row)
                }
                tasksTableView.beginUpdates()
                tasksTableView.deleteRows(at: [indexPath], with: .right)
                tasksTableView.endUpdates()
            } catch _ {
            }
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

// CoreData
extension MainViewController {
    
    
    /// This function is for fetching tasks from local storage
    
    func fetchTasks() {
        
        uncompletedTasks.removeAll()
        completedTasks.removeAll()
        
        // Fetching data from local storage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: taskEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            for data in result as! [NSManagedObject] {
                if let id = data.value(forKey: "id") as? String,
                    let title = data.value(forKey: "title") as? String,
                    let completed = data.value(forKey: "completed") as? Bool,
                    let categoryId = data.value(forKey: "categoryId") as? String {
                    
                    let completionDate = data.value(forKey: "completionDate") as? Date
                    let task = Task(id: id, title: title, completionDate: completionDate, category: categories.filter({ $0.id == categoryId }).first! , completed: completed)
                    task.completed ? completedTasks.append(task) : uncompletedTasks.append(task)
                }
            }
            // Refreshing table view
            tasksTableView.reloadData()
            
        } catch let error {
            print("Error: ", error)
        }
    }
    
    
    /// This function is for fetching categories from local storage
    
    func fetchCategories() {
        
        categories.removeAll()
        
        // Fetching data from local storage
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: categoryEntity)
        request.returnsObjectsAsFaults = false
        do {
            let result = try context.fetch(request)
            // Storing currency rates in a global variable
            for data in result as! [NSManagedObject] {
                if let id = data.value(forKey: "id") as? String,
                    let name = data.value(forKey: "name") as? String,
                    let color = data.value(forKey: "color") as? String {
                    
                    self.categories.append(Category(id: id, name: name, color: color))
                }
            }
            // Refreshing table view
            
        } catch let error {
            print("Error: ", error)
        }
    }
}

// Category Delegate, handles creating new categories
extension MainViewController: CategoryDelegate {
    
    func categoryAdded(category: Category) {
        categories.append(category)
    }
}

// Task Delegate, handles creating, updating and deleting tasks
extension MainViewController: TaskDelegate {
    

    /// Handles the creating of new tasks by adding them to the table view
    
    func taskCreated(newTask: Task) {
        
        uncompletedTasks.append(newTask)
        tasksTableView.beginUpdates()
        tasksTableView.insertRows(at: [IndexPath(row: uncompletedTasks.count - 1, section: 0)], with: .left)
        tasksTableView.endUpdates()
    }
    
    
    /// Handles the update of tasks by updating the table view
    
    func taskUpdated(task: Task) {
        
        let selectedTask = selectedIndexPath.section == 0 ? uncompletedTasks[selectedIndexPath.row] : completedTasks[selectedIndexPath.row]
        
        if task.completed == selectedTask.completed {
            if selectedIndexPath.section == 0 {
                uncompletedTasks[selectedIndexPath.row] = task
            } else {
                completedTasks[selectedIndexPath.row] = task
            }
            tasksTableView.beginUpdates()
            tasksTableView.reloadRows(at: [selectedIndexPath], with: .fade)
            tasksTableView.endUpdates()
        } else {
            
            if selectedIndexPath.section == 0 {
                
                uncompletedTasks[selectedIndexPath.row] = task
                tasksTableView.beginUpdates()
                tasksTableView.reloadRows(at: [selectedIndexPath], with: .fade)
                tasksTableView.endUpdates()
                
                uncompletedTasks.remove(at: selectedIndexPath.row)
                completedTasks.append(task)
                
                tasksTableView.beginUpdates()
                tasksTableView.moveRow(at: selectedIndexPath, to: IndexPath(row: completedTasks.count - 1, section: 1))
                tasksTableView.endUpdates()
            } else {
                
                completedTasks[selectedIndexPath.row] = task
                tasksTableView.beginUpdates()
                tasksTableView.reloadRows(at: [selectedIndexPath], with: .fade)
                tasksTableView.endUpdates()
                
                completedTasks.remove(at: selectedIndexPath.row)
                uncompletedTasks.append(task)
                tasksTableView.beginUpdates()
                tasksTableView.moveRow(at: selectedIndexPath, to: IndexPath(row: uncompletedTasks.count - 1, section: 0))
                tasksTableView.endUpdates()
            }
        }
    }
    
    
    /// Handles the delete of tasks by deleting them to the table view
    
    func taskDeleted(idTask: String) {
        var tasks = selectedIndexPath.section == 0 ? uncompletedTasks : completedTasks
        for rowIndex in 0...tasks.count - 1 {
            let task = tasks[rowIndex]
            if task.id == idTask {
                if selectedIndexPath.section == 0 {
                   uncompletedTasks.remove(at: rowIndex)
                } else {
                    completedTasks.remove(at: rowIndex)
                }
                tasksTableView.beginUpdates()
                tasksTableView.deleteRows(at: [selectedIndexPath], with: .fade)
                tasksTableView.endUpdates()
                break
            }
        }
    }
}
