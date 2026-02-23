

import UIKit

class ProjectPermissionsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var permissionId: UILabel!
    @IBOutlet weak var permissionName: UILabel!
    @IBOutlet weak var permissionDescription: UILabel!
    @IBOutlet weak var permissionType: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func configure(with permission: Results) {  // ✅ Use Results instead
        permissionId.text = permission.permissionID
        permissionName.text = permission.permissionName
        permissionDescription.text = permission.permissionDescription
        permissionType.text = permission.permissionType?.rawValue
        toggleSwitch.isOn = permission.active ?? false
    }
}
