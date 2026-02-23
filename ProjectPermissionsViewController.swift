
import UIKit

class ProjectPermissionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var projectPermissionsTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    @IBOutlet weak var selectedProjectPermissionsLabel: UILabel!
    
    var permissions: [Results] = []
    var filteredPermissions: [Results] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectPermissionsTableView.delegate = self
        projectPermissionsTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchProjectPermissions()
    }
    
    @IBAction func addProjectPermissionsButton(_ sender: Any) {
        if let createProjectPermissionsrVC = storyboard?.instantiateViewController(withIdentifier: "CreateProjectPermissionsViewController") {
            navigationController?.pushViewController(createProjectPermissionsrVC, animated: true)
        }
        // Handle add permissions action
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Call to Fetch Permissions
    func fetchProjectPermissions() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/projectPermissions", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch permissions data.")
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    let permissionsModel = try JSONDecoder().decode(ProjectPermissionsModel.self, from: responseData)
                    guard let result = permissionsModel.result else {
                        self.displayAlert(title: "Error", message: "No permissions data available.")
                        return
                    }
                    self.permissions = result
                    self.filteredPermissions = result
                    self.projectPermissionsTableView.reloadData()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectPermissionCell", for: indexPath) as? ProjectPermissionsTableViewCell else {
            return UITableViewCell()
        }
        
        let permission = filteredPermissions[indexPath.row]
        cell.configure(with: permission)
        return cell
    }
    
    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedPermission = filteredPermissions[indexPath.row]
        selectedProjectPermissionsLabel.text = selectedPermission.permissionName
    }
    
    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterPermissions(searchText: searchText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func filterPermissions(searchText: String) {
        if searchText.isEmpty {
            filteredPermissions = permissions
        } else {
            filteredPermissions = permissions.filter { permission in
                return permission.permissionName?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        projectPermissionsTableView.reloadData()
    }
    
    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
