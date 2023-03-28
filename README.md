# safe-eyes-cli

### Features:
- configurable duration of work and break sessions (in source code)
- OS can be locked during break session (use shortcut Win+L)
- break dialog that forces rest, i.e. fullscreen, no "skip" button, cannot minimize (currently only x11 is supported)
- beep sound after end of break
- break session is AUTOMATICALLY skipped during calls when web camera or microphone is used
- break is postponed if screen was locked (works also from hibernation)

### Nice to have (not implemented):
- installation guide
- skipping break on calls: notify on skipped break
- get rid of x11 workaround preventing skipping break
- "lock screen" button on break dialog?
- optional "skip" button? (let user decide)