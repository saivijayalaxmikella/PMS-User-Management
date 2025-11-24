//
//  cantLoginViewController.swift
//  PMS
//
//  Created by SPSOFT on 21/01/25.
//

import UIKit

class cantLoginViewController: UIViewController {
  
    @IBOutlet weak var email: UITextField!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Additional setup if necessary
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func continueButton(_ sender: Any) {
   
    // Check email validity only
        if self.email.text?.count == 0 || self.email.text == "" {
            self.noActionAlertView(title: appTitle, message: "Please enter an email address")
        } else if self.email.text?.isValidEmail == false {
            self.noActionAlertView(title: appTitle, message: "Please enter a valid email address")
        } else {
            let reachability = Reachability() // Network reachability object
            if reachability?.connection == .wifi || reachability?.connection == .cellular {
                self.serviceForEmailRequest() // Call the service for email request
            } else {
                self.noActionAlertView(title: appTitle, message: noInternetMessage)
            }
        }
    }
//
//    func startProgressHUD() {
//        // Display HUD right before the request is made
//        let spinningActivity = MBProgressHUD.showAdded(to: self.view, animated: true)
//        spinningActivity.bezelView.color = UIColor(named: "ButtonBackgroundColor") // Your backgroundcolor
//        spinningActivity.bezelView.style = .solidColor // Bezel view style to solid color.
//        spinningActivity.contentColor = UIColor(named: "ButtonTitleColor")
//    }
//
//    func stopProgressHUD() {
//        // Hide HUD once the network request comes back (must be done on main UI thread)
//        MBProgressHUD.hide(for: self.view, animated: true)
//    }
//
    func serviceForEmailRequest() {
        self.view.endEditing(true)
//        self.startProgressHUD()
        
        let param = ["email": self.email.text!] // Only send the email parameter
        NetworkManager.shared.load(path: "api/passwords/forgot", method: .post, params: param) { (data, error, response) in
            
            if response! {
                guard let responseData = data else {
                    return
                }
                do {
                    let apiResponse = try JSONDecoder().decode(LoginModel.self, from: responseData)
                    DispatchQueue.main.async {
                        if apiResponse.statusCode == 200 {
                            // Handle success and response data if required
                            self.noActionAlertView(title: appTitle, message: "Email request successful")
                            let passwordLoginViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PasswordLoginViewController") as? PasswordLoginViewController
                            self.navigationController?.pushViewController(passwordLoginViewController!, animated: false)
                            
                            
                        } else {
                            self.noActionAlertView(title: appTitle, message: apiResponse.message ?? "")
                        }
//                        self.stopProgressHUD()
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.noActionAlertView(title: appTitle, message: error.localizedDescription)
//                        self.stopProgressHUD()
                    }
                }
            }
        }
    }
}
