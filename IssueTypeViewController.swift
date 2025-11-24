//
//  IssueTypeViewController.swift
//  PMS
//
//  Created by SPSOFT on 20/02/25.
//

import UIKit

class IssueTypeViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var issueTableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var selectedIssueLabel: UILabel!

    var issues: [IssueResult] = []
    var filteredIssues: [IssueResult] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        issueTableView.delegate = self
        issueTableView.dataSource = self
        searchTextField.delegate = self

        filteredIssues = issues
        fetchIssueTypes()
    }

    @IBAction func backButtonToMenu(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func fetchIssueTypes() {
        NetworkManager.shared.load(path: "api/issues", method: .get, params: [:]) { (data, error, response) in
            DispatchQueue.main.async {
                if response == true {
                    guard let responseData = data else {
                        self.showAlert(title: appTitle, message: "No response data received")
                        return
                    }
                    do {
                        let apiResponse = try JSONDecoder().decode(IssueTypeModel.self, from: responseData)
                        self.issues = apiResponse.result
                        self.filteredIssues = self.issues
                        self.issueTableView.reloadData()
                    } catch {
                        self.showAlert(title: appTitle, message: error.localizedDescription)
                    }
                } else {
                    self.showAlert(title: appTitle, message: "Network request failed.")
                }
            }
        }
    }

    // MARK: - TableView DataSource Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredIssues.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "IssueCell", for: indexPath) as? IssueTableViewCell else {
            return UITableViewCell()
        }

        let issue = filteredIssues[indexPath.row]
        cell.configure(with: issue)
        return cell
    }

    // MARK: - TableView Delegate Method for Cell Selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedIssue = filteredIssues[indexPath.row]
        selectedIssueLabel.text = "\(selectedIssue.issueID) - \(selectedIssue.issueType)"
    }

    // MARK: - Search Filtering with UITextField
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterIssues(searchText: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func filterIssues(searchText: String) {
        if searchText.isEmpty {
            filteredIssues = issues
        } else {
            filteredIssues = issues.filter { issue in
                issue.issueType.lowercased().contains(searchText.lowercased()) ||
                issue.issueDescription.lowercased().contains(searchText.lowercased())
            }
        }
        issueTableView.reloadData()
    }

    // MARK: - Utility Functions
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default))
        present(alertController, animated: true)
    }
}
