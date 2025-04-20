import FirebaseAuth
import Combine

class UserAuthViewModel: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var isLoggedIn = false
    @Published var authError: String?
    @Published var displayName: String
    @Published var email: String?
    
    var currentUserUid: String? {
        return user?.uid  // This will give you the UID of the logged-in user
    }

    init() {
        let currentUser = Auth.auth().currentUser
        self.user = currentUser
        self.isLoggedIn = currentUser != nil
        self.displayName = currentUser?.displayName ?? ""
        self.email = currentUser?.email
    }

    func signUp(email: String, password: String, displayName: String) {
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                } else if let user = result?.user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges { error in
                        if let error = error {
                            self?.authError = "Profile update failed: \(error.localizedDescription)"
                        } else {
                            self?.user = user
                            self?.displayName = displayName
                            self?.email = user.email
                            self?.isLoggedIn = true
                        }
                    }
                }
            }
        }
    }


    func logIn(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    self?.authError = error.localizedDescription
                } else {
                    self?.user = result?.user
                    self?.isLoggedIn = true
                }
            }
        }
    }

    func logOut() {
        do {
            try Auth.auth().signOut()
            self.user = nil
            self.isLoggedIn = false
        } catch {
            self.authError = error.localizedDescription
        }
    }
}
