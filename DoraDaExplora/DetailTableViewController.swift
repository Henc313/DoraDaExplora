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
   let rowTitles   = ["Total MNs", "Total Shares", "Tier 1", "Tier 2", "Tier 3", "Tier 4"]
   var walletData  = [String]()
   var masterNodes = [MasterNode]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.rowHeight = 44
      collapsed = true
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
      else { return walletData.count + 1}
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if indexPath.row == 0 { // Use modular operator to make every 4th row the title cell
         let cell = tableView.dequeueReusableCell(withIdentifier: "titleCell", for: indexPath)
         cell.textLabel?.text = walletAddress
         return cell
      } else {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "detailCell") else { return UITableViewCell() }
         cell.textLabel?.text = rowTitles[indexPath.row - 1]
         cell.textLabel?.textColor = UIColor.darkGray
         if let detailLabel = cell.viewWithTag(125) as? UILabel {
            detailLabel.text = walletData[indexPath.row - 1]
         }
         return cell
      }
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
            self.walletData.append(self.fetchTotalMNs(json: jsonData))
            self.walletData.append(self.fetchTotalShares(json: jsonData))
            self.fetchTierAmounts(json: jsonData)
         } else {
            print("Error: \(String(describing: response.result.error))")
         }
      }
   }
   
   
   func fetchTotalMNs(json: JSON) -> String {
      if json["result"].count > 0 {
         return String(json["result"].count)
      } else {
         return "That address has no MNs"
      }
   }
   
   
   func fetchTotalShares(json: JSON) -> String {
      var totalSharesInMN: Double = 0
      
      if json["result"].count > 0 {
         for i in 1...json["result"].count {
            if let sharesInMN = json["result"][i - 1]["SHARES"].double {
               let roundedAmount = (sharesInMN/1e18)
               totalSharesInMN  += roundedAmount
            }
         }
      } else { return "N/A"}
      
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.groupingSeparator = " "
      guard let formattedNumber = numberFormatter.string(from: NSNumber(value:totalSharesInMN)) else { return ""}
      
      return formattedNumber
   }
   
   
   func fetchTierAmounts(json: JSON) {
      
      var count = 0
      var tier1 = 0
      var tier2 = 0
      var tier3 = 0
      var tier4 = 0
      
      while count < json["result"].count {
         if json["result"][count]["TIER"] == 1 {
            tier1 += 1
         } else if json["result"][count]["TIER"] == 2 {
            tier2 += 1
         } else if json["result"][count]["TIER"] == 3 {
            tier3 += 1
         } else {
            tier4 += 1
         }
         count += 1
      }
      
      let tierCounts = [tier1, tier2, tier3, tier4]
      
      if tierCounts == [0, 0, 0, 0] {
         
      } else {
         for tier in tierCounts {
            walletData.append(String(tier))
         }
      }
   }
}
