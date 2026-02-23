
import UIKit

class RolesTableViewCell: UITableViewCell {

    @IBOutlet weak var roleIdLabel: UILabel!
    @IBOutlet weak var roleNameLabel: UILabel!
    @IBOutlet weak var roleDescription: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    @IBOutlet weak var editButton: UIButton!

    func configure(with role: RoleResult) {
        roleIdLabel.text = role.roleID
        roleNameLabel.text = role.roleName
        roleDescription.text = role.roleDescription
        toggleSwitch.isOn = role.active ?? false  // Default to 'false' if 'active' is nil
    }
}

