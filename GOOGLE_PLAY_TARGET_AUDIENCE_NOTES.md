# Baby Locator — Target Audience & Families Policy Guidance (2026)

## 1. Product Positioning
- **Primary Users:** Parents and legal guardians (Adults 18+).
- **Secondary Experience:** Linked children whose devices are managed by parents.
- **Classification:** Parental Control / Family Safety application.

## 2. Google Play Target Audience Questionnaire Guidelines
- **Target Age Groups:**  
  When filling out the Target Audience questionnaire in Google Play Console:
  - Do NOT falsely declare that the app is exclusively for children if parents are the purchasing and managing users.
  - Declare that the primary audience includes Parents/Adults, and that children may use the app under parental supervision.
  - Review Families Policy requirements:
    - No personalized advertising (Baby Locator contains zero ads).
    - Ensure Privacy Policy explicitly mentions child safety, COPPA compliance, and parental consent.
    - Third-party SDKs must comply with Families Self-Certified Ads SDK requirements (Baby Locator uses only core Firebase, RevenueCat, and Google Maps).

## 3. Play Console Submission Checklist
- [x] All active tracks (Internal, Closed, Open, Production) must be updated to new versionCode with `isMonitoringTool="child_monitoring"`.
- [x] Superseded violating releases must be deactivated or replaced.
- [x] Privacy Policy URL must be directly accessible: `https://baby-locator.online/privacy-policy.html`.
- [x] Account Deletion URL must be directly accessible: `https://baby-locator.online/delete-account.html`.
