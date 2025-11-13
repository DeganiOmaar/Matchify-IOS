import SwiftUI

struct HomeView: View {
    var body: some View {
        VStack {
            Spacer()
            
            Text("Home Page")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(.primary)
            
            Spacer()
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        HomeView()
    }
}
