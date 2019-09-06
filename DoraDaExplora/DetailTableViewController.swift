//
//  DetailTableViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/3/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
   
   var collapsed   = Bool()
   var walletData: WalletData!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      print(walletData.tiers[0].masterNodes.count)
      tableView.rowHeight = 44
      collapsed = true
   }
   
   
   // MARK: - Table view data source
   override func numberOfSections(in tableView: UITableView) -> Int {
      return walletData.rowTitles.count
   }
   
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if section == 0 || section == 1 || section == 2 {
         return 1
      } else {
         if walletData.tiers[section - 3].collapsed {
            return 1
         } else {
            return walletData.tiers[section - 3].masterNodes.count + 1
         }
      }
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell", for: indexPath)
      cell.textLabel?.text = "\(walletData.rowTitles[indexPath.section])"
      
      if let detailLabel = cell.viewWithTag(125) as? UILabel {
         switch indexPath.section {
         case 0:
            detailLabel.text = walletData.address
         case 1:
            detailLabel.text = "\(walletData.totalMNs)"
         case 2:
            detailLabel.text = walletData.totalShares
         case 3:
            detailLabel.text = "\(walletData.tiers[0].masterNodes.count)"
         case 4:
            detailLabel.text = "\(walletData.tiers[1].masterNodes.count)"
         case 5:
            detailLabel.text = "\(walletData.tiers[2].masterNodes.count)"
         case 6:
            detailLabel.text = "\(walletData.tiers[3].masterNodes.count)"
         default:
            detailLabel.text = "Sumtin' done messed up!"
         }
      }
      
      return cell
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      print(indexPath)
      if indexPath.section > 2 {
         print(indexPath)
         walletData.tiers[indexPath.section - 3].collapsed.toggle()
         let sections = IndexSet.init(integer: indexPath.section)
         tableView.reloadSections(sections, with: .none)
      } else {
         tableView.deselectRow(at: indexPath, animated: true)
         print(indexPath)
      }
   }
   
   
}
