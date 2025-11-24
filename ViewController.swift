//
//  ViewController.swift
//  PMS
//
//  Created by spsoft on 20/01/25.
//
import UIKit
import MBProgressHUD


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailTxtField: UITextField! {
        didSet {
            self.emailTxtField.setLeftView()  // This will be triggered when emailTxtField is set.
        }
    }
    override func viewDidLoad() {
           super.viewDidLoad()
           self.navigationController?.setNavigationBarHidden(true, animated: false)
       }
       
       func textFieldShouldReturn(_ textField: UITextField) -> Bool {
           textField.resignFirstResponder()
           return true
       }
    
    
    
    
    
    
    @IBAction func continueActionButton(_ sender: Any) {
        guard let email = emailTxtField.text, !email.isEmpty else {
                    self.noActionAlertView(title: appTitle, message: "Please enter email address")
                    return
                }

                if email.isValidEmail == false {
                    self.noActionAlertView(title: appTitle, message: "Please enter a valid email address")
                } else {
                    let reachability = Reachability() // Network reachability object
                    if reachability?.connection == .wifi || reachability?.connection == .cellular {
                        self.navigateToPasswordLoginVC(withEmail: email)
                    } else {
                        self.noActionAlertView(title: appTitle, message: noInternetMessage)
                    }
                }
            }
            
            private func navigateToPasswordLoginVC(withEmail email: String) {
                // Instantiate PasswordLoginViewController and pass the email
                if let passwordLoginVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PasswordLoginViewController") as? PasswordLoginViewController {
                    passwordLoginVC.email = email
                    self.navigationController?.pushViewController(passwordLoginVC, animated: true)
                } else {
                    self.noActionAlertView(title: appTitle, message: "Failed to load the Password Login screen.")
                }
            }
        }

        extension UITextField {
            func setLeftView() {
                let iconContainerView: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                leftView = iconContainerView
                leftViewMode = .always
            }
        }

        extension String {
            var isValidEmail: Bool {
                NSPredicate(format: "SELF MATCHES %@", "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}").evaluate(with: self)
            }
        }
