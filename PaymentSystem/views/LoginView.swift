//
//  LoginView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var viewModel: LoginViewModel
    @State private var username = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var animateGradient = false
    
    var body: some View {
        ZStack {
            // Animated Background
            backgroundGradient
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Logo Section
                    logoSection
                    
                    // Login Form
                    loginForm
                    
                    // Sign Up Link
                    signUpSection
                }
                .padding(.horizontal, 24)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showSignUp) {
            NavigationStack {
                SignUpView()
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient = true
            }
        }
    }
    
    // MARK: - Background Gradient
    private var backgroundGradient: some View {
        ZStack {
            LinearGradient(
                colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .ignoresSafeArea()
            
            // Floating orbs
            Circle()
                .fill(Color(hex: "667eea").opacity(0.3))
                .frame(width: 200, height: 200)
                .blur(radius: 60)
                .offset(x: animateGradient ? 100 : -100, y: animateGradient ? -150 : -200)
            
            Circle()
                .fill(Color(hex: "764ba2").opacity(0.3))
                .frame(width: 250, height: 250)
                .blur(radius: 70)
                .offset(x: animateGradient ? -80 : 80, y: animateGradient ? 300 : 250)
        }
    }
    
    // MARK: - Logo Section
    private var logoSection: some View {
        VStack(spacing: 20) {
            Spacer()
                .frame(height: 60)
            
            // Logo
            ZStack {
                // Outer glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [Color(hex: "667eea").opacity(0.4), .clear],
                            center: .center,
                            startRadius: 40,
                            endRadius: 100
                        )
                    )
                    .frame(width: 180, height: 180)
                
                // Main circle
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 110, height: 110)
                    .shadow(color: Color(hex: "667eea").opacity(0.6), radius: 20, y: 10)
                
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text("Tamim Pay")
                    .font(.system(size: 34, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text("Secure • Fast • Reliable")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .tracking(2)
            }
        }
        .padding(.bottom, 40)
    }
    
    // MARK: - Login Form
    private var loginForm: some View {
        VStack(spacing: 20) {
            // Username Field
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "person.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
                
                TextField("", text: $username, prompt: Text("Username").foregroundColor(.white.opacity(0.4)))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
                    .font(.body)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Password Field
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
                
                SecureField("", text: $password, prompt: Text("Password").foregroundColor(.white.opacity(0.4)))
                    .foregroundColor(.white)
                    .font(.body)
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
            
            // Error Message
            if let error = viewModel.errorMessage {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.caption)
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(Color(hex: "ff6b6b"))
                .padding(.horizontal)
            }
            
            // Login Button
            Button {
                viewModel.login(username: username, password: password)
            } label: {
                HStack(spacing: 12) {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign In")
                            .fontWeight(.bold)
                        Image(systemName: "arrow.right")
                            .font(.body.bold())
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(
                    LinearGradient(
                        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .foregroundColor(.white)
                .cornerRadius(16)
                .shadow(color: Color(hex: "667eea").opacity(0.5), radius: 15, y: 8)
            }
            .disabled(viewModel.isLoading || username.isEmpty || password.isEmpty)
            .opacity(username.isEmpty || password.isEmpty ? 0.7 : 1)
            .padding(.top, 8)
        }
    }
    
    // MARK: - Sign Up Section
    private var signUpSection: some View {
        VStack(spacing: 20) {
            // Divider
            HStack {
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(height: 1)
                
                Text("OR")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.horizontal, 16)
                
                Rectangle()
                    .fill(.white.opacity(0.2))
                    .frame(height: 1)
            }
            .padding(.vertical, 24)
            
            // Sign Up Button
            Button {
                showSignUp = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.badge.plus")
                    Text("Create New Account")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            lineWidth: 2
                        )
                )
                .foregroundColor(.white)
            }
            
            // Footer
            Text("By signing in, you agree to our Terms & Privacy Policy")
                .font(.caption2)
                .foregroundColor(.white.opacity(0.4))
                .multilineTextAlignment(.center)
                .padding(.top, 20)
                .padding(.bottom, 40)
        }
    }
}

#Preview {
    NavigationStack {
        LoginView()
            .environmentObject(LoginViewModel())
    }
}
