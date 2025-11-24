//
//  ProjectRolesViewController.swift
//  PMS
//
//  Created by SPSOFT on 13/02/25.
//
import UIKit

class ProjectRolesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {


    @IBOutlet weak var projectRoleTableView: UITableView!
    
    @IBOutlet weak var searchTextField: UITextField! {
    didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var selectedProjectRoleLabel: UILabel!
    
    var projectRoles: [ProjectRole] = []
    var filteredProjectRoles: [ProjectRole] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectRoleTableView.delegate = self
        projectRoleTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchProjectRoles()
    }
    
    @IBAction func addProjectRoleButton(_ sender: Any) {
  
   
        if let createProjectRolesVC = storyboard?.instantiateViewController(withIdentifier: "CreateProjectRoleViewController") {
            navigationController?.pushViewController(createProjectRolesVC, animated: true)
        }
        
        // Implement navigation to add role screen if needed
    }
    
    @IBAction func backToMenu(_ sender: Any) {
    navigationController?.popViewController(animated: true)
    }

    // MARK: - API Call to Fetch Project Roles
    func fetchProjectRoles() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/projectRoles", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch project roles.")
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    let projectRolesModel = try JSONDecoder().decode(ProjectRolesModel.self, from: responseData)
                    guard let result = projectRolesModel.result else {
                        self.displayAlert(title: "Error", message: "No project roles available.")
                        return
                    }
                    self.projectRoles = result
                    self.filteredProjectRoles = result
                    self.projectRoleTableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProjectRoles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectRoleCell", for: indexPath) as? projectRolesTableViewCell
        else{
            return UITableViewCell()
        }
        
        let role = filteredProjectRoles[indexPath.row]
//        cell.textLabel?.text = role.roleName
//        cell.textLabel?.text = role.roleDescription
        cell.configure(with: role)
//
        return cell
    }

    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRole = filteredProjectRoles[indexPath.row]
       // selectedProjectRoleLabel.text = selectedRole.roleName
    }

    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterProjectRoles(searchText: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func filterProjectRoles(searchText: String) {
        if searchText.isEmpty {
            filteredProjectRoles = projectRoles
        } else {
            filteredProjectRoles = projectRoles.filter { role in
                (role.roleName?.lowercased().contains(searchText.lowercased()) ?? false) ||
                (role.roleDescription?.lowercased().contains(searchText.lowercased()) ?? false)
            }
        }
        projectRoleTableView.reloadData()
    }

    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
