//
//  WalletData.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/5/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import Foundation


struct WalletData {
   
   let rowTitles   = ["Total MasterNodes", "Total Shares", "Tier 1", "Tier 2", "Tier 3", "Tier 4"]
   
   var totalMNs: Int
   var totalShares: String?
   var t1Amount: Int
   var t2Amount: Int
   var t3Amount: Int
   var t4Amount: Int
   
   var masterNodes: [MasterNode]
   
   init(totalMNs: Int = 0, totalShares: String = "", t1Amount: Int = 0, t2Amount: Int = 0, t3Amount: Int = 0, t4Amount: Int = 0) {
      self.totalMNs = totalMNs
      self.totalShares = totalShares
      self.t1Amount = t1Amount
      self.t2Amount = t2Amount
      self.t3Amount = t3Amount
      self.t4Amount = t4Amount
      self.masterNodes = []
   }
}
