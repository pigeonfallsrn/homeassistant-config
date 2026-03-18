# Kitchen Dashboard Backlog
_Work from top. Do not skip blocking items._

## BLOCKING
- [ ] Calendar: verify fills full right column after dense_section_placement:false (needs tablet check)
- [ ] Music popup: test with kiosk_mode:{} temporarily to confirm it intercepts hash nav. If confirmed, fix by using Bubble Card open_popup or allow-list nav in kiosk config.

## HIGH PRIORITY
- [ ] Doorbell popup: automation on event.front_driveway_door_doorbell → browser_mod.popup on tablet showing camera feed. Guard with input_boolean.kitchen_tablet_doorbell_popup_active. Needs browser_mod installed first.
- [ ] Advanced Camera Card (HACS id:394082552): replace all 4 picture-entity camera cards. Config: type:custom:advanced-camera-card, cameras[camera_entity+live_provider:ha], menu:mode:none, performance:profile:low
- [ ] Weather popup: tap clock-weather-card → Bubble Card popup with 7-day native weather forecast tile + Weather Radar Card (HACS id:487680971, Makin-Things/weather-radar-card)

## MEDIUM PRIORITY
- [ ] Active lights chip: Mushroom Template chip, conditional on lights on unexpectedly in key areas. Exclude SBM switches: kitchen_chandelier_inovelli, above_sink_inovelli, kitchen_lounge_inovelli_smart_dimmer (they must stay powered for Hue)
- [ ] Team Tracker (HACS id:524730333, vasqued2/ha-teamtracker): MN Vikings live scores. Conditional tile visible on game days only via state_class sensor.

## LOW PRIORITY / FUTURE
- [ ] Retire lovelace-kitchen-tablet (legacy YAML-mode dashboard — confirmed superseded)
- [ ] Second room tablet using same kitchen-wall-v2 pattern
- [ ] Dim scene button: currently missing from 3-button row (Bright / Music / Night). Consider adding as 4th button or replacing Music button position.
