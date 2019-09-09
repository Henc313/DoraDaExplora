//
//  CardViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/8/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit

class SavedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   
   @IBOutlet var handleArea: UIView!
   
   override func viewDidLoad() {
      view.layer.cornerRadius = 12
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return UITableViewCell()
   }
   
   
   
   
}
