//
//  UserTableViewCell.swift
//  PMS
//
//  Created by SPSOFT on 12/02/25.
//
import UIKit

class UserTableViewCell: UITableViewCell {
    @IBOutlet weak var employeeIdLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var domainLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var toggleSwitch: UISwitch!

    func configure(with user: UserResult) {  // Updated the type to UserResult
        employeeIdLabel.text = user.employeeID
        firstNameLabel.text = user.firstName
        lastNameLabel.text = user.lastName
        emailLabel.text = user.emailID
        roleLabel.text = user.role?.rawValue
        domainLabel.text = user.domain
        toggleSwitch.isOn = user.active ?? false  // Default to 'false' if 'active' is nil
    }
}
