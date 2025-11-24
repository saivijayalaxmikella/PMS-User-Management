import UIKit

class UserViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    var selectedUserText: String?


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            // Set the magnifying glass icon to the left of the search text field
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var selectedUserLabel: UILabel! // Label for displaying selected user
    
    var users: [UserResult] = []
    var filteredUsers: [UserResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchUsers()
    }

    @IBAction func addUserButton(_ sender: Any) {
        if let createUserVC = storyboard?.instantiateViewController(withIdentifier: "CreateUserViewController") {
            navigationController?.pushViewController(createUserVC, animated: true)
        }
    }

    @IBAction func backToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - API Call to Fetch Users
    func fetchUsers() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/users", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch user data.")
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    let userModel = try JSONDecoder().decode(UserModel.self, from: responseData)
                    guard let result = userModel.result else {
                        self.displayAlert(title: "Error", message: "No user data available.")
                        return
                    }
                    self.users = result
                    self.filteredUsers = result
                    self.tableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath) as? UserTableViewCell else {
            return UITableViewCell()
        }
        
        let user = filteredUsers[indexPath.row]
        cell.configure(with: user)
        return cell
    }

    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedUser = filteredUsers[indexPath.row]
        selectedUserLabel.text = "\(selectedUser.firstName ?? "") \(selectedUser.lastName ?? "")"
    }

    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterUsers(searchText: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func filterUsers(searchText: String) {
        if searchText.isEmpty {
            filteredUsers = users
        } else {
            filteredUsers = users.filter { user in
                let fullName = "\(user.firstName ?? "") \(user.lastName ?? "")".lowercased()
                return fullName.contains(searchText.lowercased()) ||
                       (user.emailID?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        tableView.reloadData()
    }

    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) { // Renamed from showAlert to displayAlert
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
