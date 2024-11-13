import SwiftUI

struct CustomTabView: View {
    @Binding var tableSelection: Int
    @Namespace private var animationSpace
    
    let tabBarItems: [(title: String, name: String)] = [
        ("Location", "location.magnifyingglass"),
        ("Profile", "house.circle"),
        ("Settings", "gear.circle")
    ]
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(height: 80)
                .foregroundColor(Color(.secondarySystemBackground))
                .shadow(radius: 2)
            
            HStack {
                ForEach(0..<tabBarItems.count, id: \.self) { index in
                    Button(action: {
                        tableSelection = index + 1
                    }) {
                        VStack(spacing: 8) {
                            Spacer()
                            
                            // Image for the tab icon
                            Image(systemName: tabBarItems[index].name)
                                .font(.system(size: 24)) // Adjust font size as needed
                            
                            // Text for the tab label
                            Text(tabBarItems[index].title)
                                .font(.system(size: 14))
                            
                            // Capsule indicating selected tab
                            selectionIndicator(for: index)
                        }
                        .foregroundColor(index + 1 == tableSelection ? .blue : .gray)
                    }
                    .frame(maxWidth: .infinity) // Distribute buttons equally
                }
            }
            .frame(height: 80)
            .clipShape(Capsule())
        }
        .padding(.horizontal)
    }
    
    // Selection Indicator View as a separate function
    @ViewBuilder
    private func selectionIndicator(for index: Int) -> some View {
        if index + 1 == tableSelection {
            Capsule()
                .frame(height: 8)
                .foregroundColor(.blue)
                .matchedGeometryEffect(id: "SelectedTabId", in: animationSpace)
                .offset(y: 3)
        } else {
            Capsule()
                .frame(height: 8)
                .foregroundColor(.clear)
                .offset(y: 3)
        }
    }
}

struct CustomTabView_Previews: PreviewProvider {
    static var previews: some View {
        CustomTabView(tableSelection: .constant(1))
            .previewLayout(.sizeThatFits)
            .padding(.vertical)
    }
}
