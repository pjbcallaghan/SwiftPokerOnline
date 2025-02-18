**SwiftPokerOnline** is a multiplayer poker game for iOS, built using Swift and Firebase. It allows players to join rooms and play Texas Hold'em in real-time. This application was made primarily as a learning exercise for myself. Hand evaluation logic was made from scratch rather than using one of the existing libraries that can help with this, due to the nature of the project as a learning exercise. The application also features a server browser and simple custom user authentication system. This project was effective in helping me to learn principles of networking, simple algorithm creation for game flow and hand evaluation logic, and UI design.

**Sample GIFs**

![til](https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExcTkxM3l1bDNsNXFqcDdhYWxjcTFnZHNldTk4ZHB1OXR5amRqemg5ZiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/t1QrWauvsGXsL5r2i0/giphy.gif)
![til](https://media3.giphy.com/media/v1.Y2lkPTc5MGI3NjExMHk0Z2d4Z2dqZ2puaDE5MWZ5dDE1bHJoNjhtOHA1Z2g0YTdtd3prZCZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/n5Mu2acQtWuTMnF2Ir/giphy.gif)

**Tech Stack**

Language: Swift

Framework: SwiftUI

Backend: Firebase Firestore

Tools: Xcode, Git, GitHub

**Known Issues**

There are a relatively large number of bugs/issues that exist within the app in its current state. While a lot of these would be fairly trivial to fix, I have decided to move on from this project as I feel that I would be able to learn more by focussing on a different project at this stage. 

**Networking issues**

*All code is executed client side*

While using Firebase Firestore as an online database for the app is convenient and effective, cloud functions are limited to paying customers. As such, functions that would preferably be run server-side (such as hand evaluation, or card dealing) are instead called on the users device. In a consumer facing app, this would open up the opportunity for a number of exploits.

*No Timer*

There is no timer on a players actions, which means users can hold a game hostage by not choosing a move. Furthermore, if a player closes the app while not connected to the internet, or if their app crashes, they will not be removed from the table. This will break the game flow and essentially ruin that particular server until the logged in user rejoins the table and selects an action. A timer that automatically removes inactive users after a period of time would be essential for a consumer facing product.

*Chip count updates*

Player chip counts will not be updated correctly after a hand ends, as the logic creates a subarray and user chip counts are updated here. This is then not correctly set to the server. Furthermore, while a user total chip count is stored on firebase (and can be seen on the logout screen) this value is never changed within the app so is meaningless.

**Game logic issues**

*No split pot logic*
If 2 players have equal hands at showdown, the player who most recently took an action will be awarded the pot, rather than there being any split pot logic.. Similarly, if one player goes all in with a smaller stack than 2+ opposing players who continue to bet, the player with the smaller stack will still be awarded the full pot should they win the hand.

*Kicker logic is incorrect in some instances*
During showdown logic, should the 2 strongest players have equal strength pairs as their best hand, or should the 2 strongest players have the same high card as their best hand, instead of choosing their highest card as their kicker, the app will instead compare the combined value of their 3 strongest kicker cards. For example, a player with a pair of aces and a queen, jack, and 10 as their kicker cards would incorrectly beat a player with a pair of aces and a king, a 2, and a 3 as their kicker cards.

Full houses are not evaluated correctly


**UI Issues**

There is no way to return to the server browser/main menu without closing and re-opening the app.

There is no way to delete a room that a user has created other than doing so manually on firebase. 

A number of failure points simply return print statements rather than providing visual feedback for the end user

Big/small blind text will not appear properly for the user when they first join a room

Fold text will not appear properly for an opponent if this causes the hand to end


