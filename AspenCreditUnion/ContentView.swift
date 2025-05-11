//
//  ContentView.swift
//  AspenCreditUnion
//
//  Created by Jonathan McCormick on 5/9/25.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuthenticated = false
    @State private var showLoginView = false
    @State private var showRegisterView = false
    
    var body: some View {
        NavigationView {
            if isAuthenticated {
                // User is logged in, show home screen
                HomeView(isAuthenticated: $isAuthenticated)
            } else {
                // User is not logged in, show auth options
                VStack(spacing: 20) {
                    Text("Aspen Credit Union")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Button("Login") {
                        showLoginView = true
                    }
                    .buttonStyle(.borderedProminent)
                    .frame(width: 200)
                    
                    Button("Register") {
                        showRegisterView = true
                    }
                    .buttonStyle(.bordered)
                    .frame(width: 200)
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitle("Welcome", displayMode: .inline)
                .sheet(isPresented: $showLoginView) {
                    LoginView(isAuthenticated: $isAuthenticated, showLoginView: $showLoginView)
                }
                .sheet(isPresented: $showRegisterView) {
                    RegisterView(showRegisterView: $showRegisterView, showLoginView: $showLoginView)
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
