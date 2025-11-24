//
//  TemplateTableViewCell.swift
//  PMS
//
//  Created by SPSOFT on 21/07/25.
//

import UIKit

class TemplateTableViewCell: UITableViewCell {

    @IBOutlet weak var templateNameLabel: UILabel!
    @IBOutlet weak var templateDescriptionLabel: UILabel!

    func configure(with template: TemplateItem) {
        templateNameLabel.text = template.templateName
        templateDescriptionLabel.text = template.templateDescription
        contentView.alpha = template.active ? 1.0 : 0.5
    }
}
