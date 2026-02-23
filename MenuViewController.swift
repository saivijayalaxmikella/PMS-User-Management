
import UIKit

class MenuViewController: UIViewController {

    let sections = ["Dashboard", "User Management", "Project Management", "Settings"]
    let sectionData = [
        [("Dashboard", "Go to Dashboard", "dash-Setting", "DashboardViewController")],
        [
            ("User", "User Settings", "users", "UserViewController"),
            ("Roles", "Manage Roles", "Roles Data", "RolesViewController"),
            ("Permissions", "Manage Permissions", "Permissions Data", "PermissionsViewController"),
            ("Mapping", "Manage Mappings", "Mapping Data", "MappingViewController")
        ],
        [
            ("Project Roles", "Manage Project Roles", "proles", "ProjectRolesViewController"),
            ("Project Permissions", "Manage Permissions", "ppermissions", "ProjectPermissionsViewController"),
            ("Project Mapping", "Map Projects", "pmapping", "ProjectMappingViewController"),
            ("Template", "Manage Templates", "templates", "TemplateViewController"),
            ("Issue Types", "Manage Issues", "issuestype", "IssueTypesViewController"),
            ("Work Flow", "Define Work Flow", "workflow", "WorkflowViewController"),
            ("Priorities", "Set Priorities", "priorities", "PrioritiesViewController"),
            ("Team", "Manage Teams", "pteams", "TeamViewController"),
            ("Project", "Project Overview", "project", "ProjectViewController")
        ],
        [
            ("Profile Settings", "Edit Profile", "dash-Setting", "ProfileSettingsViewController"),
            ("Logout", "Logout of Account", "logout", "LogoutViewController")
        ]
    ]

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerImageView: UIView!
    
    var expandedSections = [false, false, false, false]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
}

extension MenuViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandedSections[section] ? sectionData[section].count : 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = UITableViewHeaderFooterView()
        header.textLabel?.text = sections[section]
        header.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleSection(_:))))
        header.tag = section
        return header
    }
    
    @objc func toggleSection(_ sender: UITapGestureRecognizer) {
        guard let section = sender.view?.tag else { return }
        expandedSections[section].toggle()
        tableView.reloadSections(IndexSet(integer: section), with: .automatic)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let item = sectionData[indexPath.section][indexPath.row]
        cell.textLabel?.text = item.0
        cell.imageView?.image = UIImage(named: item.2)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedItem = sectionData[indexPath.section][indexPath.row]
        let storyboardID = selectedItem.3

        if let viewController = storyboard?.instantiateViewController(withIdentifier: storyboardID) {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}
