# lid

Keep your Mac awake with the lid closed, for as long as you choose. macOS only.

## Install

Paste this in Terminal:

```
curl -fsSL https://raw.githubusercontent.com/mijanlab/lid-on/main/install.sh | sh
```

It asks for your Mac password **once**. After that, `lid` never asks again.

## Use

| Command | What it does |
|---|---|
| `lid on-120` | Stay awake with the lid closed for 120 minutes (any number works) |
| `lid check` | Show if it is on and how much time is left |
| `lid off` | Go back to normal sleep now |
| `lid help` | List all commands |

Example: `lid on-90`, close the lid, and your Mac keeps running for 1h 30m. Then it goes back to normal sleep on its own.

## Notes

- Don't leave a running Mac closed inside a bag. It gets hot.
- If you see "run lid setup", run `lid setup` in Terminal and enter your password once.

## Uninstall

```
sudo rm /usr/local/bin/lid /etc/sudoers.d/lid
```

## How it works

`lid setup` adds one sudo rule that allows only `pmset -a disablesleep 0` and `pmset -a disablesleep 1` without a password. Nothing else is changed.
