
import UIKit

class PermissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var permissionTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    @IBOutlet weak var selectedPermissionLabel: UILabel!
    
    var permissions: [Permission] = []
    var filteredPermissions: [Permission] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        
        permissionTableView.delegate = self
        permissionTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchPermissions()
    }
    
    @IBAction func addPermissionButton(_ sender: Any) {
        if let createUserVC = storyboard?.instantiateViewController(withIdentifier: "CreatePermissionViewController") {
            navigationController?.pushViewController(createUserVC, animated: true)
        }
        // Implement add permission functionality
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Call to Fetch Permissions
    func fetchPermissions() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/rolePermissions", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch permission data.")
                    return
                }
                do {
                    let permissionModel = try JSONDecoder().decode(PermissionModel.self, from: responseData)
                    guard let result = permissionModel.result else {
                        self.displayAlert(title: "Error", message: "No permission data available.")
                        return
                    }
                    
                    self.permissions = result.flatMap { $0.permissions ?? [] }
                    self.filteredPermissions = self.permissions
                    self.permissionTableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredPermissions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "PermissionCell", for: indexPath) as? PermissionTableViewCell else {
            return UITableViewCell()
        }
        
        let permission = filteredPermissions[indexPath.row]
        cell.configure(with: permission)
        return cell
    }
    
    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPermission = filteredPermissions[indexPath.row]
        selectedPermissionLabel.text = selectedPermission.permissionName
    }
    
    // MARK: - Search Filtering with UITextField
    var allPermissions: [String] = ["Camera Access", "Location Services", "Contacts", "Microphone", "Photos"]

    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterPermissions(searchText: searchText)
    }

    func filterPermissions(searchText: String) {
        let filtered = allPermissions.filter { permission in
            permission.localizedCaseInsensitiveContains(searchText)
        }
        print("Filtered Permissions: \(filtered)")
    }

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
//    func filterPermissions(searchText: String) {
//        if searchText.isEmpty {
//            filteredPermissions = permissions
//        } else {
//            filteredPermissions = permissions.filter { permission in
//                return permission.permissionName?.lowercased().contains(searchText.lowercased()) ?? false
//            }
//        }
//        permissionTableView.reloadData()
//    }
    
    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
