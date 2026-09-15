\# ECHO — The Invisible Campus



> \\\*\\\*Information shouldn't disappear just because the person who discovered it walked away.\\\*\\\*



ECHO is a time-aware campus intelligence application that helps students discover and share temporary conditions around their campus.



Instead of treating campus information as permanent, ECHO gives every report a reliability score that changes over time. Students can confirm that an issue is still present or mark it as fixed, helping others understand whether information is still trustworthy.



\---



\## 👥 Team Information



\### Team Name

\*\*TechnoVerse\*\*



\### Team Members



\- \*\*Niya Aniyan\*\*

\- \*\*Vandana Gopan\*\*

\- \*\*Pravda Premji\*\*

\- \*\*Krishnapriya A L\*\*



\---



\## 🎯 Problem Statement



Students regularly encounter temporary problems and useful conditions around campus:



\- Projectors or other equipment that stop working

\- Weak Wi-Fi in particular rooms

\- Faulty power sockets

\- Maintenance issues

\- Crowded canteen counters

\- Quiet places suitable for studying

\- Other short-lived campus conditions



This information is often communicated through conversations or messaging groups.



The problem is that temporary information becomes unreliable as time passes.



A message saying that a projector is broken may have been true earlier but may no longer be true when another student reads it.



Students need a way to discover what is happening around campus while also understanding how reliable and recent that information is.



\---



\## 💡 Solution



ECHO creates a temporary, location-aware memory layer for a campus.



Students can post short observations called \*\*Echoes\*\* at specific campus locations.



Each Echo has a changing reliability score based on how recently it was confirmed.



For example:



\*\*Lab 204 — Projector issue\*\*



An Echo can become:



\*\*Fresh → Aging → Outdated\*\*



Other students can select:



\- \*\*Still True\*\* — confirms that the condition still exists

\- \*\*Fixed\*\* — marks the condition as resolved



As time passes without confirmation, reliability decreases. This prevents old information from being treated as current information.



\---



\## ✨ Features



\### 📍 Dynamic Campus Locations

Create and use additional campus locations beyond the built-in locations.



\### 📝 Echo Reporting

Students can create short reports about temporary campus conditions.



\### ⏳ Time-Based Reliability

Echo reliability changes as information becomes older.



Reports are classified using freshness states such as Fresh, Aging, and Outdated.



\### 🔄 Still True Confirmation

Students can confirm that an existing condition is still present and refresh its reliability.



\### ✅ Issue Resolution

Issues can be marked as fixed and viewed later through Echo History.



\### 🧠 Duplicate Detection

ECHO detects similar reports at the same location and gives the user the choice to use the existing report or post a new one.



\### 🔎 Search and Filtering

Search locations and Echo content and filter reports by categories including:



\- Wi-Fi

\- Equipment

\- Electricity

\- Food

\- Maintenance

\- Other



\### ⭐ Favourite Locations

Save important campus locations for quick access.



\### 📊 Campus Analytics

View campus health information including:



\- Total Echoes

\- Active Echoes

\- Resolved Echoes

\- Locations needing attention

\- Most reported locations

\- Category distribution

\- Recent reporting trends



\### 🔔 Important Updates

Surface important campus conditions based on report reliability, confirmations, newly reported conditions, and recently resolved issues.



\### 📚 Echo History

View active and resolved observations with timestamps and freshness information.



\### 📱 Offline-First Support

Campus information is stored locally so the application can continue working without an internet connection.



\### ♿ Accessibility

The application includes accessibility support and a large-text option.



\---



\## 📸 Screenshots



Screenshots of the Android application will be added here.



\### Home



!\[ECHO Home](screenshots/home.png)



\### Add Echo



!\[Add Echo](screenshots/echo.png)



\### Location Details



!\[Location Details](screenshots/location.png)



## 🎥 Demo Video

[▶️ Watch the ECHO Campus Demo Video](https://youtube.com/shorts/kjgrQuFincY?si=A7L9JkXj7fMgQ5Nl)

---

## 📊 Presentation

[📥 Download the ECHO Campus Presentation](./ECHO_Campus_Presentation%20%283%29.pptx)
\## 🛠️ Tech Stack



\- \*\*Flutter\*\*

\- \*\*Dart\*\*

\- \*\*SharedPreferences\*\* for local data persistence

\- \*\*Android\*\*

\- \*\*Git \& GitHub\*\*



\### Architecture



ECHO currently follows an \*\*offline-first local data architecture\*\*.



Campus locations and Echo data are persisted on the device, allowing the application to remain useful without an internet connection.



\---



\## 🚀 Installation Instructions



\### Requirements



\- Flutter SDK

\- Android Studio / Android SDK

\- Android device or Android emulator



\### Run from Source



Clone the repository:



```bash

git clone https://github.com/Pravda-Premji/echo-campus.git


