import SwiftUI
import Combine

// MARK: - ViewModel

class LoginViewModel: ObservableObject {
    
    // MARK: Inputs
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: Outputs
    @Published var emailError: String = ""
    @Published var passwordError: String = ""
    @Published var isFormValid: Bool = false
    @Published var isLoading: Bool = false
    @Published var loginMessage: String = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Init
    var authService: AuthenticationService?
    
    // MARK: Init
    init() {
        setupValidation()
    }
    
    // MARK: Validation Publishers
    private var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return predicate.evaluate(with: email)
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0.count >= 8 }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isEmailValidPublisher, isPasswordValidPublisher)
            .map { emailValid, passwordValid in emailValid && passwordValid }
            .eraseToAnyPublisher()
    }
    
    private func setupValidation() {
        
        // Email error message
        isEmailValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { isValid in
                isValid ? "" : "Please enter a valid email address"
            }
            .assign(to: \.emailError, on: self)
            .store(in: &cancellables)
        
        // Password error message
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { isValid in
                isValid ? "" : "Password must be at least 8 characters"
            }
            .assign(to: \.passwordError, on: self)
            .store(in: &cancellables)
        
        // Form validity
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isFormValid, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: Actions
    
    func login() {
        guard isFormValid else { return }
        
        isLoading = true
        loginMessage = ""
        
        // Simulate async login (replace with real API call)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self else { return }
            self.isLoading = false
            // Mock: success if email contains "admin"
            if self.email.lowercased().contains("admin") {
                self.loginMessage = "✅ Login successful! Welcome back."
                self.authService?.login()
            } else {
                self.loginMessage = "❌ Invalid credentials. Try an admin email."
            }
        }
    }
}

// MARK: - View





