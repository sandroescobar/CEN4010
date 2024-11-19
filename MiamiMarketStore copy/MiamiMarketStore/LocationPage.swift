//
//  LocationPage.swift
//  MiamiMarketStore
//
//  Created by Alessandro Escobar on 11/12/24.
//

import SwiftUI

struct LocationPage: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            Text("Location Page")
                .font(.largeTitle)
                .padding()

            Button("Back to Home") {
                dismiss()
            }
            .padding()
            .foregroundColor(.blue)
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
    }
}

#Preview {
    LocationPage()
}
