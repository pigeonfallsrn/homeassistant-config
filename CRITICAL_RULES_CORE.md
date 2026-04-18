
## NEVER RULES — INFRASTRUCTURE SAFETY

NEVER: UniFi network topology (VLANs, port power, firewall rules,
port profiles) is manual UniFi-UI only. HA integrations may READ
UniFi state but NEVER write. Lockout risk.

NEVER: Create a UI helper without both a label AND a meaningful
entity_id in the same session. Auto-IDs like
input_boolean.new_input_boolean_2 become untrackable dark matter
in gitignored .storage. Weekly registry snapshot diff surfaces
unnamed helpers.
