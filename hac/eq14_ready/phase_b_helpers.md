# Phase B: Helper Rebuild — EQ14 Deployment Playbook
## S13B | 91 helpers + 11 template sensors, grouped by migration group

## TRIAGE: 110 on Green → 93 KEEP, 6 DROP, 11 → Templates

## DROP (6 booleans → consolidated into input_select.house_mode)
house_sleep_mode, house_guest_mode, house_vacation_mode,
house_cleaning_mode, party_mode, maintenance_mode
→ Replaced by house_mode options: Normal/Sleep/Guest/Vacation/Cleaning/Party/Maintenance

## CONVERT TO TEMPLATES (11 presence booleans, all "unavailable" on Green)
john_home, alaina_home, ella_home, michelle_home, someone_home,
girls_home, both_girls_home, john_and_girls, john_and_michelle,
full_house, recent_motion
→ Build as UI Template binary_sensors in Group 0

## GROUP 0 — Infrastructure (17 helpers)
input_select: House Mode, Occupancy Mode, Alarm Mode
input_boolean: Hot Tub Mode, Extended Evening, Preserve Night Vision,
  Dad Awake, Dad Bedtime Mode, Guest Present, Quiet Hours Active,
  Critical Alerts Only, Good Morning Routine Active, Good Night Routine Active,
  Leaving Home Routine Active, Arriving Home Routine Active
input_datetime: Last Good Morning Routine, Last Good Night Routine

## GROUP 1 — Entry Room (4)
input_boolean: Entry Room Manual Override
input_number: Entry Room Scene Index (0-10), Entry Room Lux Threshold (0-500 lx)
input_datetime: Entry Room Last Manual Change

## GROUP 2 — Kitchen (10)
input_boolean: Kitchen Manual Override, Kitchen Lounge Manual Override,
  Kitchen Tablet Doorbell Popup Active, Kitchen Tablet Screen Control
input_number: Kitchen Table Scene Index, Kitchen Lounge Scene Index,
  Kitchen Lounge Lux Threshold
input_select: Kitchen Lighting Scene (Off/Bright/Cooking/Dining/Evening/Night Light)
input_datetime: Kitchen Last Manual Change
timer: Kitchen Override Timer (30 min)

## GROUP 3 — Living Room (6)
input_boolean: Living Room Manual Override
input_number: LR Hue All Lamps Scene Index, LR Hue Floor Lamps Scene Index,
  LR Hue Table Lamps Scene Index, Living Room Lux Threshold
input_datetime: Living Room Last Manual Change

## GROUP 4 — Garage (11)
input_boolean: Garage Auto-Close Enabled, Garage Auto-Open Enabled,
  Garage Alert Acknowledged, Garage Manual Override
input_number: Garage Light Auto-Off Timer (min), Front Driveway Scene Index
input_datetime: Last Garage Opened, Last Garage Closed, Last Garage Alert,
  Garage North Snooze Until, Garage South Snooze Until
timer: Garage Light Timer (10 min)
counter: Garage Opens Today

## GROUP 5 — Upstairs (9)
input_boolean: 1st Floor Bathroom Manual Override, 2nd Floor Bathroom Manual Override,
  2nd Floor Bathroom Fan Manual Override, Master Bedroom Manual Override,
  Pause Bathroom Fan (Low Humidity), Bathroom Fan Paused
input_number: Bathroom Scene Index
input_datetime: Bathroom Fan Pause Until
timer: Manual Override Timeout (60 min)

## GROUP 6 — Kids (22)
input_boolean: Ella/Alaina Had Activity Today, Ella/Alaina Skip Wind-down Tonight,
  Ella/Alaina Bedroom Override, Kids Wake Lights Enabled, Kids Bedtime Override,
  School Tomorrow, School In Session Now, Kids Expected Away Now,
  Kids Bedroom Manual Override, Alaina LED Strips
input_number: Ella/Alaina/Jarrett/Owen Current Grade (0-12)
input_select: Ella Sleep Timer (Off/15/30/45/60 min)
input_datetime: Ella/Alaina Last Arrived Home, Ella/Alaina Wake Override

## GROUP 7 — Climate: 0 new (uses Group 5 fan helpers)
## GROUP 8 — Security (7): Security/Door alerts enabled, Water valve auto shutoff,
  Last Critical Alert, counters: Doorbell/Motion/Critical Alerts Today
## GROUP 9 — AV (2): Adaptive Lighting Mode select, Back Patio Scene Index
## GROUP 10 — Notifications: 0 new (uses Group 0 helpers)
## GROUP 11 — Utilities (3): AI Context Pending, Sheets Export In Progress,
  Guest Mode Auto-Disable Timer (24h)
