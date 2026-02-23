
import UIKit

class ProjectMappingTableViewCell: UITableViewCell {

    @IBOutlet weak var roleNameLabel: UILabel!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var popUpView: UIButton!
    
    func configure(with mappingResult: ProjectMappingResult) {
        roleNameLabel.text = mappingResult.roleName ?? "No role name"
        permissionLabel.text = mappingResult.permissions?.map { $0.permissionID ?? "" }.joined(separator: ", ") ?? "No permissions"
    }


}


