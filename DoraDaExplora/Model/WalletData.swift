//
//  WalletData.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/5/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import Foundation


struct WalletData {
   
   let rowTitles   = ["Address", "Total MasterNodes", "Total Shares", "Tier 1", "Tier 2", "Tier 3", "Tier 4"]
   
   var address: String?
   var totalMNs: Int
   var totalShares: String?
   var tiers = [Tier(collapsed: true, name: "Tier1", masterNodes: []),
                Tier(collapsed: true, name: "Tier2", masterNodes: []),
                Tier(collapsed: true, name: "Tier3", masterNodes: []),
                Tier(collapsed: true, name: "Tier4", masterNodes: [])
               ]

   
   init(totalMNs: Int = 0, totalShares: String = "") {
      self.totalMNs = totalMNs
      self.totalShares = totalShares
   }
}
// Make the tier amounts into an array, so you can pick the neccesary tier with indexes when opening and closing section in a tableView
