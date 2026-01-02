importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.10.1/firebase-messaging.js");

firebase.initializeApp({
  apiKey: "AIzaSyDp58F_Sdf-CrcwUb8ZizIV7zCVEjIB1FI",
  authDomain: "to-chegando-motoboy-24b4a.firebaseapp.com",
  projectId: "to-chegando-motoboy-24b4a",
  storageBucket: "to-chegando-motoboy-24b4a.appspot.com",
  messagingSenderId: "491950036407",
  appId: "1:491950036407:web:generated-web-id", // web usa outro id, isso é normal
});

const messaging = firebase.messaging();

// 🔔 Mensagens recebidas com app em background
messaging.setBackgroundMessageHandler(function (payload) {
  console.log('[firebase-messaging-sw.js] Mensagem recebida ', payload);

  const notificationTitle = payload.notification?.title || 'Nova notificação';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png', // ajuste se tiver outro ícone
    data: payload.data || {},
  };

  return self.registration.showNotification(
    notificationTitle,
    notificationOptions
  );
});

// 👉 Clique na notificação
self.addEventListener('notificationclick', function (event) {
  console.log('Notificação clicada: ', event);

  event.notification.close();

  event.waitUntil(
    clients.matchAll({ type: "window", includeUncontrolled: true }).then(clientList => {
      for (const client of clientList) {
        if (client.url && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});
