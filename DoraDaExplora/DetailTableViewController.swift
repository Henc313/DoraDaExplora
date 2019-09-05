//
//  DetailTableViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/3/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

class DetailTableViewController: UITableViewController {
   
   var walletAddress: String?
   let url         = "https://mn-api.haloplatform.tech/owned/"
   var collapsed   = Bool()
   var totalMNs    = ""
   var walletData  = WalletData()
   var tierDetailsCollapsed = Bool()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.rowHeight = 44
      collapsed = true
      tierDetailsCollapsed = true
      
      DispatchQueue.global(qos: .background).async {
         if self.walletAddress != nil {
            self.fetchWalletData(url: self.url + self.walletAddress!)
         } else {
            self.walletAddress = "Could not fetch the data, check your connection and try again"
         }
      }
   }
   
   
   // MARK: - Table view data source
   override func numberOfSections(in tableView: UITableView) -> Int {
      return 1
   }
   
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if collapsed == true { return 1 }
      else {
         return walletData.rowTitles.count + 1
      }
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if indexPath.row == 0 {
         let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
         cell.textLabel?.text = walletAddress
         return cell
      } else {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") else { return UITableViewCell() }
         cell.textLabel?.text = walletData.rowTitles[indexPath.row - 1]
         cell.textLabel?.textColor = UIColor.darkGray
         
         if let detailLabel = cell.viewWithTag(125) as? UILabel {
            switch indexPath.row {
            case 1:
               detailLabel.text = walletData.totalMNs == 0 ? "This account has no MNs" : "\(walletData.totalMNs)"
            case 2:
               detailLabel.text = walletData.totalShares
            case 3:
               detailLabel.text = "\(walletData.t1Amount)"
            case 4:
               detailLabel.text = "\(walletData.t2Amount)"
            case 5:
               detailLabel.text = "\(walletData.t3Amount)"
            case 6:
               detailLabel.text = "\(walletData.t4Amount)"
            default:
               detailLabel.text = "Sumtin's messed up"
            }
         }
         return cell
      }
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      calculateTotalTierCount()
      if indexPath.row == 0 {
         collapsed.toggle()
      }
      let sections = IndexSet.init(integer: indexPath.section)
      tableView.reloadSections(sections, with: .none)
   }
   
   
   // MARK: - Fetch the JSON
   
   func fetchWalletData(url: String) {
      Alamofire.request(url, method: .get).responseJSON { response in
         if response.result.isSuccess {
            let jsonData = JSON(response.result.value as Any)
            self.walletData.totalShares = self.fetchTotalShares(json: jsonData)
            self.walletData.totalMNs = jsonData["result"].count
            self.fetchMNDetails(json: jsonData)
         } else {
            print("Error: \(String(describing: response.result.error))")
         }
      }
   }
   
   
   func fetchTotalShares(json: JSON) -> String {
      var totalSharesInMN: Double = 0
      
      if json["result"].count > 0 {
         for i in 1...json["result"].count {
            if let sharesInMN = json["result"][i - 1]["SHARES"].double {
               totalSharesInMN  += sharesInMN
            }
         }
      } else { return "N/A"}
      
      return format(number: totalSharesInMN)
   }
   
   
   func calculateTotalTierCount() {
      
      if walletData.t1Amount == 0 && walletData.t2Amount == 0 && walletData.t3Amount == 0 && walletData.t4Amount == 0 {
         for mn in walletData.masterNodes {
            if mn.tier == 1 {
               walletData.t1Amount += 1
            } else if mn.tier == 2 {
               walletData.t2Amount += 1
            } else if mn.tier == 3 {
               walletData.t3Amount += 1
            } else {
               walletData.t4Amount += 1
            }
         }
      }
   }
   
   
   func fetchMNDetails(json: JSON) {
      
      for mn in 0...json["result"].count {
         
         if let address = json["result"][mn]["ADDRESS"].string,
            let state = json["result"][mn]["STATE"].int,
            let tier = json["result"][mn]["TIER"].int,
            let shares = json["result"][mn]["SHARES"].double {
            
            let newMN = MasterNode(shares: format(number: shares), address: address, tier: tier, state: state)
            walletData.masterNodes.append(newMN)
         }
      }
   }
   
   
   func format(number: Double) -> String {
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.groupingSeparator = " "
      let dividedNumber = number / 1e18
      guard let formattedNumber = numberFormatter.string(from: NSNumber(value:dividedNumber)) else { return ""}
      
      return formattedNumber
   }
   
   
}
