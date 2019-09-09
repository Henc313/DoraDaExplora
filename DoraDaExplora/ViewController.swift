import UIKit
import Web3swift
import CryptoSwift
import BigInt

class ViewController: UIViewController, CanReceiveAddress {
   
   var wallet   = "0xbcef3088c414d25da1bde04775d484177f9326cb"
   let geth_url = "http://206.45.86.254:80"
   var numberFormatter: NumberFormatter?
   
   @IBAction func testButton(_ sender: Any) {
      print("Anything")
   }
   enum CardState {
      case expanded
      case collapsed
   }
   
   var cardViewController: SavedListViewController!
   var visualEffectView: UIVisualEffectView!
   
   let cardHeight: CGFloat = 400
   let cardHeaderHeight: CGFloat = 42
   
   var cardVisible = false
   var nextState: CardState {
      return cardVisible ? .collapsed : .expanded
   }
   
   var runningAnimations = [UIViewPropertyAnimator]()
   var animationProgressWhenInterrupted: CGFloat = 0
   
   func setupCard() {
      visualEffectView = UIVisualEffectView()
      visualEffectView.frame = self.view.frame
      self.view.addSubview(visualEffectView)
      
      cardViewController = SavedListViewController(nibName: "SavedListView", bundle: nil)
      self.addChild(cardViewController)
      self.view.addSubview(cardViewController.view)
      
      cardViewController.view.frame = CGRect(x: 0, y: self.view.frame.height - cardHeaderHeight, width: self.view.bounds.width, height: cardHeight)
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
         var fractionComplete = translation.y / cardHeight
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
               self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeight
            case .collapsed:
               self.cardViewController.view.frame.origin.y = self.view.frame.height - self.cardHeaderHeight
            }
         }
         frameAnimator.addCompletion { _ in
            self.cardVisible = !self.cardVisible
            self.runningAnimations.removeAll()
         }
         
         frameAnimator.startAnimation()
         runningAnimations.append(frameAnimator)
         
         let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
            switch state {
            case .expanded:
               self.visualEffectView.effect = UIBlurEffect(style: .dark)
            case .collapsed:
               self.visualEffectView.effect = nil
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
   
   
   @IBOutlet var hitMeButton: UIButton!
   @IBOutlet var balanceLabel: UILabel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setupCard()
      
      view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
      
      hitMeButton.layer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
      hitMeButton.layer.cornerRadius    = 17.0
      hitMeButton.layer.shadowColor     = #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
      hitMeButton.layer.shadowRadius    = 8
      hitMeButton.layer.shadowOffset    = CGSize(width: 3, height: 4)
      hitMeButton.layer.shadowOpacity   = 1.0
      hitMeButton.setTitleColor(.darkGray, for: .normal)
      view.bringSubviewToFront(hitMeButton)
      
      navigationItem.leftBarButtonItem  = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAddress))
      navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(goToAddressList))
   }
   
   
   @IBAction func hitMePressed(_ sender: Any) {
      testDeployWithRemoteSigning()
      print("PRESSED")
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
