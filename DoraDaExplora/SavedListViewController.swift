//
//  CardViewController.swift
//  DoraDaExplora
//
//  Created by ♏︎ on 9/8/19.
//  Copyright © 2019 Henry Kivimaa. All rights reserved.
//

import UIKit
import SVProgressHUD


class SavedListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
   
   let defaults = UserDefaults.standard
   let addressListVC = AddressListTableViewController()
   var selectedWallet = ""
   var savedWallets = [String]()
   var walletData = WalletData()
   let detailTableViewController = DetailTableViewController()
   
   @IBOutlet var handleArea: UIView!
   @IBOutlet var handle: UIImageView!
   @IBOutlet var tableView: UITableView!
   
   
   override func viewDidLoad() {
      guard let walletList = defaults.object(forKey: "savedWallets") as? [String] else { return }
      savedWallets = walletList
      
      tableView.register(UINib(nibName: "SavedListView", bundle: nil), forCellReuseIdentifier: "detailCell")
      tableView.register(UINib(nibName: "SavedListView", bundle: nil), forCellReuseIdentifier: "mnCell")
      
      view.layer.cornerRadius = 12
      handle.layer.cornerRadius = 6
      handleArea.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
      handleArea.alpha = 0.90
      handle.alpha = 0.90
      view.backgroundColor = .clear
   }
   
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return savedWallets.count
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      tableView.register(UITableViewCell.self, forCellReuseIdentifier: "defaultCell")
      let cell = tableView.dequeueReusableCell(withIdentifier: "defaultCell", for: indexPath)
      if savedWallets.isEmpty {
         cell.textLabel?.text = "No addresses saved yet"
      } else {
         cell.textLabel?.text = savedWallets[indexPath.row]
      }
      return cell
   }
   
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      selectedWallet = savedWallets[indexPath.row]
      walletData.fetchWalletData(address: selectedWallet)
      detailTableViewController.walletData = walletData
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
         self.show(self.detailTableViewController, sender: self)
         SVProgressHUD.dismiss()
      }
   }
   

}
