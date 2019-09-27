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
   let url = "https://mn-api.haloplatform.tech/owned/"
   let eAPIurl = "https://e-api.haloplatform.tech/halo/addresses/"
   var walletData: WalletData?
   var groupedWallets = [Group]()
   
   override func viewDidAppear(_ animated: Bool) {
      walletData = WalletData()
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      groupedWallets = premiumWallets
      title = "Address List"
      tableView.rowHeight = 48
      tableView.separatorStyle = .none
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
      tableView.deselectRow(at: indexPath, animated: true)
      guard let walletAddress = groupedWallets[indexPath.section].wallets[indexPath.row].address else { return }
      delegate?.getWallet(address: walletAddress)
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
