//
//  MappingTableViewCell.swift
//  PMS
//
//  Created by SPSOFT on 18/02/25.
//
import UIKit

class MappingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var roleNameLabel: UILabel!
    @IBOutlet weak var permissionLabel: UILabel!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var popUpView: UIButton!
    
    func configure(with mappingResult: MappingResult) {
        roleNameLabel.text = mappingResult.roleName
        permissionLabel.text = mappingResult.permissions?.map { $0.permissionName ?? "" }.joined(separator: ", ") ?? "No permissions"
    }
}
