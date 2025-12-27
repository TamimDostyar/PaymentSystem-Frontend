//
//  SignUpView.swift
//  PaymentSystem
//
//  Created by Ahmad Tamim Dostyar on 12/26/25.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = SignUpViewModel()
    
    @State private var name = ""
    @State private var lastName = ""
    @State private var address = ""
    @State private var phoneNumber = ""
    @State private var username = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var selectedAccountType: AccountType = .checking
    
    @State private var showSuccessAlert = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                headerSection
                
                // Form
                formSection
                
                // Sign Up Button
                signUpButton
                
                // Error Message
                errorSection
            }
        }
        .background(
            LinearGradient(
                colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
        )
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
        }
        .alert("Account Created!", isPresented: $showSuccessAlert) {
            Button("Continue to Login") {
                dismiss()
            }
        } message: {
            Text("Your account has been created successfully. You can now log in with your credentials.")
        }
        .onChange(of: viewModel.isSignUpSuccessful) { _, success in
            if success {
                showSuccessAlert = true
            }
        }
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                
                Image(systemName: "person.badge.plus")
                    .font(.system(size: 44))
                    .foregroundColor(.white)
            }
            .padding(.top, 40)
            
            Text("Create Account")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text("Join us and start managing your finances")
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - Form Section
    private var formSection: some View {
        VStack(spacing: 20) {
            // Personal Info Section
            sectionHeader("Personal Information")
            
            HStack(spacing: 12) {
                customTextField(
                    icon: "person.fill",
                    placeholder: "First Name",
                    text: $name
                )
                
                customTextField(
                    icon: "person.fill",
                    placeholder: "Last Name",
                    text: $lastName
                )
            }
            
            customTextField(
                icon: "house.fill",
                placeholder: "Address",
                text: $address
            )
            
            customTextField(
                icon: "phone.fill",
                placeholder: "Phone Number",
                text: $phoneNumber,
                keyboardType: .phonePad
            )
            
            // Account Type Picker
            accountTypePicker
            
            // Login Info Section
            sectionHeader("Login Credentials")
            
            // Username with availability check
            usernameField
            
            customSecureField(
                icon: "lock.fill",
                placeholder: "Password",
                text: $password
            )
            
            customSecureField(
                icon: "lock.shield.fill",
                placeholder: "Confirm Password",
                text: $confirmPassword
            )
            
            // Password Match Indicator
            if !confirmPassword.isEmpty {
                HStack {
                    Image(systemName: password == confirmPassword ? "checkmark.circle.fill" : "xmark.circle.fill")
                    Text(password == confirmPassword ? "Passwords match" : "Passwords don't match")
                        .font(.caption)
                }
                .foregroundColor(password == confirmPassword ? .green : .red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 4)
            }
        }
        .padding(.horizontal, 24)
    }
    
    // MARK: - Section Header
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 14, weight: .semibold, design: .rounded))
            .foregroundColor(.white.opacity(0.6))
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 8)
    }
    
    // MARK: - Account Type Picker
    private var accountTypePicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.1))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: "building.columns.fill")
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Picker("Account Type", selection: $selectedAccountType) {
                    ForEach(AccountType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.segmented)
                .tint(Color(hex: "667eea"))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.08))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            )
        }
    }
    
    // MARK: - Username Field with Availability
    private var usernameField: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: "at")
                    .foregroundColor(.white.opacity(0.7))
            }
            
            TextField("", text: $username, prompt: Text("Username").foregroundColor(.white.opacity(0.5)))
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled()
                .foregroundColor(.white)
                .onChange(of: username) { _, newValue in
                    viewModel.checkUsernameAvailability(username: newValue)
                }
            
            // Availability indicator
            if viewModel.checkingUsername {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(0.8)
            } else if let available = viewModel.usernameAvailable {
                Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(available ? .green : .red)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Custom Text Field
    private func customTextField(
        icon: String,
        placeholder: String,
        text: Binding<String>,
        keyboardType: UIKeyboardType = .default
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            TextField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .textInputAutocapitalization(.words)
                .keyboardType(keyboardType)
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Custom Secure Field
    private func customSecureField(
        icon: String,
        placeholder: String,
        text: Binding<String>
    ) -> some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(.white.opacity(0.1))
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            SecureField("", text: text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.5)))
                .foregroundColor(.white)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.white.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
    
    // MARK: - Sign Up Button
    private var signUpButton: some View {
        Button {
            viewModel.signUp(
                name: name,
                lastName: lastName,
                address: address,
                accountType: selectedAccountType,
                phoneNumber: phoneNumber,
                username: username,
                password: password,
                confirmPassword: confirmPassword
            )
        } label: {
            HStack {
                if viewModel.isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text("Create Account")
                        .fontWeight(.bold)
                    Image(systemName: "arrow.right")
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(16)
        }
        .disabled(viewModel.isLoading)
        .padding(.horizontal, 24)
        .padding(.top, 32)
    }
    
    // MARK: - Error Section
    private var errorSection: some View {
        Group {
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                        .font(.caption)
                }
                .foregroundColor(.red)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.red.opacity(0.1))
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
            }
        }
        .padding(.bottom, 40)
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
            (a, r, g, b) = (1, 1, 1, 0)
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

#Preview {
    NavigationStack {
        SignUpView()
    }
}

