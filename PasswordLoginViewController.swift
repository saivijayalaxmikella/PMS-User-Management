
import UIKit
import JWTDecode

class PasswordLoginViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var userLabel: UILabel!
    
    @IBOutlet weak var passwordTxtField: UITextField!{
        didSet{
            self.passwordTxtField.setLeftView()
        }
    }
    var email: String?
    
    
    
    @IBOutlet weak var checkMark: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the email label
        if let email = email {
            userLabel.text = email
        }
    }
    
    @IBAction func txtpassword(_ sender: Any) {
    }
    var isPasswordHidden = true
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func editButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: false)
    }
    
    @IBAction func PaswordHideShow(_ sender: Any) {
        isPasswordHidden.toggle()
        
        // Change the secure text entry property
        passwordTxtField.isSecureTextEntry = isPasswordHidden
        
        // Optionally, update the button's image (if using eye icons for visibility)
        let imageName = isPasswordHidden ? "eye_closed" : "eye_open"  // Set your own images for this
        checkMark.setImage(UIImage(named: imageName), for: .normal)
    }
    
    
    @IBAction func cantLoginButton(_ sender: Any) {
        let cantLoginViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cantLoginViewController")
        
        // If you have a navigation controller, push the view controller
        self.navigationController?.pushViewController(cantLoginViewController, animated: true)
    }
    
    
    @IBAction func continueButton(_ sender: Any) {
        if let password = passwordTxtField.text, password.isEmpty {
            self.noActionAlertView(title: appTitle, message: "Please enter password")
        } else {
            // Continue with login using email and password
            self.serviceForLogin()
        }
    }
    func serviceForLogin() {
        self.view.endEditing(true)
        
        let param = ["emailId": userLabel.text!, "password": self.passwordTxtField.text!]
        NetworkManager.shared.load(path: "auth/login", method: .post, params: param) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.noActionAlertView(title: appTitle, message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(LoginModel.self, from: responseData)
                        if apiResponse.statusCode == 200 {
                            guard let result = apiResponse.result else {
                                self.noActionAlertView(title: appTitle, message: "Result is nil")
                                return
                            }
                            
                            let jwt = try decode(jwt: result.token ?? "")
                            
                            Appstorage.UserToken = result.token ?? ""
                            Appstorage.UserID = "\(result.userId ?? 0)"
                            Appstorage.UserFullName = (result.firstName ?? "") + " " + (result.lastName ?? "")
                            Appstorage.UserEmail = result.emailId
                            Appstorage.UserPhoneNumber = result.mobileNumber
                            Appstorage.UserCountry = result.country ?? ""
                           // Appstorage.UserCountryCode = result.countryCode ?? ""
                            
                            let MenuViewController = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController
                            self.navigationController?.pushViewController(MenuViewController!, animated: false)
                        } else {
                            // Use the message from the LoginModel for error feedback
                            self.noActionAlertView(title: appTitle, message: apiResponse.message ?? "An error occurred.")
                        }
                        
                    } catch {
                        self.noActionAlertView(title: appTitle, message: error.localizedDescription)
                    }
                } else {
                    self.noActionAlertView(title: appTitle, message: "Network request failed.")
                }
            }
        }
    }
}
