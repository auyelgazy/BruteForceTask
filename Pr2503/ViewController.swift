import UIKit

final class ViewController: UIViewController {

    // MARK: - UI

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var stopButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

    // MARK: - Properties

    var isSearching = false
    var isBlack: Bool = false {
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

    @IBAction func changeBackgroundButton(_ sender: Any) {
        isBlack.toggle()
    }

    @IBAction func startPressed(_ sender: UIButton) {
        guard let password = textField.text else { return }
        if password == "" { return }
        activityIndicator.startAnimating()
        bruteForce(passwordToUnlock: password)
    }

    @IBAction func stopPressed(_ sender: UIButton) {
        isSearching = false
    }

    private func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }

        var password: String = ""
        isSearching = true

        let queue = DispatchQueue(label: "queue", qos: .userInitiated)
        queue.async {
            while password != passwordToUnlock && self.isSearching {
                password = self.generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)

                DispatchQueue.main.async {
                    self.label.text = password
                }
            }

            DispatchQueue.main.async {
                if password == passwordToUnlock {
                    self.label.text = "Password: \(password)"
                } else {
                    self.label.text = "Password not found"
                }
                self.activityIndicator.stopAnimating()
            }
        }
    }

    private func indexOf(character: Character, _ array: [String]) -> Int {
        return array.firstIndex(of: String(character))!
    }

    private func characterAt(index: Int, _ array: [String]) -> Character {
        return index < array.count ? Character(array[index])
        : Character("")
    }

    private func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
        var str: String = string

        if str.count <= 0 {
            str.append(characterAt(index: 0, array))
        }
        else {
            str.replace(at: str.count - 1,
                        with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

            if indexOf(character: str.last!, array) == 0 {
                str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
            }
        }

        return str
    }
}

// MARK: - Extensions

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }



    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}
