import UIKit
import Web3swift
import CryptoSwift
import BigInt
import SVProgressHUD

class ViewController: UIViewController, CanReceiveAddress {
   
   var wallet   = "0xbcef3088c414d25da1bde04775d484177f9326cb"
   let geth_url = "http://206.45.86.254:80"
   var numberFormatter: NumberFormatter?
   var addressList = [String]()
   var walletData = WalletData()
   let defaults = UserDefaults.standard
   var savedWallets = [String]()
   
   enum CardState {
      case expanded
      case collapsed
   }
   
   var cardViewController: SavedListViewController!
   var visualEffectView: UIVisualEffectView!
   
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
   
   @IBOutlet var hitMeButton: UIButton!
   @IBOutlet var balanceLabel: UILabel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      savedWallets = defaults.object(forKey: "savedWallets") as? [String] ?? [String]()
      setupCard()
      setUpButton()
      
      view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
      
      navigationItem.leftBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAddress))
      navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(goToAddressList)),
                                            UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(makeTabTransparent))]
   }
   
   
   @objc func makeTabTransparent() {
      animateTransitionIfNeeded(state: nextState, duration: 1)
//      print(cardViewController.handleArea.alpha)
//      if cardViewController.handleArea.alpha > 0.50 {
//         cardViewController.handle.alpha = 0.1
//         cardViewController.handleArea.alpha = 0.1
//      } else {
//         cardViewController.handle.alpha = 0.90
//         cardViewController.handleArea.alpha = 0.90
//      }
   }
   
   
   func setupCard() {
      
      cardViewController = SavedListViewController(nibName: "SavedListView", bundle: nil)
      self.addChild(cardViewController)
      self.view.addSubview(cardViewController.view)
      
      cardViewController.view.frame = CGRect(x: 0 - cardWidth + cardHeaderWidth, y: 130, width: cardWidth, height: cardHeight)
      cardViewController.view.clipsToBounds = true
      
      let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.handleCardTap(recognizer:)))
      let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(ViewController.handleCardPan(recognizer:)))
      
      cardViewController.handleArea.addGestureRecognizer(tapGestureRecognizer)
      cardViewController.handleArea.addGestureRecognizer(panGestureRecognizer)
   }
   
   
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
         let translation = recognizer.translation(in: self.cardViewController.handleArea)
         var fractionComplete = translation.x / cardWidth
         fractionComplete = cardVisible ? fractionComplete : -fractionComplete
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
               self.cardViewController.view.frame.origin.x = self.cardExpandedPositionX
            case .collapsed:
               self.cardViewController.view.frame.origin.x = self.cardHeaderWidth - self.cardWidth
            }
         }
         frameAnimator.addCompletion { _ in
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
         }
         
         frameAnimator.startAnimation()
         runningAnimations.append(frameAnimator)
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
   
   
   @IBAction func hitMePressed(_ sender: Any) {
      print("PRESSED")
      performSegue(withIdentifier: "savedAddressSegue", sender: self)
   }
   
   
   @objc func addNewAddress() {
      let ac = UIAlertController(title: "Enter address", message: nil, preferredStyle: .alert)
      ac.addTextField()
      ac.textFields![0].placeholder = "HALO Wallet Address Here"
      
      let getTheBalance = UIAlertAction(title: "Save", style: .default) { [unowned ac] _ in
         guard let walletAddress = ac.textFields![0].text else { return }
         
         if walletAddress.count != 42 {
            let errorAc = UIAlertController(title: "Address not valid", message: "The address you entered does not seem to be a correct Halo address, please check and try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            errorAc.addAction(action)
            self.present(errorAc, animated: true)
         } else {
            self.savedWallets.append(walletAddress)
            self.defaults.set(self.savedWallets, forKey: "savedWallets")
            self.cardViewController.tableView.reloadData()
         }
      }
      
      ac.addAction(getTheBalance)
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
   
   
   func setUpButton() {
      hitMeButton.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      hitMeButton.layer.cornerRadius    = 17.0
      hitMeButton.layer.shadowColor     = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
      hitMeButton.layer.shadowRadius    = 8
      hitMeButton.layer.shadowOffset    = CGSize(width: 3, height: 4)
      hitMeButton.layer.shadowOpacity   = 1.0
      hitMeButton.setTitleColor(.darkGray, for: .normal)
   }
   
   func getWallet(address: String) {
      // Protocol Method
   }
}
