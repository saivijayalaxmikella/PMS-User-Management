
import UIKit

class CreateProjectRoleViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var rolesName: UITextField!
    @IBOutlet weak var rolesDescription: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        let textFields = [rolesName, rolesDescription]
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
        serviceForCreateProjectRole()
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        rolesName.text = ""
        rolesDescription.text = ""
    }
    
    @IBAction func backToProjectRolesPermisison(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
  
        // MARK: - API Calls
    func serviceForCreateProjectRole() {
        self.view.endEditing(true)
        
        guard let roleName = rolesName.text, !roleName.isEmpty,
              let roleDescription = rolesDescription.text, !roleDescription.isEmpty
        else {
            self.noActionAlertView(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        let param: [String: Any] = [
            "roleName": roleName,
            "roleDescription": roleDescription
        ]
        
        NetworkManager.shared.load(path: "api/projectRoles", method: .post, params: param) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.noActionAlertView(title: "Error", message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(CreateProjectRolesModel.self, from: responseData)
                        if apiResponse.statusCode == 200 {
                            self.singleActionAlertView(title: appTitle, message: apiResponse.result?.message ?? "") { (result) in
                                if result {
                                    let projectRolesViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectRolesViewController") as? ProjectRolesViewController
                                    self.navigationController?.pushViewController(projectRolesViewController!, animated: false)
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

