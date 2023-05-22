import UIKit

final class ViewController: UIViewController {

    // MARK: - UI

    @IBOutlet private weak var label: UILabel!
    @IBOutlet private weak var textField: UITextField!
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var startButton: UIButton!
    @IBOutlet private weak var stopButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    private let bruteForce = BruteForce()
    private var isSearching = false
    private var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .darkGray
                label.textColor = .white
            } else {
                self.view.backgroundColor = .lightGray
                label.textColor = .black
            }
        }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupOutlets()
    }

    // MARK: - Setup

    private func setupOutlets() {
        textField.isSecureTextEntry = true
        button.backgroundColor = .systemOrange
        startButton.backgroundColor = .systemGreen
        stopButton.backgroundColor = .systemRed
    }

    // MARK: - Actions

    @IBAction private func changeBackgroundButton(_ sender: Any) {
        isBlack.toggle()
    }

    @IBAction private func startPressed(_ sender: UIButton) {
        if isSearching { return }
        guard let password = textField.text else { return }
        guard !password.isEmpty else { return }
        activityIndicator.startAnimating()
        bruteForce(passwordToUnlock: password)
    }

    @IBAction private func stopPressed(_ sender: UIButton) {
        isSearching = false
    }

    private func bruteForce(passwordToUnlock: String) {
        let allowedCharacters: [String] = String().printable.map { String($0) }

        var password: String = ""
        isSearching = true

        let queue = DispatchQueue(label: "queue", qos: .userInitiated)
        queue.async {
            while password != passwordToUnlock && self.isSearching {
                password = self.bruteForce.generateBruteForce(password, fromArray: allowedCharacters)

                DispatchQueue.main.async {
                    self.label.text = password
                }
            }
            self.endBruteForce(password, passwordToUnlock)
        }
    }

    private func endBruteForce(_ password: String, _ passwordToUnlock: String) {
        DispatchQueue.main.async {
            if password == passwordToUnlock {
                self.label.text = "Password: \(password)"
            } else {
                self.label.text = "Password not found"
            }
            self.activityIndicator.stopAnimating()
            self.isSearching = false
        }
    }
}
