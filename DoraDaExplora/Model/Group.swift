//
//  wallets.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/3/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//


struct Group {
   
   var name: String!
   var wallets: [Wallet]
   
   struct Wallet {
      let name: String!
      let address: String!
   }
}
