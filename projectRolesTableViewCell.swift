

import UIKit

class projectRolesTableViewCell: UITableViewCell {
    

    @IBOutlet weak var roleIdLabel: UILabel!
    
    @IBOutlet weak var roleNameLabel: UILabel!
    
    @IBOutlet weak var roleDescriptionLabel: UILabel!
    
    @IBOutlet weak var editButton: UIButton!
    
    @IBOutlet weak var toggleSwitch: UISwitch!
    
    func configure(with role: ProjectRole) {  // Use ProjectRole instead
        roleIdLabel.text = role.roleID
        roleNameLabel.text = role.roleName
        roleDescriptionLabel.text = role.roleDescription
        toggleSwitch.isOn = role.active ?? false  // Default to 'false' if 'active' is nil
    }
    

}
