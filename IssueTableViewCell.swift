//
//  IssueTableViewCell.swift
//  PMS
//
//  Created by SPSOFT on 21/07/25.
//

import UIKit

class IssueTableViewCell: UITableViewCell {


    @IBOutlet weak var issueTypeLabel: UILabel!
   
    @IBOutlet weak var issueDescriptionLabel: UILabel!
    
    func configure(with issue: IssueResult) {
        issueTypeLabel.text = issue.issueType
        issueDescriptionLabel.text = issue.issueDescription
        contentView.alpha = issue.active ? 1.0 : 0.5
    }
}
