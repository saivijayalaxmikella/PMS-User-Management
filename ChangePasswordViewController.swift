//
//  ChangePasswordViewController.swift
//  PMS
//
//  Created by SPSOFT on 22/01/25.
//

import UIKit

class ChangePasswordViewController: UIViewController {

    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var newPassword: UITextField!
    
    @IBOutlet weak var confirmNewPassword: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func saveChanges(_ sender: Any) {
    }
    
   
}
