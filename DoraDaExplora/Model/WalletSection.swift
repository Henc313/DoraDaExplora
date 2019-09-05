//
//  wallets.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/3/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//


struct WalletSection {
   
   var sectionName: String!
   var sectionWallets: [Wallets]
   
   struct Wallets {
      let name: String!
      let address: String!
   }
}
