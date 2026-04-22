# Quick Actions Feature - Visual Reference

## UI/UX Flow Diagrams

### Parent Home Screen Help Flow
```
┌─────────────────────────────────────┐
│  Parent Home Screen                 │
│  ┌─────────────────────────────────┐│
│  │ Greeting                        ││
│  │ "Good Morning Sarah 👋"         ││
│  │ Find trusted care...            ││
│  └─────────────────────────────────┘│
│  [Emergency Banner]                 │
│  [Quick Actions - Find, Trust...]   │
│  [Upcoming Bookings]                │
│                                     │
│  ┌──────────────────────────────┐   │
│  │ ⊙ (Help FAB)                │ ← Click here
│  └──────────────────────────────┘   │
└─────────────────────────────────────┘
         │
         ├─→ Shows Bottom Sheet
         │
         ▼
┌──────────────────────────────────┐
│ Get Quick Help               [—]  │
├──────────────────────────────────┤
│                                  │
│ 💬 Chat with Support            │
│   Live messaging                │
│                                  │
│ 📧 Send Email                   │
│   support@hodon.app             │
│                                  │
│ 📞 Call Us                      │
│   +961 1 234 567                │
│                                  │
│ 💬 WhatsApp                     │
│   Chat via WhatsApp             │
│                                  │
│ [Cancel]                        │
└──────────────────────────────────┘
```

### Email Support Flow
```
User clicks "Send Email"
         │
         ▼
Try to open email client
         │
    ┌────┴────┐
    │          │
Success    Exception
    │          │
    ▼          ▼
Opens      Show Error
Email      SnackBar
Client     "Could not
with       open email
pre-       client"
filled
details
    │
    └─→ User composes message
        and sends to support@hodon.app
```

### Phone Call Support Flow
```
User clicks "Call Us"
         │
         ▼
Validate phone format
         │
         ▼
Try to open dialer
         │
    ┌────┴────┐
    │          │
Success    Exception
    │          │
    ▼          ▼
Opens      Show Error
Phone      SnackBar
Dialer     "Could not
with       open phone
+961123... dialer"
    │
    └─→ User confirms
        and dials
```

### WhatsApp Support Flow
```
User clicks "WhatsApp"
         │
         ▼
Check if WhatsApp is installed
         │
    ┌────┴────┐
    │          │
Installed  Not Found
    │          │
    ▼          ▼
Open      Show Error
WhatsApp  SnackBar
with      "Could not
message   open
preload   WhatsApp"
    │
    └─→ User sends message
        to support
```

## Component Hierarchy

```
Scaffold
├── AppBar
├── Body
│   └── CustomScrollView
│       └── SliverList/SliverGrid
└── FloatingActionButton
    └── Help Icon (?)
        └── onPressed
            └── _showQuickSupportOptions()
                └── showModalBottomSheet
                    └── Column
                        ├── Handle Bar
                        ├── Title "Get Quick Help"
                        ├── ListTile (Chat)
                        ├── ListTile (Email)
                        ├── ListTile (Phone)
                        ├── ListTile (WhatsApp)
                        └── Cancel Button
```

## Data Flow

```
┌─────────────────────────────────────────┐
│  CommunicationService (Singleton)       │
├─────────────────────────────────────────┤
│                                         │
│  Constants:                             │
│  • supportEmail: String                 │
│  • supportPhone: String                 │
│  • supportPhoneDisplay: String          │
│                                         │
│  Methods:                               │
│  • sendEmail()                          │
│  • makePhoneCall()                      │
│  • sendSMS()                            │
│  • openWhatsApp()                       │
│  • openUrl()                            │
│  • showCommunicationDialog()            │
│                                         │
└──────────────────┬──────────────────────┘
                   │
        ┌──────────┼──────────┬──────────┐
        │          │          │          │
        ▼          ▼          ▼          ▼
    url_launcher  mailto:   tel:    https://wa.me
        │          │          │          │
        └──────────┼──────────┼──────────┘
                   │
        ┌──────────┴──────────┐
        │                     │
        ▼                     ▼
    Platform API        External Apps
    (Android/iOS)    (Email, Phone, WhatsApp)
```

## State Management

### No State Required
The quick actions feature is stateless:
- All communication is external
- No data persistence needed
- No Riverpod providers required
- Error handling via try-catch blocks
- User feedback via SnackBar

### Error Handling Flow
```
Try Block
    │
    ├─→ Call CommunicationService method
    │
    ├─→ url_launcher opens app
    │
    ├─→ Check: canLaunchUrl(uri)
    │
    ├─→ launchUrl(uri)
    │
Catch Block (Exception)
    │
    ├─→ Check context.mounted
    │
    ├─→ Show SnackBar with error message
    │
    └─→ User sees friendly error
```

## File Organization

```
lib/
├── core/
│   ├── utils/
│   │   └── communication_service.dart ← All logic here
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_sizes.dart
│   │   └── app_strings.dart
│   ├── router/
│   │   └── app_router.dart (routes to help)
│   └── storage/
│
├── presentation/
│   ├── parent/
│   │   └── home/
│   │       └── parent_home_screen.dart ← FAB + bottom sheet
│   │
│   ├── babysitter/
│   │   └── home/
│   │       └── babysitter_home_screen.dart ← FAB + bottom sheet
│   │
│   ├── shared/
│   │   └── support/
│   │       └── help_support_screen.dart ← Action tiles + FAQs
│   │
│   └── shared/
│       └── chat/
│           ├── chat_list_screen.dart (route: /chat)
│           └── chat_screen.dart
│
├── application/
│   ├── auth/
│   ├── booking/
│   └── providers.dart
│
├── domain/
│   └── models/
│
└── data/
    └── repositories/
```

## URL Scheme Reference

| Channel | Scheme | Example |
|---------|--------|---------|
| Email | mailto: | mailto:support@hodon.app?subject=Help |
| Phone | tel: | tel:+961123456789 |
| SMS | sms: | sms:+961123456789?body=Hello |
| WhatsApp | https://wa.me | https://wa.me/961123456789?text=Help |
| URL | https:// | https://hodon.app/help |

## Platform Support Matrix

| Platform | Email | Phone | SMS | WhatsApp | URL |
|----------|-------|-------|-----|----------|-----|
| Android  | ✅    | ✅    | ✅  | ✅       | ✅  |
| iOS      | ✅    | ✅    | ✅  | ✅       | ✅  |
| Web      | ✅    | ❌    | ❌  | ✅       | ✅  |
| Windows  | ✅    | ✅    | ✅  | ✅       | ✅  |
| Linux    | ✅    | ✅    | ✅  | ✅       | ✅  |
| macOS    | ✅    | ✅    | ✅  | ✅       | ✅  |

## Settings Journey

```
Home Screen
    │
    └─→ Menu / Settings
        │
        └─→ Help & Support Screen
            │
            ├─→ Quick Actions
            │   ├─ Live Chat → /chat
            │   ├─ Email → Opens email
            │   └─ Call → Opens phone
            │
            └─→ FAQ Section
                ├─ How do I cancel?
                ├─ How are payments calculated?
                └─ How do I update verification?
```

## Testing Scenarios

### Scenario 1: User has all apps installed
```
User → FAB → Bottom Sheet → Email → Opens email client ✓
                         → Phone → Opens dialer ✓
                         → Chat → Routes to chat ✓
                         → WhatsApp → Opens WhatsApp ✓
```

### Scenario 2: User missing WhatsApp
```
User → FAB → Bottom Sheet → WhatsApp → Exception caught
                                      → SnackBar: "WhatsApp not available"
```

### Scenario 3: User on device without phone capability
```
User → FAB → Bottom Sheet → Phone → Exception caught
                                   → SnackBar: "Phone not available"
```

### Scenario 4: Network issue (if backend check needed)
```
User → FAB → Loading → Service error → Catch block
                                      → Show error message
```

## Performance Considerations

- ✅ No async wait on UI render
- ✅ Lightweight service (no state management)
- ✅ Platform native implementations (fast)
- ✅ No database queries
- ✅ Minimal memory footprint
- ✅ No animation overhead

## Security Considerations

- ✅ No sensitive data in URLs
- ✅ Support email publicly visible (by design)
- ✅ Phone number in common format
- ✅ No user data shared externally
- ✅ Proper error messages (no stack traces to user)
- ✅ HTTPS used for web links
- ✅ Platform-level handling of URIs

## Accessibility

- 🔵 Icons with text labels
- 🔵 Semantic ListView structure
- 🔵 Readable font sizes
- 🔵 Good contrast ratios
- 🔵 Touch target size > 48dp
- 🔵 Error messages are clear
- 🔵 Bottom sheet dismissable

## Localization Ready

Current strings (hard-coded):
- "Get Quick Help"
- "Chat with Support"
- "Send Email"
- "Call Us"
- "WhatsApp"

**Next step**: Move to `app_strings.dart` for i18n support

