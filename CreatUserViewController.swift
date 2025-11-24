import UIKit

class CreateUserViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var workEmailTextField: UITextField!
    @IBOutlet weak var mobileNumberTextField: UITextField!
    @IBOutlet weak var employeeIDTextField: UITextField!
    @IBOutlet weak var designationTextField: UITextField!
    @IBOutlet weak var domainTextField: UITextField!
    @IBOutlet weak var experienceYearsTextField: UITextField!
    @IBOutlet weak var experienceMonthsTextField: UITextField!
    @IBOutlet weak var isManagerSwitch: UISwitch!
    
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        let textFields = [firstNameTextField, lastNameTextField, workEmailTextField, mobileNumberTextField, employeeIDTextField, designationTextField, domainTextField, experienceYearsTextField, experienceMonthsTextField]
        textFields.forEach { styleTextField($0) }
        
        styleButton(submitButton)
        styleButton(resetButton)
    }
    
    func styleTextField(_ textField: UITextField?) {
        guard let textField = textField else { return }
        textField.layer.borderColor = UIColor.lightGray.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8
        textField.setLeftPaddingPoints(10)
    }
    
    func styleButton(_ button: UIButton) {
        button.layer.cornerRadius = 8
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
    }
    
    // MARK: - IBActions
    @IBAction func handleSubmit(_ sender: UIButton) {
        serviceForCreateUser()
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        let textFields = [firstNameTextField, lastNameTextField, workEmailTextField, mobileNumberTextField, employeeIDTextField, designationTextField, domainTextField, experienceYearsTextField, experienceMonthsTextField]
        textFields.forEach { $0?.text = "" }
        isManagerSwitch.isOn = false
    }
    
    @IBAction func backToUser(_ sender: Any) {
        navigationController?.popViewController(animated: true)

        
    }
    
    // MARK: - API Calls
    func serviceForCreateUser() {
        self.view.endEditing(true)
        
        guard let firstName = firstNameTextField.text, !firstName.isEmpty,
              let lastName = lastNameTextField.text, !lastName.isEmpty,
              let email = workEmailTextField.text, !email.isEmpty,
              let mobileNumber = mobileNumberTextField.text, !mobileNumber.isEmpty,
              let employeeID = employeeIDTextField.text, !employeeID.isEmpty,
              let designation = designationTextField.text, !designation.isEmpty,
              let domain = domainTextField.text, !domain.isEmpty,
              let experienceYears = experienceYearsTextField.text, !experienceYears.isEmpty,
              let experienceMonths = experienceMonthsTextField.text, !experienceMonths.isEmpty
        else {
            self.noActionAlertView(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        let param: [String: Any] = [
            "firstName": firstName,
            "lastName": lastName,
            "emailId": email,
            "mobileNumber": mobileNumber,
            "employeeId": employeeID,
            "designation": designation,
            "domain": domain,
            "experience": "\(experienceYears).\(experienceMonths)",
            "isManager": false
        ]
//        print(param)
        
        NetworkManager.shared.load(path: "api/users", method: .post, params: param) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.noActionAlertView(title: "Error", message: "No response data received")
                        return
                    }
                    do {
//                        let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
//                        print(jsonData)
                        let apiResponse = try JSONDecoder().decode(CreateUserModel.self, from: responseData)
                        if apiResponse.statusCode == 200 {
                            self.singleActionAlertView(title: appTitle, message: apiResponse.result?.message ?? "") { (result) in
                                if result {
                                    let userViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "UserViewController") as? UserViewController
                                    self.navigationController?.pushViewController(userViewController!, animated: false)
                                }
                            }
                        } else {
                            self.noActionAlertView(title: "Error", message: apiResponse.result?.message ?? "An error occurred.")
                        }
                    } catch {
                        self.noActionAlertView(title: "Error", message: error.localizedDescription)
                    }
                } else {
                    self.noActionAlertView(title: "Error", message: "Network request failed.")
                }
            }
        }
    }
}

// MARK: - UITextField Padding Extension
extension UITextField {
    func setLeftPaddingPoints(_ amount: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

