

import UIKit
import Web3swift
import CryptoSwift
import BigInt

class ViewController: UIViewController, CanReceiveAddress {
   
   var wallet   = "0xbcef3088c414d25da1bde04775d484177f9326cb"
   let geth_url = "http://206.45.86.254:80"
   var numberFormatter: NumberFormatter?
   
   
   @IBOutlet var hitMeButton: UIButton!
   @IBOutlet var balanceLabel: UILabel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
      
      hitMeButton.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      hitMeButton.layer.cornerRadius    = 17.0
      hitMeButton.layer.shadowColor     = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
      hitMeButton.layer.shadowRadius    = 8
      hitMeButton.layer.shadowOffset    = CGSize(width: 3, height: 4)
      hitMeButton.layer.shadowOpacity   = 1.0
      hitMeButton.setTitleColor(.darkGray, for: .normal)
      
      navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAddress))
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(goToAddressList))
   }
   
   
   @IBAction func hitMePressed(_ sender: Any) {
      testDeployWithRemoteSigning()
   }
   
   
   func testDeployWithRemoteSigning() {
      let web3 = try! Web3.new(URL.init(string: geth_url)!)
      guard let address = EthereumAddress(wallet) else { return }
      let balance = (try! web3.eth.getBalance(address: address))/BigUInt(1e18)
      
      updateUI(with: balance)
   }
   
   
   @objc func addNewAddress() {
      let ac = UIAlertController(title: "Enter address", message: nil, preferredStyle: .alert)
      ac.addTextField()
      ac.textFields![0].placeholder = "HALO Wallet Address Here"
      
      let getTheBalance = UIAlertAction(title: "Get the Balance", style: .default) { [unowned ac] _ in
         let walletAddress = ac.textFields![0].text
         
         if walletAddress!.count != 42 {
            self.balanceLabel.text = "Address not valid"
         }
         
         self.wallet = walletAddress!
         self.testDeployWithRemoteSigning()
      }
      
      ac.addAction(getTheBalance)
      present(ac, animated: true)
   }
   
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "addressListSegue" {
         let secondVC = segue.destination as! AddressListTableViewController
         secondVC.delegate = self
      }
   }
   
   
   @objc func goToAddressList() {
      performSegue(withIdentifier: "addressListSegue", sender: self)
   }
   
   
   func format(number: BigUInt) -> String? {
      numberFormatter = NumberFormatter()
      numberFormatter?.usesGroupingSeparator = true
      numberFormatter?.groupingSeparator = " "
      numberFormatter?.numberStyle = .decimal
      numberFormatter?.positiveSuffix = " HALO"
      numberFormatter?.positivePrefix = "Balance is "
      
      let numberAsInteger = Int(number)
      let formattedNumber = numberFormatter?.string(from: NSNumber(value: numberAsInteger))
      
      return formattedNumber ?? ""
   }
   
   
   func updateUI(with balance: BigUInt) {
      balanceLabel.text = format(number: balance)
      
   }
   
   
   func getWallet(address: String) {
      wallet = address
      testDeployWithRemoteSigning()
   }
   
   
}
