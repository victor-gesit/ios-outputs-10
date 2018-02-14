import UIKit


// Keychain Configuration
struct KeychainConfiguration {
    static let serviceName = "iOSDevs"
    static let accessGroup: String? = nil
}

class AuthViewController: UIViewController {
    @IBOutlet weak var loginButton: UIButton!
    let username = "iosdevs"
    let password = "andela"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var authSwitch: UISwitch!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var touchIDButton: UIButton!
    let touchMe = BiometricIDAuth()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let hasLogin = UserDefaults.standard.bool(forKey: "hasLoginKey")
        if hasLogin {
            loginButton.setTitle("Log in", for: .normal)
            authSwitch.setOn(false, animated: true)
        } else {
            loginButton.setTitle("Sign Up", for: .normal)
            authSwitch.setOn(true, animated: true)
        }
        
        // 3
        if let storedUsername = UserDefaults.standard.value(forKey: "username") as? String {
            usernameTextField.text = storedUsername
        }
        
        touchIDButton.isHidden = !touchMe.canEvaluatePolicy()
    }
    
//    @IBAction func loginButtonTap(_ sender: Any) {
//        if let usernameText = usernameTextField.text, let passwordText = passwordTextField.text {
//            if usernameText != username && passwordText != password {
//                loginFailed()
//            }
//        }
//    }
//
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.isOn {
            loginButton.setTitle("Sign Up", for: .normal)
        } else {
            loginButton.setTitle("Log in", for: .normal)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let touchBool = touchMe.canEvaluatePolicy()
        if touchBool {
            touchIDLoginAction()
        }
    }
    
    
    @IBAction func touchIDLoginAction() {
        // 1
        touchMe.authenticateUser() { [weak self] message in
            // 2
            if let message = message {
                // if the completion is not nil show an alert
                let alertView = UIAlertController(title: "Error",
                                                  message: message,
                                                  preferredStyle: .alert)
                let okAction = UIAlertAction(title: "Darn!", style: .default)
                alertView.addAction(okAction)
                self?.present(alertView, animated: true)
            } else {
                // 3
                self?.performSegue(withIdentifier: "dismissLogin", sender: self)
            }
        }
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    
    // MARK: Private Instance Methods
//    
//    private func loginFailed() {
//        let alert = UIAlertController(title: "Login failed", message: "Incorrect username or password", preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
//            self.usernameTextField.becomeFirstResponder()
//        }))
//        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
//            self.usernameTextField.resignFirstResponder()
//            self.passwordTextField.resignFirstResponder()
//        }))
//        present(alert, animated: true)
//    }
}


extension AuthViewController {
    
    @IBAction func loginButtonTapped(sender: UIButton) {
        // 1
        // Check that text has been entered into both the username and password fields.
        guard let newAccountName = usernameTextField.text,
            let newPassword = passwordTextField.text,
            !newAccountName.isEmpty,
            !newPassword.isEmpty else {
                showLoginFailedAlert()
                return
        }
        
        // 2
        usernameTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        // 3
        if authSwitch.isOn {
            // 4
            let hasLoginKey = UserDefaults.standard.bool(forKey: "hasLoginKey")
            if !hasLoginKey && usernameTextField.hasText {
                UserDefaults.standard.setValue(usernameTextField.text, forKey: "username")
            }
            
            // 5
            do {
                // This is a new account, create a new keychain item with the account name.
                let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                        account: newAccountName,
                                                        accessGroup: KeychainConfiguration.accessGroup)
                
                // Save the password for the new item.
                try passwordItem.savePassword(newPassword)
            } catch {
                fatalError("Error updating keychain - \(error)")
            }
            
            // 6
            UserDefaults.standard.set(true, forKey: "hasLoginKey")
            authSwitch.setOn(false, animated: true)
            performSegue(withIdentifier: "dismissLogin", sender: self)
        } else if !authSwitch.isOn {
            // 7
            if checkLogin(username: newAccountName, password: newPassword) {
                performSegue(withIdentifier: "dismissLogin", sender: self)
            } else {
                // 8
                showLoginFailedAlert()
            }
        }
    }
    
    func checkLogin(username: String, password: String) -> Bool {
        guard username == UserDefaults.standard.value(forKey: "username") as? String else {
            return false
        }
        
        do {
            let passwordItem = KeychainPasswordItem(service: KeychainConfiguration.serviceName,
                                                    account: username,
                                                    accessGroup: KeychainConfiguration.accessGroup)
            let keychainPassword = try passwordItem.readPassword()
            return password == keychainPassword
        } catch {
            fatalError("Error reading password from keychain - \(error)")
        }
    }
    private func showLoginFailedAlert() {
        let alertView = UIAlertController(title: "Login Problem",
                                          message: "Wrong username or password.",
                                          preferredStyle:. alert)
        let okAction = UIAlertAction(title: "Foiled Again!", style: .default)
        alertView.addAction(okAction)
        present(alertView, animated: true)
    }
}
