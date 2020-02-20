import SwiftUI
import UserNotifications

struct FavouriteToggleView: View {
    @Binding var favourite: Bool
    
    var notificationId : String
    var notificationTitle : String
    var notificationLocation : String
    var notificationTrigger : Date?
    
    var body: some View {
        Image(systemName: favourite == true ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.plus").resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 30.0, height: 30.0).onTapGesture {
                self.toggle()
            }
    }
    
    func toggle() {
        self.favourite.toggle()

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                // We can do notification stuff
                
                if (self.favourite == true) {
                    if let date = self.notificationTrigger {
                        let triggerDate = date.forNotification() ?? date
                        
                        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: triggerDate)
                        
                        let content = UNMutableNotificationContent()
                        
                        content.title = self.notificationTitle
                        content.subtitle = "Your next session starts in \(self.notificationLocation) at \(date.asTime())"
                        content.sound = UNNotificationSound.default
                        
                        // Replace with cal
                        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                        
                        // choose a random identifier - use session.sessionID
                        let request = UNNotificationRequest(identifier: self.notificationId, content: content, trigger: trigger)
                        
                        UNUserNotificationCenter.current().add(request)
                    }
                } else {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [self.notificationId])
                }
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}

struct FavouriteToggleView_Previews: PreviewProvider {
    static var previews: some View {
        FavouriteToggleView(favourite: .constant(false), notificationId: "", notificationTitle: "", notificationLocation: "", notificationTrigger: Date())
    }
}
