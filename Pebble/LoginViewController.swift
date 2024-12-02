//
//  LoginViewController.swift
//  Pebble
//
//  Created by Eddy Mercado on 10/21/24.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseFirestore

let db = Firestore.firestore()

class LoginViewController: UIViewController, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        nameField.delegate = self
        passwordField.isSecureTextEntry = true
        passwordField.enablePasswordToggle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Ensure any subsequent navigations use fullScreen when coming back
        self.navigationController?.modalPresentationStyle = .fullScreen
        
        // Clear the text fields when the view appears
        usernameField.text = ""
        passwordField.text = ""
    }

    @IBAction func loginButton(_ sender: Any) {
        // if username is valid login/ segue to browse events
        guard let email = usernameField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            showAlert(title: "Please enter both email and password", message: "")
            return
        }
        
        Auth.auth().signIn(withEmail: usernameField.text!, password: passwordField.text!) {
            (authResult, error) in
            DispatchQueue.main.async {
                if (error as NSError?) != nil {
                    self.showAlert(title: "Email or Password is incorrect", message: "Retry credentials or create an account!")
                    return
                } else {
//                    self.performSegue(withIdentifier: "startUpToBrowseEventsPage", sender: self)
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let segueVC = storyboard.instantiateViewController(withIdentifier: "TabBarViewController") as? UITabBarController {
                        segueVC.modalPresentationStyle = .fullScreen
                        self.present(segueVC, animated: true, completion: nil)
                    }
                }
            }
        }
    }
    
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func signUpButton(_ sender: Any) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil) // Assuming SignUpViewController is in Main storyboard
    }
    
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // Called when the user clicks on the view outside of the UITextField

    open override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension UITextField {
    fileprivate func setPasswordToggleImage(_ button: UIButton) {
        if(!isSecureTextEntry){
            button.setImage(UIImage(named: "eye"), for: .normal)
        } else {
            button.setImage(UIImage(named: "hidden"), for: .normal)
        }
    }
    
    func enablePasswordToggle(){
        let button = UIButton(type: .custom)
        setPasswordToggleImage(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(button)
        NSLayoutConstraint.activate([
            button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            button.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 25),
            button.heightAnchor.constraint(equalToConstant: 25)
        ])
        
        button.addTarget(self, action: #selector(self.togglePasswordView), for: .touchUpInside)
    }
    

    
    @IBAction func togglePasswordView(_ sender: Any) {
        self.isSecureTextEntry = !self.isSecureTextEntry
        setPasswordToggleImage(sender as! UIButton)
    }
}
