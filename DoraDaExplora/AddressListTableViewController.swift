//
//  AddressListTableViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/2/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit

protocol CanReceiveAddress { func getWallet(address: String) }


class AddressListTableViewController: UITableViewController {
   
   var delegate: CanReceiveAddress?
   
   var wallets = [WalletSection]()
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.rowHeight = 48
      
      wallets = [WalletSection(sectionName: "Halo Owned",
                               sectionWallets: [WalletSection.Wallets(name: "ArchNode", address: "0xBCEF3088C414D25dA1bDe04775D484177f9326CB"),
                                                WalletSection.Wallets(name: "DEX", address: "0x0256f12c5151f9260f3be56bc0f4a92d8501d6e3"),
                                                WalletSection.Wallets(name: "BlockFight", address: "0x3fcf16e7090fe013b5648d796908916b2290b6c6"),
                                                WalletSection.Wallets(name: "Blackout", address: "0x277AB01693C3d02939df1a90F8E78048e1379868")]),
                 WalletSection(sectionName: "Whales",
                               sectionWallets: [WalletSection.Wallets(name: "Baller", address: "0x251090F2661621D59AEdf8E17Ac0FB87255e12e6"),
                                                WalletSection.Wallets(name: "Dumpy", address: "0xb869D3C600a54e9BE280607C613A7D5137840192"),
                                                WalletSection.Wallets(name: "Bob Jones", address: "0xa7CE90F11B2D084170A17A0DDA0FDca113E5E2fb"),
                                                WalletSection.Wallets(name: "Halrid", address: "0x2E5e23362C842fD98DE97fD46E242430c14f8FC9")]),
                 WalletSection(sectionName: "Known",
                               sectionWallets: [WalletSection.Wallets(name: "Dingo", address: "678"),
                                                WalletSection.Wallets(name: "Bingo", address: "789"),
                                                WalletSection.Wallets(name: "Bongo", address: "4th Avenue"),
                                                WalletSection.Wallets(name: "Gavin", address: "0x5c2da9bbd16176a39fcf4f0b54c5299053363166")])]
   }
   
   
   override func numberOfSections(in tableView: UITableView) -> Int {
      return wallets.count
   }
   
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return wallets[section].sectionWallets.count
   }
   
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return wallets[section].sectionName
   }
   
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
      cell.textLabel?.text = wallets[indexPath.section].sectionWallets[indexPath.row].name
      if let label = cell.viewWithTag(200) as? UILabel {
         label.text = wallets[indexPath.section].sectionWallets[indexPath.row].address
      }
      
      return cell
   }
   
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      DispatchQueue.main.async {
         self.delegate?.getWallet(address: self.wallets[indexPath.section].sectionWallets[indexPath.row].address)
      }
      self.navigationController?.popViewController(animated: true)
   }
   
   
   override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
      if let detailTableViewController = storyboard?.instantiateViewController(withIdentifier: "detailTableViewController") as? DetailTableViewController {
         print(indexPath.row, indexPath.section)
         if let selectedWallet = wallets[indexPath.section].sectionWallets[indexPath.row].address {
            detailTableViewController.walletAddress = selectedWallet
            print(selectedWallet)
            self.show(detailTableViewController, sender: self)
         }
      }
      
      
   }
   
   
   //   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
   //      if segue.identifier == "detailViewControllerSegue" {
   //         let destinationVC = segue.destination as? DetailTableViewController
   //
   //         destinationVC?.walletAddress = "12345678"
   //      }
   //   }
   
}
