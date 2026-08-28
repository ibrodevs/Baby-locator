# Google Play Console: Data Safety Form Guide

**Application:** Family Security (`com.company.familysecurity`)  
**Developer:** Quantum limited  
**Privacy Policy URL:** `https://baby-locator-web.vercel.app/privacy-policy.html`  
**Account Deletion URL:** `https://baby-locator-web.vercel.app/delete-account.html`  

---

## 1. Overview Questions

1. **Does your app collect or share any of the required user data types?**  
   > **Yes**
2. **Is all of the user data collected by your app encrypted in transit?**  
   > **Yes** *(All network communications use HTTPS / TLS 1.3)*
3. **Do you provide a way for users to request that their data be deleted?**  
   > **Yes** *(In-app under Settings > Account > Delete Account and via web link)*
4. **Does your app provide a link that users can follow to request account and data deletion?**  
   > **Yes**  
   > URL: `https://baby-locator-web.vercel.app/delete-account.html`

---

## 2. Data Types Breakdown

### A. Location Data

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **Approximate location**, **Precise location** |
| **Is it collected?** | **Yes** |
| **Is it shared with third parties?** | **No** (Shared only with the authenticated paired parent account) |
| **Is it processed ephemerally?** | **No** (Stored to provide location history and safe zone event logs to parents) |
| **Is collection required or optional?** | **Required for child tracking features / Optional for parent** |
| **Purposes** | **App functionality** *(Real-time child location tracking, safe zone alerts, SOS emergency alerts)* |

---

### B. Personal Info

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **Name** *(Display Name)*, **User IDs** *(Account username/ID)* |
| **Is it collected?** | **Yes** |
| **Is it shared with third parties?** | **No** |
| **Is collection required or optional?** | **Required for account creation and parent-child pairing** |
| **Purposes** | **Account management**, **App functionality** |

---

### C. Messages

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **Other in-app messages** *(Family chat messages & task notes between parent and child)* |
| **Is it collected?** | **Yes** |
| **Is it shared with third parties?** | **No** |
| **Purposes** | **App functionality** *(Family communication & task management)* |

---

### D. Audio Files (Microphone)

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **Voice or sound recordings** *(On-demand ambient audio requested by parent)* |
| **Is it collected?** | **Yes** *(Only when activated by parent on-demand)* |
| **Is it shared with third parties?** | **No** |
| **Is it processed ephemerally?** | **Yes** *(Streamed live to parent or stored ephemerally for playback, not used for profiling)* |
| **Is collection required or optional?** | **Optional** |
| **Purposes** | **App functionality** *(Parental safety monitoring around child)* |

---

### E. App Activity & App Info

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **App interactions** *(App usage duration/stats on child device)*, **Installed apps** *(For parental app blocking configuration)* |
| **Is it collected?** | **Yes** |
| **Is it shared with third parties?** | **No** |
| **Purposes** | **App functionality** *(Parental control app limits, screen time statistics, and app blocking)* |

---

### F. Device or Other IDs

| Field | Value |
| :--- | :--- |
| **Data Types Collected** | **Device or other IDs** *(FCM push notification token, device model, battery level)* |
| **Is it collected?** | **Yes** |
| **Is it shared with third parties?** | **No** |
| **Purposes** | **App functionality** *(Push notification delivery, battery level monitoring for parent)* |

---

## 3. Security Practices

- **Encryption in Transit:** All collected user and telemetry data is transmitted using encrypted HTTPS / TLS 1.3 protocols.
- **Access Control:** Multi-tenant child data isolation ensures that only the authenticated parent account paired via invite code can view location and device telemetry.
- **Account & Data Deletion:** Users can permanently delete their account and all associated child profiles, location records, and messages instantly via the in-app menu or through the web deletion portal at `https://baby-locator-web.vercel.app/delete-account.html`.
