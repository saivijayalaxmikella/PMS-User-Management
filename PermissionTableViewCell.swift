
import UIKit

class PermissionTableViewCell: UITableViewCell {
    
    @IBOutlet weak var permissionIdLabel: UILabel!
    @IBOutlet weak var permissionNameLabel: UILabel!
    @IBOutlet weak var permissionDescriptionLabel: UILabel!
    @IBOutlet weak var permissionTypeLabel: UILabel!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func configure(with permission: Permission) {
        permissionIdLabel.text = permission.permissionID
        permissionNameLabel.text = permission.permissionName
        permissionDescriptionLabel.text = permission.permissionDescription
        permissionTypeLabel.text = permission.permissionType?.rawValue
        toggleSwitch.isOn = permission.active ?? false  // Default to 'false' if 'active' is nil
    }
}
