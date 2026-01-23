# Property, Business & Network Infrastructure

## PERSONAL RESIDENCE
**Address**: 40154 US Highway 53, Strum, WI  
**Zone Name**: "home"  
**WiFi**: Primary SSID (main network)  
**Residents**: John Spencer, Alaina Spencer, Ella Spencer  
**Network**: UniFi UDM-PRO (192.168.1.1)

---

## BUSINESS ENTITIES

### 1. Pigeon Falls Lawn Care & Snow Removal, LLC
**Abbreviation**: PFLC  
**Email**: PigeonFallsLawnCare@gmail.com  
**Business Type**: Service (lawn care, mowing, snow plowing)  
**Operations Base**: 40003 Commercial Ave (Big Garage)

### 2. Pigeon Falls Properties, LLC
**Abbreviation**: PFP  
**Email**: PigeonFallsProperties@gmail.com  
**Business Type**: Real estate holdings & property management  
**Operations Base**: 40003 Commercial Ave (Big Garage)

---

## PFP PROPERTY HOLDINGS

### Active Rentals:
1. **40062 US Highway 53** ("Michelle's House" / "Residential Rental")
   - Tenant: Michelle + Jarrett + Owen
   - WiFi SSID: "Goetting" (guest network)
   - Network: UniFi bridge connection to main network
   - 3 houses down from John's residence

2. **40021 Anderson Street** ("Orange Pole Building")
   - Type: Older Morton-built pole building (orange)
   - Status: Rented out
   - Adjacent parcel: Also owned by PFP

### Operations Facility:
3. **40003 Commercial Avenue** ("Big Garage")
   - Type: Climate-controlled storage facility
   - Use: Operations center for PFLC + PFP
   - WiFi SSID: "PFP" (separate network)
   - Network: UniFi cameras + bridge connection
   - Adjacent ag-zoned parcels: Owned by PFP

### Vacant Lots (Development Pipeline):
4. **Winsand Drive Lot #1** (Pigeon Falls)
   - Utilities: Water + Sewer
   - Zoning: Residential
   - Status: Vacant, ready for development

5. **Winsand Drive Lot #2** (Pigeon Falls)
   - Utilities: Water + Sewer
   - Zoning: Residential
   - Status: Vacant, ready for development

6. **Church Street Lot** (Pigeon Falls) ⭐ PRIME LOCATION
   - Utilities: Water + Sewer + Walk-out basement potential
   - Zoning: Residential
   - Future Goal: Build duplex (rental property)
   - Reference: Adjacent duplex as model
   - Status: Vacant, development-ready

### Agricultural Parcels:
- Multiple ag-zoned parcels around 40003 Commercial Ave
- Parcel adjoined to 40021 Anderson St property

---

## NETWORK ARCHITECTURE

### Primary Hub: 40154 US Highway 53 (Home)
- **Hardware**: UniFi UDM-PRO (192.168.1.1)
- **Main Controller**: All sites managed from here
- **VLANs**: IoT, LAN, Guest configured
- **Integration**: Full HA integration ✅

### Site 1: 40062 US Highway 53 (Michelle's House)
- **Connection**: UniFi bridge to main network
- **WiFi SSID**: "Goetting"
- **Guest Network**: VPN-enabled
- **Distance**: 3 houses down from main hub
- **Cameras**: TBD (if any)

### Site 2: 40003 Commercial Ave (Big Garage)
- **Connection**: UniFi bridge (UBB) to main network
- **WiFi SSID**: "PFP"
- **UniFi Protect Cameras**: Active (monitoring storage/operations)
- **Use**: Business operations + climate-controlled storage
- **HA Integration**: Same network, accessible from home

### Site 3: 40021 Anderson St (Orange Pole Building)
- **Status**: Rental property (no known HA integration)
- **Network**: TBD

---

## UNIFI PROTECT CAMERA LOCATIONS

### Home (40154 US Highway 53):
- Very Front Door (High Res + Package Camera) ✅
- Front Driveway Door (High Res + Package Camera) ✅
- Back Yard (G4 Bullet) ✅

### Big Garage (40003 Commercial Ave):
- **Cameras**: Need to identify which cameras monitor this location
- **Purpose**: Security for storage facility + operations

### Unavailable/Needs Troubleshooting:
- AI Theta cameras (2x) - Kitchen + unknown location
- G6 Bullet - unknown location
- Third Party Camera

---

## HOME ASSISTANT ZONE RECOMMENDATIONS
```yaml
# Current Zones
zone:
  - name: home
    latitude: [40154 US Highway 53 coordinates]
    longitude: [coordinates]
    radius: 100
    icon: mdi:home

# Recommended Additional Zones
zone:
  - name: Michelle's House
    latitude: [40062 US Highway 53 coordinates]
    longitude: [coordinates]
    radius: 50
    icon: mdi:home-account
    
  - name: Big Garage
    latitude: [40003 Commercial Ave coordinates]
    longitude: [coordinates]
    radius: 75
    icon: mdi:warehouse
    
  - name: Orange Building
    latitude: [40021 Anderson St coordinates]
    longitude: [coordinates]
    radius: 50
    icon: mdi:barn
```

---

## AUTOMATION OPPORTUNITIES

### Property Management:
1. **Big Garage Security**
   - Camera motion detection when facility closed
   - Temperature monitoring (climate-controlled)
   - After-hours access alerts

2. **Rental Property Monitoring**
   - Michelle's house: Basic presence/away detection
   - Network usage monitoring for maintenance scheduling

3. **Business Operations**
   - Track when John is at Big Garage vs Home
   - Equipment/vehicle tracking (if applicable)
   - Climate control automation for storage facility

### Family Presence Detection:
- Multi-site presence: Home / Michelle's House / Big Garage
- SSID-based location: Primary SSID = Home, Goetting = Michelle's, PFP = Big Garage

### Development Pipeline Tracking:
- Placeholder automations for future duplex on Church St
- Vacant lot status tracking (when utilities activated, etc.)

---

## NETWORK SSID SUMMARY
| SSID | Location | Purpose |
|------|----------|---------|
| Primary | 40154 US Hwy 53 | Home network |
| Goetting | 40062 US Hwy 53 | Michelle's house guest network |
| PFP | 40003 Commercial Ave | Big Garage operations/storage |

---

## BUSINESS EMAIL ACCOUNTS
- **PFLC**: PigeonFallsLawnCare@gmail.com
- **PFP**: PigeonFallsProperties@gmail.com
- **Personal**: pigeonfallsrn@gmail.com

---

## FUTURE DEVELOPMENT GOALS
1. **Church Street Duplex** (PFP)
   - Model: Adjacent duplex
   - Features: Walk-out basement
   - Timeline: TBD
   - Automation potential: Smart rental unit with HA integration

2. **Winsand Drive Lots** (PFP)
   - 2 lots available for development
   - Utilities ready (water + sewer)
