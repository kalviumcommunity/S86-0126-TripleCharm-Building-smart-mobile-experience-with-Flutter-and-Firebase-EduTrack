importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "AIzaSyAvIbdjTwOZm7rrFtuEg0KLL339bVYx9hU",
  authDomain: "edutrack-demo-e4192.firebaseapp.com",
  projectId: "edutrack-demo-e4192",
  storageBucket: "edutrack-demo-e4192.firebasestorage.app",
  messagingSenderId: "655038338036",
  appId: "1:655038338036:web:702918ae29f5b6026edfa1",
});

const messaging = firebase.messaging();

// Optional: Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log("Received background message: ", payload);
  const notificationTitle = payload.notification.title;
  const notificationOptions = {
    body: payload.notification.body,
    icon: "/icons/Icon-192.png",
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});
