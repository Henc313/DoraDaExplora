//let geth_url = "http://206.45.86.254:80"

import UIKit
import SVProgressHUD

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CanReceiveAddress {
   
   var wallet   = "0xbcef3088c414d25da1bde04775d484177f9326cb"
   var numberFormatter: NumberFormatter?
   var addressList = [String]()
   var walletData = WalletData()
   let defaults = UserDefaults.standard
   var savedWallets = [String]()
   let detailTableViewController = DetailTableViewController()
   
   let addressListVC = AddressListTableViewController()
   var selectedWallet = ""
   
   enum CardState {
      case expanded
      case collapsed
   }
   
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
   
   @IBOutlet var cardView: UIView!
   @IBOutlet var hitMeButton: UIButton!
   @IBOutlet var balanceLabel: UILabel!
   @IBOutlet var handleArea: UIView!
   @IBOutlet var handlebar: UIImageView!
   @IBOutlet var savedListTableView: UITableView!
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      savedWallets = defaults.object(forKey: "savedWallets") as? [String] ?? [String]()
      setupCard()
      setUpButton()
      
      guard let walletList = defaults.object(forKey: "savedWallets") as? [String] else { return }
      savedWallets = walletList
      
      
      
      navigationItem.leftBarButtonItem   = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewAddress))
      navigationItem.rightBarButtonItems = [UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(goToAddressList)),
                                            UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(makeTabTransparent))]
   }
   
   
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
      handleArea.backgroundColor = #colorLiteral(red: 0.921431005, green: 0.9214526415, blue: 0.9214410186, alpha: 1)
      handleArea.alpha = 0.90
      handlebar.alpha = 0.90
      cardView.backgroundColor = .clear
      
      view.backgroundColor = #colorLiteral(red: 0.4620226622, green: 0.8382837176, blue: 1, alpha: 1)
   }
   
   
   @objc func handleCardTap(recognizer: UITapGestureRecognizer) {
      switch recognizer.state {
      case .ended:
         animateTransitionIfNeeded(state: nextState, duration: 0.9)
      default:
         break
      }
   }
   
   
   //MARK: - Adapt to UIView
   @objc func handleCardPan(recognizer: UIPanGestureRecognizer) {
      switch recognizer.state {
      case .began:
         startInteractiveTransition(state: nextState, duration: 0.9)
      case .changed:
         let translation = recognizer.translation(in: handleArea)
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
   
   //MARK: - TableView Delegate Methods
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
