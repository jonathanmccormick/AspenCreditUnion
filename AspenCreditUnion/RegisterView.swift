import SwiftUI

struct RegisterView: View {
    @Binding var showRegisterView: Bool
    @Binding var showLoginView: Bool
    
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var isLoading = false
    @State private var errorMessage = ""
    @State private var registrationSuccess = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Personal Information")) {
                    TextField("First Name", text: $firstName)
                    TextField("Last Name", text: $lastName)
                }
                
                Section(header: Text("Account Information")) {
                    TextField("Email", text: $email)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                    
                    SecureField("Password", text: $password)
                    SecureField("Confirm Password", text: $confirmPassword)
                }
                
                if !errorMessage.isEmpty {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                    }
                }
                
                Section {
                    Button(action: register) {
                        if isLoading {
                            ProgressView()
                        } else {
                            Text("Register")
                        }
                    }
                    .disabled(email.isEmpty || password.isEmpty || confirmPassword.isEmpty || firstName.isEmpty || lastName.isEmpty || isLoading)
                    .frame(maxWidth: .infinity)
                }
            }
            .navigationBarTitle("Register", displayMode: .inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showRegisterView = false
                    }
                }
            }
            .alert("Registration Successful", isPresented: $registrationSuccess) {
                Button("Login Now") {
                    showRegisterView = false
                    showLoginView = true
                }
            } message: {
                Text("Your account has been created. Please login with your credentials.")
            }
        }
    }
    
    private func register() {
        // Perform basic validation
        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            return
        }
        
        isLoading = true
        errorMessage = ""
        
        Task {
            do {
                try await AuthService.shared.register(
                    email: email,
                    password: password,
                    confirmPassword: confirmPassword,
                    firstName: firstName,
                    lastName: lastName
                )
                
                // Update UI on main thread
                DispatchQueue.main.async {
                    isLoading = false
                    registrationSuccess = true
                }
            } catch {
                // Update UI on main thread
                DispatchQueue.main.async {
                    isLoading = false
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
}