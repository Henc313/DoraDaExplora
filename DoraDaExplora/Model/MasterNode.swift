//
//  MasterNode.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/5/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import Foundation


struct MasterNode {
   
   var shares: String
   var address: String
   
   enum Tier {
      case tier1, tier2, tier3, tier4
   }
   
   enum State {
      case active, deposited, suspended, invalidPing
   }
   
}
