import SwiftUI

struct CustomTabView: View {
    let selectedTab: Int
    let onSelect: (Int) -> Void
    @Namespace private var animationSpace

    var body: some View {
        ZStack {
            // Tab Bar Background
            Capsule()
                .frame(height: 80)
                .padding(.horizontal, 5)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(radius: 2)

            // Tab Buttons
            HStack {
                ForEach(0..<3) { index in
                    Button(action: { onSelect(index) }) {
                        VStack(spacing: 8) {
                            // Tab Icon
                            Image(systemName: tabIconName(for: index))
                                .font(.system(size: 24))
                                .foregroundColor(selectedTab == index ? .blue : .gray)

                            // Tab Label
                            Text(tabLabelName(for: index))
                                .font(.system(size: 14))
                                .foregroundColor(selectedTab == index ? .blue : .gray)

                            // Blue Line Indicator
                            if selectedTab == index {
                                Capsule()
                                    .frame(height: 4) // Thinner line for better fit
                                    .foregroundColor(.blue)
                                    .matchedGeometryEffect(id: "SelectedTab", in: animationSpace)
                                    .padding(.top, -2) // Fine-tune positioning
                            } else {
                                Capsule()
                                    .frame(height: 4)
                                    .foregroundColor(.clear)
                            }
                        }
                        .frame(maxWidth: .infinity) // Distribute buttons evenly
                    }
                }
            }
            .padding(.horizontal, 16) // Ensure buttons are spaced slightly from the edges
        }
        .frame(height: 80) // Keep overall tab bar height consistent
        .padding(.bottom, -8) // Adjust overall vertical alignment of tab bar
    }

    // Helper Functions for Tab Names
    private func tabIconName(for index: Int) -> String {
        switch index {
        case 0: return "location.magnifyingglass"
        case 1: return "house.circle"
        case 2: return "gear.circle"
        default: return ""
        }
    }

    private func tabLabelName(for index: Int) -> String {
        switch index {
        case 0: return "Location"
        case 1: return "Profile"
        case 2: return "Settings"
        default: return ""
        }
    }
}




struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(
            selectedTab: 0, // Default to "Location"
            onSelect: { _ in } // Provide an empty callback
        )
    }
}



