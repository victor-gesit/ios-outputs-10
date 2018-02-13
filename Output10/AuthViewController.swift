import UIKit

class AuthViewController: UIViewController {

    let username = "iosdevs"
    let password = "andela"
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func loginButtonTapped(_ sender: Any) {
        if let usernameText = usernameTextField.text, let passwordText = passwordTextField.text {
            if usernameText != username && passwordText != password {
                loginFailed()
            }
        }
    }
    // MARK: Private Instance Methods
    
    private func loginFailed() {
        let alert = UIAlertController(title: "Login failed", message: "Incorrect username or password", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .default, handler: { _ in
            self.usernameTextField.becomeFirstResponder()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.usernameTextField.resignFirstResponder()
            self.passwordTextField.resignFirstResponder()
        }))
        present(alert, animated: true)
    }
}
