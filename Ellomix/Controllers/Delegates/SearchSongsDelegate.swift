//
//  SearchSongsDelegate.swift
//  Ellomix
//
//  Created by Kevin Avila on 2/7/19.
//  Copyright © 2019 Ellomix. All rights reserved.
//

import UIKit

protocol SearchSongsDelegate {
    func doneSelecting(selected: [String:Dictionary<String, AnyObject>])
}
