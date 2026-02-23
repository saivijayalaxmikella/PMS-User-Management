

import UIKit

class ProjectMappingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var projectMappingTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    @IBOutlet weak var selectedProjectMappingLabel: UILabel!
    
    var projectMappings: [ProjectMappingResult] = []
    var filteredProjectMappings: [ProjectMappingResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        projectMappingTableView.delegate = self
        projectMappingTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchProjectMappings()
    }
    
    @IBAction func addProjectMappingButton(_ sender: Any) {
        if let createProjectMappingVC = storyboard?.instantiateViewController(withIdentifier: "CreateProjectMappingViewController") {
            navigationController?.pushViewController(createProjectMappingVC, animated: true)
        }
    }
    
    // MARK: - API Call to Fetch Project Mappings
    func fetchProjectMappings() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/projectRolePermissions", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch project mapping data.")
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    let projectMappingModel = try JSONDecoder().decode(ProjectMappingModel.self, from: responseData)
                    guard let result = projectMappingModel.result else {
                        self.displayAlert(title: "Error", message: "No project mapping data available.")
                        return
                    }
                    self.projectMappings = result
                    self.filteredProjectMappings = result
                    self.projectMappingTableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)" )
                }
            }
        }
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredProjectMappings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ProjectMappingCell", for: indexPath) as? ProjectMappingTableViewCell else{
            return UITableViewCell()
        }
        let project = filteredProjectMappings[indexPath.row]
        cell.configure(with: project)

        return cell
    }
    
    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedProject = filteredProjectMappings[indexPath.row]
        selectedProjectMappingLabel.text = selectedProject.roleName ?? ""
    }
    
    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterProjectMappings(searchText: searchText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func filterProjectMappings(searchText: String) {
        if searchText.isEmpty {
            filteredProjectMappings = projectMappings
        } else {
            filteredProjectMappings = projectMappings.filter { project in
                return project.roleName?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        projectMappingTableView.reloadData()
    }
    
    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
