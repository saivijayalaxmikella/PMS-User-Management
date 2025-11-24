//
import UIKit

class MappingViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    @IBOutlet weak var mappingTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
        }
    }
    
    @IBOutlet weak var selectedMappingLabel: UILabel!
    
    var mappings: [MappingResult] = []
    var filteredMappings: [MappingResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mappingTableView.delegate = self
        mappingTableView.dataSource = self
        searchTextField.delegate = self
        
        searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        
        fetchMappings()
    }
    
    @IBAction func addMappingButton(_ sender: Any) {
        // Handle add mapping action
    }
    
    @IBAction func backToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - API Call to Fetch Mappings
    func fetchMappings() {
        self.view.endEditing(true)
        
        NetworkManager.shared.load(path: "api/rolePermissions", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                guard let response = response, response, let responseData = data else {
                    self.displayAlert(title: "Error", message: "Failed to fetch mapping data.")
                    return
                }
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers)
                    print(jsonData)
                    let mappingModel = try JSONDecoder().decode(MappingModel.self, from: responseData)
                    guard let result = mappingModel.result else {
                        self.displayAlert(title: "Error", message: "No mapping data available.")
                        return
                    }
                    self.mappings = result
                    self.filteredMappings = result
                    self.mappingTableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredMappings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MappingCell", for: indexPath) as? MappingTableViewCell else {
            return UITableViewCell()
        }
        
        let mapping = filteredMappings[indexPath.row]
        cell.configure(with: mapping)
        return cell
    }
    
    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedMapping = filteredMappings[indexPath.row]
        selectedMappingLabel.text = selectedMapping.roleName ?? ""
    }
    
    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterMappings(searchText: searchText)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func filterMappings(searchText: String) {
        if searchText.isEmpty {
            filteredMappings = mappings
        } else {
            filteredMappings = mappings.filter { mapping in
                return mapping.roleName?.lowercased().contains(searchText.lowercased()) ?? false
            }
        }
        mappingTableView.reloadData()
    }
    
    // MARK: - Utility Functions
    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
