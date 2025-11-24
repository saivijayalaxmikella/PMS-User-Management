//
//  CreateProjectPermissionsViewController.swift
//  PMS
//
//  Created by SPSOFT on 20/02/25.
//

import UIKit

class CreateProjectPermissionsViewController: UIViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var permissionNameTextField: UITextField!
    
    @IBOutlet weak var permissionDescriptionTextField: UITextField!
    @IBOutlet weak var permissionTypeTextField: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setup
    func setupUI() {
        let textFields = [permissionNameTextField, permissionDescriptionTextField, permissionTypeTextField]
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
        serviceForCreateProjectPermission()
    }
    
    @IBAction func handleReset(_ sender: UIButton) {
        let textFields = [permissionNameTextField, permissionDescriptionTextField, permissionTypeTextField]
        textFields.forEach { $0?.text = "" }
    }
    
    @IBAction func backToPermissionsList(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Calls
    func serviceForCreateProjectPermission() {
        self.view.endEditing(true)
        
        guard let permissionName = permissionNameTextField.text, !permissionName.isEmpty,
              let permissionDescription = permissionDescriptionTextField.text, !permissionDescription.isEmpty,
              let permissionType = permissionTypeTextField.text, !permissionType.isEmpty
        else {
            self.noActionAlertView(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        let param: [String: Any] = [
            "permissionName": permissionName,
            "permissionDescription": permissionDescription,
            "permissionType": permissionType
        ]
        
        NetworkManager.shared.load(path: "api/projectPermissions", method: .post, params: param) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.noActionAlertView(title: "Error", message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(CreateProjectPermissionsModel.self, from: responseData)
                        if apiResponse.statusCode == 200 {
                            self.singleActionAlertView(title: "Success", message: apiResponse.result?.message ?? "") { (result) in
                                if result {
                                    let projectPermissionsViewController = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "ProjectPermissionsViewController") as? ProjectPermissionsViewController
                                    self.navigationController?.pushViewController(projectPermissionsViewController!, animated: false)
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

