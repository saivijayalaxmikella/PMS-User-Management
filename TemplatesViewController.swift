//
//  TemplatesViewController.swift
//  PMS
//
//  Created by SPSOFT on 20/02/25.
//
import UIKit

class TemplatesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchTextField: UITextField! {
        didSet {
            let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
            searchIcon.tintColor = .gray
            searchTextField.leftView = searchIcon
            searchTextField.leftViewMode = .always
            searchTextField.delegate = self
            searchTextField.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        }
    }

    var templates: [TemplateItem] = []
    var filteredTemplates: [TemplateItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        fetchTemplates()
    }

    func fetchTemplates() {
        self.view.endEditing(true)

        NetworkManager.shared.load(path: "api/templates", method: .get, params: [:]) { data, error, response in
            DispatchQueue.main.async {
                guard let responseData = data, error == nil else {
                    self.displayAlert(title: "Error", message: "Failed to fetch templates.")
                    return
                }
                do {
                    let templatesModel = try JSONDecoder().decode(TemplatesModel.self, from: responseData)
                    self.templates = templatesModel.result
                    self.filteredTemplates = self.templates
                    self.tableView.reloadData()
                } catch {
                    self.displayAlert(title: "Error", message: "Failed to decode response: \(error.localizedDescription)")
                }
            }
        }
    }

    // MARK: - TableView DataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredTemplates.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "TemplateCell", for: indexPath) as? TemplateTableViewCell else {
            return UITableViewCell()
        }
        let template = filteredTemplates[indexPath.row]
        cell.configure(with: template)
        return cell
    }

    // MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedTemplate = filteredTemplates[indexPath.row]
        print("Selected template: \(selectedTemplate.templateName)")
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK: - Search Filtering
    @objc func textFieldDidChange(_ sender: UITextField) {
        let searchText = sender.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        filterTemplates(searchText: searchText)
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func filterTemplates(searchText: String) {
        if searchText.isEmpty {
            filteredTemplates = templates
        } else {
            filteredTemplates = templates.filter { template in
                template.templateName.lowercased().contains(searchText.lowercased()) ||
                template.templateDescription.lowercased().contains(searchText.lowercased())
            }
        }
        tableView.reloadData()
    }

    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

