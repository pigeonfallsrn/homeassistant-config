# Kitchen Dashboard Backlog
_Work from top. Do not skip blocking items._

## BLOCKING
- [ ] Music popup: kiosk_mode test currently live (disabled this session). Tap music button — if popup opens, kiosk_mode was the blocker. Fix: use Bubble Card open_popup action or configure kiosk_mode allowlist for hash nav. Then re-enable kiosk_mode.
- [ ] Calendar: verify fills full right column with dense_section_placement:false — check on tablet after next reload.

## HIGH PRIORITY
- [ ] Doorbell popup: automation on event.front_driveway_door_doorbell triggers browser_mod.popup on tablet showing camera feed. Guard with input_boolean.kitchen_tablet_doorbell_popup_active. Needs browser_mod installed first.
- [ ] Advanced Camera Card (HACS id:394082552): replace all 4 picture-entity camera cards. Config: type:custom:advanced-camera-card, cameras[camera_entity+live_provider:ha], menu:mode:none, performance:profile:low
- [ ] Weather popup: tap clock-weather-card opens Bubble Card popup with 7-day native weather forecast tile + Weather Radar Card (HACS id:487680971, Makin-Things/weather-radar-card)

## MEDIUM PRIORITY
- [ ] Active lights chip: Mushroom Template chip, conditional on lights on unexpectedly in key areas. Exclude SBM switches: kitchen_chandelier_inovelli, above_sink_inovelli, kitchen_lounge_inovelli_smart_dimmer (must stay powered for Hue)
- [ ] Dim scene button: currently missing from 3-button row (Bright/Music/Night). Add as 4th or swap Music position.
- [ ] Team Tracker (HACS id:524730333, vasqued2/ha-teamtracker): MN Vikings live scores. Conditional tile visible on game days only.

## LOW PRIORITY / FUTURE
- [ ] Retire lovelace-kitchen-tablet (legacy YAML-mode dashboard — confirmed superseded by kitchen-wall-v2)
- [ ] Second room tablet using same kitchen-wall-v2 pattern
