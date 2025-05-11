import SwiftUI

struct HomeView: View {
    @Binding var isAuthenticated: Bool
    @State private var userName: String = "User"
    @State private var isLoading = true
    
    var body: some View {
        VStack {
            Text("Welcome, \(userName)")
                .font(.title)
                .padding()
            
            Spacer()
            
            if isLoading {
                ProgressView()
                    .padding()
            } else {
                Text("You are logged in!")
                    .padding()
            }
            
            Spacer()
            
            Button("Logout") {
                logout()
            }
            .padding()
            .buttonStyle(.borderedProminent)
            .tint(.red)
        }
        .padding()
        .onAppear {
            loadUserProfile()
        }
    }
    
    private func loadUserProfile() {
        Task {
            do {
                let userProfile = try await UserService.shared.getProfile()
                DispatchQueue.main.async {
                    self.userName = "\(userProfile.firstName) \(userProfile.lastName)"
                    self.isLoading = false
                }
            } catch {
                print("Failed to load user profile: \(error)")
                DispatchQueue.main.async {
                    self.isLoading = false
                }
            }
        }
    }
    
    private func logout() {
        Task {
            do {
                try await AuthService.shared.logout()
                DispatchQueue.main.async {
                    isAuthenticated = false
                }
            } catch {
                print("Logout failed: \(error)")
            }
        }
    }
}