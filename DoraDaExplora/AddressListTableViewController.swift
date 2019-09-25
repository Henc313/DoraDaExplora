//
//  AddressListTableViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/2/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit
import SwiftyJSON
import Alamofire
import SVProgressHUD

protocol CanReceiveAddress { func getWallet(address: String) }


class AddressListTableViewController: UITableViewController {
   
   var delegate: CanReceiveAddress?
   let url            = "https://mn-api.haloplatform.tech/owned/"
   let eAPIurl        = "https://e-api.haloplatform.tech/halo/addresses/"
   var walletData: WalletData?
   var groupedWallets = [Group]()
   
   override func viewDidAppear(_ animated: Bool) {
      walletData = WalletData()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      title = "Address List"
      tableView.rowHeight = 48
      
      groupedWallets = [Group(name: "Halo Owned",
                              wallets: [Group.Wallet(name: "ArchNode", address: "0xBCEF3088C414D25dA1bDe04775D484177f9326CB"),
                                        Group.Wallet(name: "DEX", address: "0x0256f12c5151f9260f3be56bc0f4a92d8501d6e3"),
                                        Group.Wallet(name: "BlockFight", address: "0x3fcf16e7090fe013b5648d796908916b2290b6c6"),
                                        Group.Wallet(name: "Blackout", address: "0x277AB01693C3d02939df1a90F8E78048e1379868"),
                                        Group.Wallet(name: "Project Wes", address: "0x40431A7bF0Cf380339785e70688E9F385aB22684")]),
                        Group(name: "Whales",
                              wallets: [Group.Wallet(name: "Baller", address: "0x251090F2661621D59AEdf8E17Ac0FB87255e12e6"),
                                        Group.Wallet(name: "Dumpy", address: "0xb869D3C600a54e9BE280607C613A7D5137840192"),
                                        Group.Wallet(name: "3rd", address: "0x78AEf65955952f47ac3acD8f7AA90779992e3914"),
                                        Group.Wallet(name: "4th", address: "0x45b4749D82Cf410edA6D0A2bfa15E569eb81F618"),
                                        Group.Wallet(name: "5th", address: "0x96ab106bA3302B7FDdb6c81929f8D08C3197DDe8"),
                                        Group.Wallet(name: "Bob Jones", address: "0xa7CE90F11B2D084170A17A0DDA0FDca113E5E2fb"),
                                        Group.Wallet(name: "7th", address: "0x173F813A2Ee3d5e82ebBCE78954e7cbBed52D581"),
                                        Group.Wallet(name: "8th", address: "0xC1316CCAFE1386EB874b9C93B24F353dDCC22Bc8"),
                                        Group.Wallet(name: "9th", address: "0x12646F991F8778bb2Cf4283adACA0C3FA1a40040"),
                                        Group.Wallet(name: "10th", address: "0xcCC749e875b1CaA69e6eb616d0F4019b065FBD5A"),
                                        Group.Wallet(name: "Halrid", address: "0x2E5e23362C842fD98DE97fD46E242430c14f8FC9"),
                                        Group.Wallet(name: "12th", address: "0xed2EB93625f7C3a7d3232eaABDF615e478c99847")]),
                        Group(name: "Known",
                              wallets: [Group.Wallet(name: "Dingo", address: "678"),
                                        Group.Wallet(name: "Bingo", address: "789"),
                                        Group.Wallet(name: "Bongo", address: "4th Avenue"),
                                        Group.Wallet(name: "Gavin", address: "0x5c2da9bbd16176a39fcf4f0b54c5299053363166")])]
   }
   
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return groupedWallets.count
   }
   
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return groupedWallets[section].wallets.count
   }
   
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return groupedWallets[section].name
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
      cell.textLabel?.text = groupedWallets[indexPath.section].wallets[indexPath.row].name
      if let label = cell.viewWithTag(200) as? UILabel {
         label.text = groupedWallets[indexPath.section].wallets[indexPath.row].address
      }
      
      return cell
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      DispatchQueue.main.async {
         self.delegate?.getWallet(address: self.groupedWallets[indexPath.section].wallets[indexPath.row].address)
      }
      self.navigationController?.popViewController(animated: true)
   }
   
   
   override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
      if let selectedWallet = groupedWallets[indexPath.section].wallets[indexPath.row].address {
         walletData?.fetchWalletData(address: selectedWallet)
         
         DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            if let detailTableViewController = self.storyboard?.instantiateViewController(withIdentifier: "detailTableViewController") as? DetailTableViewController {
               detailTableViewController.walletData = self.walletData!
               self.show(detailTableViewController, sender: self)
               SVProgressHUD.dismiss()
            }
         }
      }
   }
   
   
   
}
