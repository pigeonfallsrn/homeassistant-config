# Quick onboarding text for ChatGPT/Gemini
# Run from PowerShell: .\Get-AIOnboarding.ps1

$text = @"
Hi! I'm John. I use Claude, ChatGPT, and Gemini for Home Assistant.

Read AI_INSTRUCTIONS.md in my Google Drive AI_Context folder first.

I'm pasting my hac output (40-line diagnostic). Work with me:
- ONE command at a time
- ha core check before restart
- Reference baseline when needed  
- Remind me: haclearn "what we solved"

Style: Direct, technical, no hand-holding.

Here's my hac output:

"@

Set-Clipboard -Value $text
Write-Host "✅ Onboarding copied! Paste to ChatGPT/Gemini, then paste your hac output" -ForegroundColor Green
