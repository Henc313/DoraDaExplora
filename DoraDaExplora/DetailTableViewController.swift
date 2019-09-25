//
//  DetailTableViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/3/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit

class DetailTableViewController: UITableViewController {
   
   var collapsed  = Bool()
   var walletData = WalletData()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.register(DetailCell.self, forCellReuseIdentifier: "detailCell")
      tableView.register(TitleCell.self, forCellReuseIdentifier: "titleCell")
      
      
      tableView.rowHeight = 44
      title = "Wallet Details"
      collapsed = true
      
      print(walletData.address)
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
      if indexPath.row == 0 {
         
         let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell") as! TitleCell
         cell.textLabel?.text = "\(walletData.rowTitles[indexPath.section])"
         
         switch indexPath.section {
         case 0:
            cell.detailLabel.text = walletData.address
         case 1:
            cell.detailLabel.text = "\(walletData.totalMNs)"
         case 2:
            cell.detailLabel.text = walletData.totalShares
         case 3:
            cell.detailLabel.text = "\(walletData.tiers[0].masterNodes.count)"
         case 4:
            cell.detailLabel.text = "\(walletData.tiers[1].masterNodes.count)"
         case 5:
            cell.detailLabel.text = "\(walletData.tiers[2].masterNodes.count)"
         case 6:
            cell.detailLabel.text = "\(walletData.tiers[3].masterNodes.count)"
         default:
            cell.detailLabel.text = "Sumtin' done messed up!"
         }
         
         return cell
         
      } else {
         let cell       = tableView.dequeueReusableCell(withIdentifier: "detailCell") as! DetailCell
         let masterNode = walletData.tiers[indexPath.section - 3].masterNodes[indexPath.row - 1]
         
         cell.detailLabel.text = masterNode.address
         
         switch masterNode.state {
         case 1:
            cell.detailLabel.textColor = #colorLiteral(red: 0.2196078449, green: 0.007843137719, blue: 0.8549019694, alpha: 1) // Initialize
         case 2:
            cell.detailLabel.textColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1) // Deposited
         case 3:
            cell.detailLabel.textColor = #colorLiteral(red: 0.2745098174, green: 0.4862745106, blue: 0.1411764771, alpha: 1) // Active
         case 4:
            cell.detailLabel.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) // Terminate
         default:
            cell.detailLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1) // Unknown
         }
         
         cell.textLabel?.text = walletData.tiers[indexPath.section - 3].masterNodes[indexPath.row - 1].shares
         cell.textLabel?.alpha = 0.75
         cell.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
         cell.textLabel?.font = UIFont(name: "Helvetica Neue", size: 14)
         
         return cell
      }
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      print(indexPath)
      if indexPath.section > 2 {
         walletData.tiers[indexPath.section - 3].collapsed.toggle()
         let sections = IndexSet.init(integer: indexPath.section)
         tableView.reloadSections(sections, with: .none)
      } else {
         tableView.deselectRow(at: indexPath, animated: true)
      }
   }
   
   
}
