# safe-eyes-cli

## Installation

1. Clone repo
2. Add alias `safe-eyes` to shell config
3. Add autostart entry
4. Configure (needs restart): `safe-eyes config`
5. Start! `safe-eyes start`

### Fedora KDE

```
git clone https://github.com/RG9/safe-eyes-cli.git && \
echo 'alias safe-eyes='$(pwd)'/safe-eyes-cli/safe-eyes.sh' >> ~/.zshrc; source ~/.zshrc && \
mkdir -p ~/.config/autostart && \
sed "s|#MY_PATH#|$(pwd)|g" safe-eyes-cli/installation/safe-eyes-cli.desktop > ~/.config/autostart/safe-eyes-cli.desktop
```

## Usage

Install and forget.

The program is designed to automatically start on boot and pause when necessary. 

However, in certain situations, the following features may be useful:

* print usage: `safe-eyes --help`

* start and debug: `safe-eyes start --debug`

* stop: `safe-eyes stop`

## Features

- **break dialog/notification that enforces rest**, i.e. fullscreen mode, no "skip" button, prevent minimizing (currently only x11 is supported)
- **break is postponed if screen was locked** (also works after hibernation)
- **break session is AUTOMATICALLY skipped during calls** when webcam or microphone is in use
- OS can be locked during break session (use shortcut Win+L)
- audible beep sound signaling the end of a break
- customizable work and break session durations
- a separate configuration file to facilitate easy script updates in the future

## Nice to have (not implemented)

- skipping break on calls: notify on skipped break
- get rid of x11 workaround preventing skipping break
- "lock screen" button on break dialog?
- optional "skip" button? (let user decide)

## Alternatives

- https://github.com/slgobinath/SafeEyes
  - \+ many settings and extra plugins
  - \- however requires some extra dependencies on Fedora and I haven't figured out yet how to run it in toolbox container
  
- https://github.com/hovancik/stretchly
  - \+ distributed as a Flatpack
  - \- why it starts so many processes in background?

Both applications are great, but lacks some important feature:
- pause automatically during calls
