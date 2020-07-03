//
//  RegisterViewController.swift
//  Flash Chat
//
//  This is the View Controller which registers new users with Firebase
//

import UIKit
import Firebase
import SVProgressHUD

class RegisterViewController: UIViewController {

    
    //Pre-linked IBOutlets

    @IBOutlet var emailTextfield: UITextField!
    @IBOutlet var passwordTextfield: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

  
    @IBAction func registerPressed(_ sender: UIButton) {

        SVProgressHUD.show()
        
        //Set up a new user on the Firbase database
        Auth.auth().createUser(withEmail: emailTextfield.text!, password: passwordTextfield.text!) {
            (user, error) in //where a closure starts - closure is anonymous function
            
            if error != nil {
                print(error!)
            }else{
                print("Registration successful!") //password length >= 6 characters
                SVProgressHUD.dismiss()
                
                //go to chat screen after registration
                self.performSegue(withIdentifier: "goToChat", sender: self)
            }
        }
    }
    
}
