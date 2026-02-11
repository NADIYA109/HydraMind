const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

// 🔁 This function runs every minute
exports.sendWaterReminder = functions.pubsub
  .schedule("* * * * *") // every minute
  .timeZone("Asia/Kolkata")
  .onRun(async () => {

    const now = new Date();
    const currentHour = now.getHours();
    const currentMinute = now.getMinutes();

    const usersSnapshot = await db.collection("users").get();

    for (const doc of usersSnapshot.docs) {
      const data = doc.data();

      const reminder = data.reminder;
      const token = data.fcmToken;

      if (
        reminder &&
        reminder.enabled === true &&
        reminder.hour === currentHour &&
        reminder.minute === currentMinute &&
        token
      ) {
        // 🔔 SEND FCM PUSH
        await admin.messaging().send({
          token: token,
          notification: {
            title: "HydraMind 💧",
            body: "Time to drink water",
          },
        });
      }
    }

    return null;
  });
