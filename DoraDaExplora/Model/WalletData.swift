//
//  WalletData.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/5/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import Alamofire
import Foundation
import SVProgressHUD
import SwiftyJSON

class WalletData {
   
   let apiURL = "https://mn-api.haloplatform.tech/owned/"
   let rowTitles   = ["Address", "Total MasterNodes", "Total Shares", "Tier 1", "Tier 2", "Tier 3", "Tier 4"]
   
   var address = ""
   var totalMNs: Int
   var totalShares = ""
   var tiers = [Tier(collapsed: true, name: "Tier1", masterNodes: []),
                Tier(collapsed: true, name: "Tier2", masterNodes: []),
                Tier(collapsed: true, name: "Tier3", masterNodes: []),
                Tier(collapsed: true, name: "Tier4", masterNodes: [])
               ]

   
   init(totalMNs: Int = 0) {
      self.totalMNs    = totalMNs
   }
   
   
   func fetchWalletData(address: String) {
      SVProgressHUD.show()
      self.address = address
      Alamofire.request(apiURL + address, method: .get).responseJSON { response in
         if response.result.isSuccess {
            let jsonData = JSON(response.result.value as Any)
            self.fetchTotalShares(json: jsonData)
            self.fetchMNDetails(json: jsonData)
         } else {
            print("Error: \(String(describing: response.result.error))")
            SVProgressHUD.dismiss()
         }
      }
   }
   
   
   private func fetchTotalShares(json: JSON) {
      var totalSharesInMN: Double = 0
      
      totalMNs = json["result"].count
      
      if json["result"].count > 0 {
         for i in 1...json["result"].count {
            if let sharesInMN = json["result"][i - 1]["SHARES"].double {
               totalSharesInMN  += sharesInMN
            }
         }
         self.totalShares = format(number: totalSharesInMN)
      } else {
         self.totalShares = "N/A"
      }
   }
   
   
   private func fetchMNDetails(json: JSON) {
      
      for mn in 0...json["result"].count {
         if let address = json["result"][mn]["ADDRESS"].string,
            let state = json["result"][mn]["STATE"].int,
            let tier = json["result"][mn]["TIER"].int,
            let shares = json["result"][mn]["SHARES"].double {
            
            let newMN = MasterNode(shares: format(number: shares), address: address, state: state, tier: tier)
            
            if newMN.tier == 1 {
               self.tiers[0].masterNodes.append(newMN)
            } else if newMN.tier == 2 {
               self.tiers[1].masterNodes.append(newMN)
            } else if newMN.tier == 3 {
               self.tiers[2].masterNodes.append(newMN)
            } else {
               self.tiers[3].masterNodes.append(newMN)
            }
         }
      }
   }
   
   
   private func format(number: Double) -> String {
      let numberFormatter = NumberFormatter()
      numberFormatter.numberStyle = .decimal
      numberFormatter.groupingSeparator = " "
      let dividedNumber = number / 1e18
      guard let formattedNumber = numberFormatter.string(from: NSNumber(value:dividedNumber)) else { return ""}
      
      return formattedNumber
   }
}
