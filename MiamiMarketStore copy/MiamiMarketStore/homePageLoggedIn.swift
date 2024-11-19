import SwiftUI
import FirebaseAuth


struct homePageLoggedIn: View {
    @Binding var isSignedIn: Bool
    @State private var selectedTab: Int? = nil // Track the selected tab

    var body: some View {
        VStack {
            // Show Home Page or Selected Tab Content
            if selectedTab == nil {
                Text("Welcome to the Home Page!")
                    .font(.largeTitle)
                    .padding()
            } else {
                Group {
                    switch selectedTab {
                    case 0: LocationPage()
                    case 1: PreferencePage()
                    case 2: SettingPage(isSignedIn: $isSignedIn)
                    default: Text("Unknown Tab")
                    }
                }
            }

            Spacer()

            // Custom Tab Bar
            CustomTabView(
                selectedTab: selectedTab ?? 0, // Default to the first tab when selectedTab is nil
                onSelect: { selectedTab = $0 }
            )
        }
        .padding(.bottom, 30)
        .ignoresSafeArea(edges: .bottom)
    }
}

#Preview {
    homePageLoggedIn(isSignedIn: .constant(true))
}


