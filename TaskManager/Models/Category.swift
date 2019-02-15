//
//  Category.swift
//  TaskManager
//
//  Created by Yessine on 2/13/19.
//  Copyright © 2019 Choura Yessine. All rights reserved.
//

import UIKit

struct Category {
    var id: String!
    var name: String!
    var color: String!
    
    init(id: String? = nil, name: String? = nil, color: String? = nil) {
        self.id = id
        self.name = name
        self.color = color
    }
}
