import SwiftUI

struct LoginView: View {
    @Binding var isAuthenticated: Bool
    @Binding var showLoginView: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: login) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Login")
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || isLoading)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle("Login", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showLoginView = false
                    }
                }
            }
        }
    }
    
    private func login() {
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                let success = try await AuthService.shared.login(email: email, password: password)
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    isLoading = false
                    if success {
                        isAuthenticated = true
                        showLoginView = false
                    }
                }
            } catch let error as APIError {
                handleError(message: error.errorDescription)
            } catch {
                handleError(message: error.localizedDescription)
            }
        }
    }
    
    private func handleError(message: String) {
        // Update UI on main thread
        DispatchQueue.main.async {
            isLoading = false
            errorMessage = message
        }
    }
}
