# Family Structure & Device Tracking

## PRIMARY RESIDENCE: John's House (40154 US Highway 53, Strum, WI)
**Zone Name: "home"**

### Residents:
- **John Spencer** (RN, owner)
  - Device: device_tracker.john_s_s24_ultra_4 (Samsung S24 Ultra) ✅
  
- **Alaina Spencer** (daughter)
  - Primary: iPhone 17 → device_tracker.alaina_s_iphone ✅ (needs re-login on Sunday)
  - Secondary: School-issued iPad
  - Secondary: Personal iPad
  
- **Ella Spencer** (daughter)
  - Primary: iPhone 17 ⚠️ NEEDS SETUP (target: Sunday when home)
  - Secondary: School-issued iPad
  - Secondary: Personal iPad
  - Secondary: "Mom's extra iPhone" (in Ella's possession, at home indefinitely)

### Non-residents (for reference):
- **Traci** (Alaina & Ella's mother) - No affiliation, no tracking

---

## RENTAL PROPERTY: Michelle's House (40062 US Highway 53, Strum, WI)
**Zone Name: "michelle_house" | WiFi SSID: "Goetting"**

### Residents:
- **Michelle** (family member, renter)
  - Device: device_tracker.michelle_s_iphone_14_pro (iPhone 14 Pro) ✅
  - Note: Shows "home" on both WiFi networks (same UniFi infrastructure)
  
- **Jarrett** (Michelle's son, placeholder)
  - Device: Android tablet (not yet integrated into HA)
  - Future: May get phone in several years
  
- **Owen** (Michelle's son, placeholder)
  - Device: Android tablet (not yet integrated into HA)
  - Future: May get phone in several years

---

## Network Architecture
- **Primary location**: 40154 US Highway 53 (John's house)
- **Rental property**: 40062 US Highway 53 (Michelle's house, 3 houses down)
- **Network**: Single UniFi infrastructure (UDM-PRO, VLANs configured)
- **SSIDs**: Primary SSID at John's house + "Goetting" SSID at Michelle's house
- **Tracking behavior**: Both houses register as "home" zone for device_tracker entities

## Device Status Summary
✅ **Active & Linked:**
- John: Samsung S24 Ultra
- Alaina: iPhone 17 (needs re-login Sunday)
- Michelle: iPhone 14 Pro

⚠️ **Needs Setup:**
- Ella: iPhone 17 (install HA Companion app on Sunday)

📋 **Placeholder (Future):**
- Jarrett: Android tablet (no HA integration yet)
- Owen: Android tablet (no HA integration yet)

🔌 **Untracked Devices:**
- Alaina's school iPad
- Alaina's personal iPad
- Ella's school iPad
- Ella's personal iPad
- "Mom's extra iPhone" (at John's house, in Ella's possession)

## Action Items
1. **Sunday**: Re-login Alaina's iPhone 17 to HA Companion app
2. **Sunday**: Setup Ella's iPhone 17 with HA Companion app
3. **Optional**: Create "michelle_house" zone in HA for granular location tracking
4. **Future**: Create person entities for Jarrett & Owen when devices have HA integration

## Zone Configuration Recommendation
```yaml
# configuration.yaml or zones.yaml
zone:
  - name: Michelle's House
    latitude: [Michelle's house coordinates]
    longitude: [Michelle's house coordinates]
    radius: 50
    icon: mdi:home-account
```
This would allow distinguishing "at John's house" vs "at Michelle's house" for Michelle, Jarrett, and Owen.
