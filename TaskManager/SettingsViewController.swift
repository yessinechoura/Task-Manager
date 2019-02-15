//
//  SettingsViewController.swift
//  TaskManager
//
//  Created by Yessine on 2/13/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UIViewController {

    let cellId = "settings.cell"
    let tableView = UITableView()
    var numberOfRowns: Int!
    var propertySelected: Int!
    var category = Category()
    let categoryEntity = "CategoryEntity"
    var delegate: CategoryDelegate!
    let notifSwitch = UISwitch()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        setupView()
    }
    
    func setupView() {
        // Setting up add and settings buttons
        setupNavigationBar()
        
        // Setting up the table view
        setupTableView()
    }
    
    
    /// This function helps setup the navigation bar
    
    /**
     This function sets the navigation controller name and configures cancel button with text and actions
     */
    
    func setupNavigationBar() {
        
        title = "Task"
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelAction))
        self.navigationItem.leftBarButtonItem = cancelBarButton
    }
    
    
    /// Dismissing the view controller if the cancel button is pushed
    
    @objc func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    
    /// This function triggers when add category is pushed
    
    /**
     This function creates a new task in the local storage
     */
    
    @objc func addCategoryAction() {
        
        guard let color = category.color, let name = category.name else {
            showSimpleAlert(alertMessage: "You should pick a name and a color!")
            return
        }
        if color.isEmpty || name.isEmpty {
            showSimpleAlert(alertMessage: "You should pick a name and color!")
        } else {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedContext = appDelegate.persistentContainer.viewContext
            let entity = NSEntityDescription.entity(forEntityName: categoryEntity, in: managedContext)
            let categoryObject = NSManagedObject(entity: entity!, insertInto: managedContext)
            categoryObject.setValue(UserDefaults.standard.integer(forKey: "categoryId").description, forKey: "id")
            categoryObject.setValue(name, forKey: "name")
            categoryObject.setValue(color, forKey: "color")
            do {
                try managedContext.save()
                UserDefaults.standard.set(UserDefaults.standard.integer(forKey: "categoryId") + 1, forKey: "categoryId")
                delegate.categoryAdded(category: category)
                dismiss(animated: true, completion: nil)
            } catch let error {
                print("Error: ", error)
            }
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
        
        // Background color
        tableView.backgroundColor = Colors.lightGray
        
        // Register cell
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        // Applying auto layout constraints for the table view
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    }
    
    
    /// This function triggers when notification switch is pushed
    
    /**
     This function allows user to activate and desactivate notifications
     */
    
    @objc func switchAction() {
        UserDefaults.standard.set(notifSwitch.isOn, forKey: "notification")
    }
}

// TableView
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 1 ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: cellId)
        
        // Settings for the cell
        cell.selectionStyle = .none
        
        // First section is for the notifcation, second for category properties and third for adding the category
        switch indexPath.section {
        case 0:
            cell.textLabel?.text = "Notifications"
            notifSwitch.addTarget(self, action: #selector(switchAction), for: .valueChanged)
            notifSwitch.isOn = UserDefaults.standard.bool(forKey: "notification")
            cell.accessoryView = notifSwitch
        case 1:
            switch indexPath.row {
            case 0:
                cell.textLabel?.text = "Category Name"
                cell.accessoryType = .disclosureIndicator
            case 1:
                cell.textLabel?.text = "Category Color"
                cell.accessoryType = .disclosureIndicator
            default:
                break
            }
        case 2:
            let addButton = UIButton(type: .system)
            addButton.setTitle("Add Category", for: .normal)
            addButton.addTarget(self, action: #selector(addCategoryAction), for: .touchUpInside)
            cell.contentView.addSubview(addButton)
            addButton.translatesAutoresizingMaskIntoConstraints = false
            addButton.centerXAnchor.constraint(equalTo: cell.contentView.centerXAnchor).isActive = true
            addButton.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor).isActive = true
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0:
            break
        case 1:
            switch indexPath.row {
            // If we wish to edit something we should specify a property number so we can know what to do in the EditVC because it can be called other editing purposes
            // We also should specify some other variables like the number of row in the table view and the title of the VC
            case 0:
                let editTaskViewController = EditViewController()
                editTaskViewController.title = "Category Name"
                editTaskViewController.delegate = self
                editTaskViewController.numberOfRowns = 1
                editTaskViewController.propertySelected = 3
                editTaskViewController.placeHolderText = "Category Name"
                editTaskViewController.category = category
                navigationController?.pushViewController(editTaskViewController, animated: true)
                
            // If we wish to edit something we should specify a property number so we can know what to do in the EditVC because it can be called other editing purposes
            // We also should specify some other variables like the number of row in the table view and the title of the VC
            case 1:
                let editTaskViewController = EditViewController()
                editTaskViewController.title = "Category Color"
                editTaskViewController.delegate = self
                editTaskViewController.numberOfRowns = Colors.allColors.count
                editTaskViewController.propertySelected = 4
                editTaskViewController.category = category
                navigationController?.pushViewController(editTaskViewController, animated: true)
            default:
                break
            }
        case 2:
            break
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

// Edit Delegate
extension SettingsViewController: EditDelegate {
    
    // Updating the category name when changed from the EditVC
    
    func categoryNameChanged(_ name: String) {
        category.name = name
        tableView.cellForRow(at: IndexPath(row: 0, section: 1))?.detailTextLabel?.text = name
    }
    
    // Updating the category color when changed from the EditVC
    
    func categoryColorChanged(_ index: Int) {
        let color = Colors.allColors[index]
        category.color = color
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        imageView.image =  UIColor.init(hex: color)!.circle(radius: 15)
        imageView.layer.cornerRadius = 7.5
        imageView.clipsToBounds = true
        tableView.cellForRow(at: IndexPath(row: 1, section: 1))?.accessoryView = imageView
    }
}

// Defining a new protocol to notify MainVC when a new category is created
protocol CategoryDelegate {
    
    func categoryAdded(category: Category)
}
