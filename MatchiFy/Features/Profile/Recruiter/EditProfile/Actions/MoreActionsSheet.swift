import SwiftUI

struct MoreActionsSheet: View {

    var onEditProfile: () -> Void
    var onSettings: () -> Void

    var body: some View {
        VStack(spacing: 20) {

            Button(action: onEditProfile) {
                HStack {
                    Image(systemName: "pencil")
                        .font(.system(size: 20))
                    Text("Edit Profile")
                        .font(.system(size: 18))
                    Spacer()
                }
                .padding()
            }

            Button(action: onSettings) {
                HStack {
                    Image(systemName: "gearshape")
                        .font(.system(size: 20))
                    Text("Settings")
                        .font(.system(size: 18))
                    Spacer()
                }
                .padding()
            }

            Spacer()
        }
        .padding()
        .presentationDetents([.height(180)])
    }
}
