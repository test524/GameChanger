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
    
    // MARK: Validation Publishers
    
    private var isEmailValidPublisher: AnyPublisher<Bool, Never> {
        $email
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let predicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return predicate.evaluate(with: email)
            }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<Bool, Never> {
        $password
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .map { $0.count >= 8 }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isEmailValidPublisher, isPasswordValidPublisher)
            .map { emailValid, passwordValid in emailValid && passwordValid }
            .eraseToAnyPublisher()
    }
    
    // MARK: Init
    
    init() {
        setupValidation()
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
            } else {
                self.loginMessage = "❌ Invalid credentials. Try an admin email."
            }
        }
    }
}

// MARK: - View

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @State private var isPasswordVisible = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [Color(hex: "0F0C29"), Color(hex: "302B63"), Color(hex: "24243E")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 0) {
                    Spacer(minLength: 60)
                    
                    // Header
                    header()
                    
                    // Card
                    card()
                    
                    // Sign Up Link
                    message()
                    
                    Spacer(minLength: 40)
                }
            }
        }
        .animation(.easeInOut(duration: 0.25), value: viewModel.emailError)
        .animation(.easeInOut(duration: 0.25), value: viewModel.passwordError)
        .animation(.easeInOut(duration: 0.3), value: viewModel.loginMessage)
    }
    
    func message() -> some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundColor(.white.opacity(0.4))
            Button("Create one") {}
                .foregroundColor(Color(hex: "A78BFA"))
        }
        .font(.system(size: 14, weight: .medium))
        .padding(.top, 24)
    }
    
    func header() -> some View {
        VStack(spacing: 12) {
            Image(systemName: "lock.shield.fill")
                .font(.system(size: 56))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(hex: "A78BFA"), Color(hex: "818CF8")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            
            Text("Welcome Back")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Sign in to your account")
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.bottom, 40)
    }
    
    func card() -> some View {
        VStack(spacing: 20) {
            
            // Email Field
           email()
            
            // Password Field
            password()
            
            // Forgot Password
            HStack {
                Spacer()
                Button("Forgot Password?") {}
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "A78BFA"))
            }
            
            // Login Button
            Button(action: viewModel.login) {
                ZStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .font(.system(size: 16, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    Group {
                        if viewModel.isFormValid {
                            LinearGradient(
                                colors: [Color(hex: "A78BFA"), Color(hex: "818CF8")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.white.opacity(0.1)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .shadow(
                    color: viewModel.isFormValid ? Color(hex: "A78BFA").opacity(0.5) : .clear,
                    radius: 12, x: 0, y: 6
                )
            }
            .disabled(!viewModel.isFormValid || viewModel.isLoading)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isFormValid)
            
            // Login Message
            if !viewModel.loginMessage.isEmpty {
                Text(viewModel.loginMessage)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.white.opacity(0.08))
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(28)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal, 24)
    }
    
    func password() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Password", systemImage: "key.horizontal")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                Group {
                    if isPasswordVisible {
                        TextField("Minimum 8 characters", text: $viewModel.password)
                    } else {
                        SecureField("Minimum 8 characters", text: $viewModel.password)
                    }
                }
                .foregroundColor(.white)
                .tint(Color(hex: "A78BFA"))
                .autocapitalization(.none)
                .autocorrectionDisabled()
                
                Button {
                    isPasswordVisible.toggle()
                } label: {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .font(.system(size: 15))
                        .foregroundColor(.white.opacity(0.4))
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                viewModel.passwordError.isEmpty
                                    ? Color.white.opacity(0.15)
                                    : Color(hex: "F87171"),
                                lineWidth: 1
                            )
                    )
            )
            
            if !viewModel.passwordError.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(viewModel.passwordError)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "F87171"))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    
    func email() -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Label("Email Address", systemImage: "envelope")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white.opacity(0.7))
            
            HStack {
                TextField("you@example.com", text: $viewModel.email)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .tint(Color(hex: "A78BFA"))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.07))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                viewModel.emailError.isEmpty
                                    ? Color.white.opacity(0.15)
                                    : Color(hex: "F87171"),
                                lineWidth: 1
                            )
                    )
            )
            
            if !viewModel.emailError.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 12))
                    Text(viewModel.emailError)
                        .font(.system(size: 12, weight: .medium))
                }
                .foregroundColor(Color(hex: "F87171"))
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }
        
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview {
    LoginView()
}
