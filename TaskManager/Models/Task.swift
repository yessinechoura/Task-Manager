//
//  Task.swift
//  TaskManager
//
//  Created by Yessine on 2/13/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit

struct Task {
    var id: String?
    var title: String?
    var completionDate: Date?
    var category: Category?
    var completed: Bool!
    
    init(id: String? = nil, title: String? = nil, completionDate: Date? = nil, category: Category? = nil, completed: Bool = false) {
        self.id = id
        self.title = title
        self.completionDate = completionDate
        self.category = category
        self.completed = completed
    }
}
