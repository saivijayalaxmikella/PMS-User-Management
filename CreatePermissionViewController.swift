//
//  CreatePermissionViewController.swift
//  PMS
//
//  Created by SPSOFT on 12/02/25.
//

import UIKit

class CreatePermissionViewController: UIViewController {
    
    @IBOutlet weak var permissionName: UITextField!
    @IBOutlet weak var permissionDescription: UITextField!
    @IBOutlet weak var permissionType: UITextField!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func submitButtonTapped(_ sender: Any) {
        serviceForCreatePermission()
    }
    
    @IBAction func resetButtonTapped(_ sender: Any) {
        permissionName.text = ""
        permissionDescription.text = ""
        permissionType.text = ""
    }
    
    @IBAction func backToPermission(_ sender: Any) {
        navigationController?.popViewController(animated: true)

    }
    func serviceForCreatePermission() {
        self.view.endEditing(true)
        
        guard let name = permissionName.text, !name.isEmpty,
              let description = permissionDescription.text, !description.isEmpty,
              let type = permissionType.text, !type.isEmpty else {
            showAlert(title: "Error", message: "Please fill in all fields.")
            return
        }
        
        let param: [String: Any] = [
            "name": name,
            "description": description,
            "type": type
        ]
        
        NetworkManager.shared.load(path: "api/permissions", method: .post, params: param) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.showAlert(title: "Error", message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(CreatePermissionModel.self, from: responseData)
                        if apiResponse.statusCode == 200 {
                            self.showAlert(title: "Success", message: apiResponse.result?.message ?? "") { _ in
                                if let permissionListVC = UIStoryboard(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "PermissionListViewController") as? UIViewController {
                                    self.navigationController?.pushViewController(permissionListVC, animated: false)
                                } else {
                                    self.showAlert(title: "Error", message: "Failed to load PermissionListViewController.")
                                }
                            }
                        } else {
                            self.showAlert(title: "Error", message: apiResponse.result?.message ?? "An error occurred.")
                        }
                    } catch {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                    }
                } else {
                    self.showAlert(title: "Error", message: "Network request failed.")
                }
            }
        }
    }
    
    func showAlert(title: String, message: String, completion: ((Bool) -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completion?(true)
        })
        present(alert, animated: true, completion: nil)
    }
}
