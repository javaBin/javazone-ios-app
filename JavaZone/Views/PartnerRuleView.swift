import SwiftUI

struct PartnerRuleView: View {
    var body: some View {
        ScrollView {
            VStack {
                Text("Visit All The Partners Game")
                    .font(.title).padding(.bottom)
                
                Text("""
1. Visit all partner stands and scan their QR-codes. Each stand should have one, ask if they are not visible.

2. When you have got a green checkmark on all logos, visit the javaBin Lounge in the expo area.

3. Show your badge, and register your contact information to participate in a prize draw.
""")
                    .font(.body)

                Text("Prizes")
                    .font(.headline).padding()
                
                Text("The prizes will be drawn shortly after the conference. If you are among the lucky winners you will hear from us shortly after the conference.").font(.body)

                Text("General Data Protection Regulation (GDPR)")
                    .font(.headline).padding()

                Text("""
JavaZone team would like to remind attendees that by allowing a partner to scan your badge, you are agreeing to share your contact information with them.

All data will be stored locally on the device and no data will be collected or shared with third parties.
""")
                    .font(.body)
            }.padding()
        }
    }
}

struct PartnerRuleView_Previews: PreviewProvider {
    static var previews: some View {
        PartnerRuleView()
    }
}
