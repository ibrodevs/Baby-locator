# Baby Locator — Google Play Data Safety Declaration (2026)

This document provides the exact, code-audited answers for the Google Play Console **Data safety** questionnaire for **Baby Locator**.

---

## 1. Overview & Data Practices Summary

- **Does your app collect or share any of the required user data types?**  
  **Yes**.
- **Is all of the user data collected by your app encrypted in transit?**  
  **Yes** (all network communications use TLS/HTTPS and secure WebSocket/WSS protocols).
- **Do you provide a way for users to request that their data be deleted?**  
  **Yes** (in-app via Settings → Delete Account, and publicly at `https://baby-locator.online/delete-account.html`).
- **Does your app commit to following the Google Play Families Policy?**  
  **Yes** (parental control app designed for parents to safeguard their children).

---

## 2. Comprehensive Data Safety Questionnaire Responses

### A. Location
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Approximate location** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (child location map, battery telemetry). |
| **Precise location** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (real-time tracking, Safe Zones, movement history, emergency SOS). |

### B. Personal Info
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Name / Display name** | **Yes** | **No** | Stored on server, encrypted in transit. | Account management, App functionality (displaying child profile to parent). |
| **User IDs** | **Yes** | **No** | Stored on server, encrypted in transit. | Account management, authentication. |
| **Address** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (GPS coordinates converted to street address via reverse geocoding to display location history). |
| **Phone number** | **NO (Not collected)** | **No** | **N/A** | **Not collected by application or backend.** |
| **Email address** | **Optional** | **No** | Stored if provided during registration. | Account management. |

### C. Audio
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Voice / Sound recordings** | **Yes** | **No** | Ephemeral streaming via in-memory buffer to linked parent. Not persisted to disk during live streaming. | App functionality (parent-initiated Listen Around ambient safety audio). |

### D. Messages
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **In-app messages** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (family chat between parent and linked child). |

### E. Photos and Videos
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Photos** | **Optional** | **No** | Stored on server, encrypted in transit. | App functionality (user avatar profile pictures uploaded voluntarily). |

### F. App Activity
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Installed apps** | **Yes** | **No** | Transmitted to parent dashboard, encrypted in transit. | App functionality (enabling parent to configure App Blocking and screen time rules). |
| **App interactions / Usage time** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (daily app usage snapshots and screen time tracking). |

### G. Device or Other Identifiers
| Data Type | Collected? | Shared? | Processing | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| **Device or other IDs** | **Yes** | **No** | Stored on server, encrypted in transit. | App functionality (FCM push notification token, battery level, device OS version). |

---

## 3. Policy & Compliance Guarantees

1. **Third-Party Data Sharing:**  
   **No user data is sold, rented, or shared with third parties or data brokers.** All data processing is strictly first-party between the parent and linked child accounts.
2. **AccessibilityService Data Guarantee:**  
   AccessibilityService on the child device is restricted to `canRetrieveWindowContent=false`. It operates solely using `AccessibilityEvent.packageName` to match open applications against the parental block list. It **never** accesses screen text, keystrokes, messages, phone numbers, or passwords.
3. **Listen Around Transparency:**  
   When the microphone is active, a persistent notification with the Baby Locator icon is displayed on the child device:  
   `Baby Locator — Microphone is active. Live audio is being shared with your linked parent.`
4. **Data Deletion:**  
   When an account is deleted, all associated location records, messages, child profiles, and media files are permanently purged.
