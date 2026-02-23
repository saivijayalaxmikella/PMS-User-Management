
import UIKit

class RolesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var rolesTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var selectedRoleLabel: UILabel!
    
    var roles: [RoleResult] = []
    var filteredRoles: [RoleResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        rolesTableView.delegate = self
        rolesTableView.dataSource = self
        searchTextField.delegate = self
        
        // Initialize filteredRoles with all roles
        filteredRoles = roles
        serviceForGetRoles()
    }
    
    @IBAction func backButtonToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    func serviceForGetRoles() {
        NetworkManager.shared.load(path: "api/roles", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.noActionAlertView(title: appTitle, message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(RolesModel.self, from: responseData)
                        if let roles = apiResponse.result {
                            self.roles = roles
                            self.filteredRoles = roles // Update filteredRoles with fetched roles
                            self.rolesTableView.reloadData() // Reload table view after data fetch
                        } else {
                            self.noActionAlertView(title: appTitle, message: "No roles found")
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

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredRoles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "RolesCell", for: indexPath) as? RolesTableViewCell else {
            return UITableViewCell()
        }
        
        let role = filteredRoles[indexPath.row]
        cell.configure(with: role)
        return cell
    }

    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRole = filteredRoles[indexPath.row]
        selectedRoleLabel.text = "\(selectedRole.roleID ?? "") \(selectedRole.roleName ?? "")"
    }

    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterRoles(searchText: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func filterRoles(searchText: String) {
        if searchText.isEmpty {
            filteredRoles = roles
        } else {
            filteredRoles = roles.filter { role in
                let roleName = role.roleName?.lowercased() ?? ""
                return roleName.contains(searchText.lowercased())
            }
        }
        rolesTableView.reloadData() // Correct reference to reload the data
    }

    // MARK: - Utility Functions
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
}

