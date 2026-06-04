//
// NotificationService.swift
// Aira
//

import Foundation
import UserNotifications


final class NotificationService {


    static let shared =
    NotificationService()


    private init() {}



    // طلب السماح
    func requestPermission() {


        UNUserNotificationCenter
            .current()
            .requestAuthorization(
                options: [
                    .alert,
                    .sound,
                    .badge
                ]
            ) { allowed, error in


                if allowed {

                    print("🔔 Notification allowed")

                } else {

                    print("🔕 Notification denied")
                }
            }
    }





    // إرسال التنبيه

    func sendAlert(
        title: String,
        message: String
    ) {


        let content =
        UNMutableNotificationContent()


        content.title =
        title


        content.body =
        message


        content.sound =
        .default






        let request =
        UNNotificationRequest(

            identifier:
                UUID().uuidString,

            content:
                content,

            trigger:
                nil
        )







        UNUserNotificationCenter
            .current()
            .add(request)
    }
}
