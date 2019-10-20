//let geth_url = "http://206.45.86.254:80"

import UIKit
import SVProgressHUD
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, CanReceiveAddress {
   
   //MARK:- Properties
   var wallet = "0xbcef3088c414d25da1bde04775d484177f9326cb"
   var numberFormatter: NumberFormatter?
   var addressList = [String]()
   var walletData = WalletData()
   let defaults = UserDefaults.standard
   var savedWallets = [String]()
   let detailTableViewController = DetailTableViewController()
   var walletBalance: String = "Display the wallet balance for selected wallet" {
      didSet {
         balanceLabel.text = walletBalance
      }
   }
   
   let addressListVC = AddressListTableViewController()
   var selectedWallet = ""
   
   enum CardState {
      case expanded
      case collapsed
   }
   
   let cardHeight: CGFloat = 700
   let cardWidth: CGFloat = 370
   let cardHeaderWidth: CGFloat = 40
   var cardExpandedPositionX: CGFloat = -5
   
   var cardVisible = false
   var nextState: CardState {
      return cardVisible ? .collapsed : .expanded
   }
   
   var runningAnimations = [UIViewPropertyAnimator]()
   var animationProgressWhenInterrupted: CGFloat = 0
   
   //MARK:- IBOutlets
   @IBOutlet var cardView: UIView!
   @IBOutlet var hitMeButton: UIButton!
   @IBOutlet var balanceLabel: UILabel!
   @IBOutlet var handleArea: UIView!
   @IBOutlet var handlebar: UIImageView!
   @IBOutlet var savedListTableView: UITableView!
   @IBOutlet var visualEffectView: UIVisualEffectView!
   
   //MARK:- ViewDidLoad
   override func viewDidLoad() {
      super.viewDidLoad()
      
      title = "Dora Da Explora"
      visualEffectView.effect   = nil
      visualEffectView.isHidden = true
      savedListTableView.delegate = self
      
      savedWallets = defaults.object(forKey: "savedWallets") as? [String] ?? [String]()
      setupCard()
      setUpButton()
      
      navigationItem.leftBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAddress))
      navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(goToAddressList)),
                                            UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(makeTabTransparent))
      ]
      savedListTableView.alpha = 0.75
      
      guard let walletList = defaults.object(forKey: "savedWallets") as? [String] else { return }
      savedWallets = walletList
   }
   
   //MARK:- Methods
   @objc func makeTabTransparent() {
      animateTransitionIfNeeded(state: nextState, duration: 1)
   }
   
   
   func setupCard() {
      cardView.layer.cornerRadius = 12
      cardView.frame = CGRect(x: 0 - cardWidth + cardHeaderWidth, y: 130, width: cardWidth, height: cardHeight)
      cardView.clipsToBounds = true
      
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))

      handleArea.addGestureRecognizer(tapGestureRecognizer)
      handleArea.addGestureRecognizer(panGestureRecognizer)
      
      view.layer.cornerRadius = 12
      handlebar.layer.cornerRadius = 6
      handleArea.backgroundColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
      handleArea.alpha = 0.75
      handlebar.alpha = 0.75
      cardView.backgroundColor = .clear
   }
   
   //MARK:- Animation Methods
   @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
      switch recognizer.state {
      case .ended:
         animateTransitionIfNeeded(state: nextState, duration: 0.9)
      default:
         break
      }
   }
   
   
   @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
      switch recognizer.state {
      case .began:
         startInteractiveTransition(state: nextState, duration: 0.9)
      case .changed:
         let translation = recognizer.translation(in: handleArea)
         var fractionComplete = translation.x / cardWidth
         fractionComplete = cardVisible ? -fractionComplete : fractionComplete
         updateInteractiveTransition(fractionCompleted: fractionComplete)
      case .ended:
         continueInteractiveTransition()
      default:
         break
      }
   }
   
   
   func animateTransitionIfNeeded(state: CardState, duration: TimeInterval) {
      if runningAnimations.isEmpty {
         let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            
            switch state {
            case .expanded:
               self.cardView.frame.origin.x = self.cardExpandedPositionX
            case .collapsed:
               self.cardView.frame.origin.x = self.cardHeaderWidth - self.cardWidth
            }
         }
         frameAnimator.addCompletion { _ in
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
         }
         
         frameAnimator.startAnimation()
         runningAnimations.append(frameAnimator)
         
         frameAnimator.startAnimation()
         runningAnimations.append(frameAnimator)
         
         let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
               self.visualEffectView.isHidden = false
               self.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .collapsed:
               self.visualEffectView.effect = nil
               DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                  self.visualEffectView.isHidden = true
               }
            }
         }
         
         blurAnimator.startAnimation()
         runningAnimations.append(blurAnimator)
      }
   }
   
   
   func startInteractiveTransition(state: CardState, duration: TimeInterval) {
      if runningAnimations.isEmpty {
         animateTransitionIfNeeded(state: state, duration: duration)
      }
      for animator in runningAnimations {
         animator.pauseAnimation()
         animationProgressWhenInterrupted = animator.fractionComplete
      }
   }
   
   
   func updateInteractiveTransition(fractionCompleted: CGFloat) {
      for animator in runningAnimations {
         animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
      }
   }
   
   
   func continueInteractiveTransition() {
      for animator in runningAnimations {
         animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
      }
   }
   
   //MARK:- IBActions
   @IBAction func hitMePressed(_ sender: Any) {
   }
   
   
   @objc func addNewAddress() {
      let ac = UIAlertController(title: "Enter address", message: nil, preferredStyle: .alert)
      ac.addTextField()
      ac.textFields![0].placeholder = "HALO Wallet Address Here"
      
      let saveAction = UIAlertAction(title: "Save", style: .default) { [unowned ac] _ in
         guard let walletAddress = ac.textFields![0].text else { return }
         
         if walletAddress.count != 42 {
            let errorAc = UIAlertController(title: "Address not valid", message: "The address you entered does not seem to be a correct Halo address, please check and try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            errorAc.addAction(action)
            self.present(errorAc, animated: true)
         } else {
            self.savedWallets.append(walletAddress)
            self.defaults.set(self.savedWallets, forKey: "savedWallets")
            self.savedListTableView.reloadData()
            let indexPaths: [IndexPath] = [[0, self.savedWallets.count]]
            self.savedListTableView.reloadRows(at: indexPaths, with: .automatic)
            
         }
      }
      
      let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
      
      ac.addAction(saveAction)
      ac.addAction(cancelAction)
      present(ac, animated: true)
   }
   
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "addressListSegue" {
         let secondVC = segue.destination as! AddressListTableViewController
         secondVC.delegate = self
      } else if segue.identifier == "SavedAddressSegue" {
         let destinationVC = segue.destination as! DetailTableViewController
         destinationVC.walletData = walletData
      }
   }
   
   
   @objc func goToAddressList() {
      performSegue(withIdentifier: "addressListSegue", sender: self)
   }
   
   
   func setUpButton() {
      hitMeButton.layer.backgroundColor = #colorLiteral(red: 0.1298420429, green: 0.1298461258, blue: 0.1298439503, alpha: 1)
      hitMeButton.layer.cornerRadius    = 17.0
      hitMeButton.layer.shadowColor     = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
      hitMeButton.layer.shadowRadius    = 8
      hitMeButton.layer.shadowOffset    = CGSize(width: 3, height: 4)
      hitMeButton.layer.shadowOpacity   = 1.0
      hitMeButton.setTitleColor(.lightGray, for: .normal)
   }
   
   
   func getWallet(address: String) {
      fetchWalletBalances(address: address)
   }
   
   
   func fetchWalletBalances(address: String) {
      let balanceRequestURL = "https://e-api.haloplatform.tech/halo/addresses/\(address)/balance"
      var balance: Double   = 0
      Alamofire.request(balanceRequestURL, method: .get).responseJSON { response in
         if response.result.isSuccess {
            let jsonData = JSON(response.result.value as Any)
            balance = jsonData["result"]["balance"].doubleValue
            self.walletBalance = "\(self.walletData.format(number: balance)) HALO"
         } else {
            print("Error \(String(describing: response.result.error))")
         }
      }
   }
   
   
}


//MARK:- Extensions
extension ViewController: UITableViewDataSource, UITableViewDelegate {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if savedWallets.isEmpty {
         return 1
      } else {
         return savedWallets.count + 1
      }
   }
   
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      if indexPath.row == 0 {
         if savedWallets.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticCell", for: indexPath)
            cell.textLabel?.text = "No addresses saved yet"
            cell.textLabel?.textColor = .white
            cell.isEditing = false
            return cell
         } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StaticCell", for: indexPath)
            cell.textLabel?.text = "Address book"
            cell.textLabel?.textColor = .white
            cell.isEditing = false
            return cell
         }
      } else {
         let cell = tableView.dequeueReusableCell(withIdentifier: "AddressBookCell", for: indexPath)
         cell.textLabel?.text = savedWallets[indexPath.row - 1]
         return cell
      }
   }
   
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      getWallet(address: savedWallets[indexPath.row - 1])
      tableView.deselectRow(at: indexPath, animated: true)
      animateTransitionIfNeeded(state: nextState, duration: 1.5)
   }
   
   
   func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
      walletData = WalletData()
      selectedWallet = savedWallets[indexPath.row - 1]
      walletData.fetchWalletData(address: selectedWallet)
      detailTableViewController.walletData = walletData
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
         
         self.show(self.detailTableViewController, sender: self)
         self.detailTableViewController.tableView.reloadData()
         SVProgressHUD.dismiss()
      }
   }
   
   
   func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
      if indexPath.row == 0 {
         return false
      } else { return true }
   }
   
   
   func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
      
      if editingStyle == .delete {
         savedWallets.remove(at: indexPath.row - 1)
         self.defaults.set(self.savedWallets, forKey: "savedWallets")
         
         tableView.beginUpdates()
         tableView.deleteRows(at: [indexPath], with: .automatic)
         var indexPaths = [IndexPath]()
         indexPaths = [[0, 0]]
         tableView.reloadRows(at: indexPaths, with: .automatic)
         tableView.endUpdates()
      }
   }
}
