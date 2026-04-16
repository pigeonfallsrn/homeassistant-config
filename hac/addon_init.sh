# Persistent shell init — sourced by SSH add-on on every start
# Lives at /config/hac/addon_init.sh (survives add-on updates)
cd /homeassistant
alias gs='git status'
alias gl='git log --oneline -5'
alias gpush='GIT_TERMINAL_PROMPT=0 git push origin main'
