# Update: Firefox v138

As of Firefox v138, [Expand Vertical Tabs on Hover](#expand-vertical-tabs-on-hover) no longer works, and I can't figure out how to fix it with plain CSS. However, a similar feature is now available natively. To use it, set the following options in `about:config`.

| Setting | Value | Description |
| --- | --- | --- |
| sidebar.verticalTabs | true | Enable vertical tabs |
| sidebar.visibility | expand-on-hover | Make the vertical tabs expand when you hover over them |
| sidebar.revamp | true | Should be automatically enabled when you enable vertical tabs |
| sidebar.animation.expand-on-hover.duration-ms | 50 | Speed up the animation when expanding the sidebar (optional, it's quite slow by default) |

# Firefox CSS Tweaks

A collection of CSS tweaks for Firefox to customize its appearance and behavior. These tweaks are applied using the `userChrome.css` file, which allows for customizing the browser's UI.

## Table of Contents
- [Tweaks](#tweaks)
	- [Expand Vertical Tabs on Hover](#expand-vertical-tabs-on-hover)
	- [Better Active Tab Indicator](#better-active-tab-indicator)
- [Installation](#installation)
	- [1. Enable `userChrome.css` Support](#1-enable-userchromecss-support)
	- [2. Find the User Profile Folder](#2-find-the-user-profile-folder)
	- [3. Apply Tweaks](#3-apply-tweaks)
- [Customization](#customization)

## Tweaks

### Expand Vertical Tabs on Hover

This tweak enables vertical tabs in Firefox to automatically expand when hovering over them, displaying full tab titles with a smooth animation. This is a fork of [ENDE25/FIREFOX-tabs-hover-expand](https://github.com/ENDE25/FIREFOX-tabs-hover-expand).

#### Features

- Narrow tabs sidebar with icons only by default
- Full tabs with title and close button on hover
- Smooth animation when expanding tabs
- Support for pinned tabs
- Support for tab groups
- Sidebar expands over the content area instead of pushing it
- Faster animation times than the original version
- Slightly wider expanded width than the original version

#### Demo
![Demo](/demos/expand-vertical-tabs-on-hover/demo.webp)

#### Known Issues

- The button to expand/collapse the sidebar will no longer work. This is because if this customization would respect it, tabs would remain expanded when the mouse leaves the sidebar, which is not the desired behavior. This would happen because FireFox automatically adds the `expanded` attribute when the button is clicked **and** when the mouse is over the sidebar. This prevents the CSS from distinguishing between the two cases, so instead it simply ignores the `expanded` attribute and only reacts to `:hover`.

### Better Active Tab Indicator

This tweak improves the visual indication of the currently active tab in Firefox. It provides a more pronounced indicator for the active tab compared to the default styling. This tweak is only for vertical tabs.

#### Features

- Enhanced visibility of the active tab
- Customizable color and width

#### Demo
![Demo](/demos/better-active-tab-indicator/demo.png)

## Installation

### Firefox Settings

For these tweaks to work, you must change some settings in Firefox. Go to `about:config` and set the following preferences:

Setting | Value | Description | Required By
--- | --- | --- | ---
`toolkit.legacyUserProfileCustomizations.stylesheets` | `true` | Enable `userChrome.css` support | All tweaks
`sidebar.verticalTabs` | `true` | Enable vertical tabs | `expand-vertical-tabs-on-hover`, `better-active-tab-indicator`
`sidebar.visibility` | `always-show` | Always show the sidebar | `expand-vertical-tabs-on-hover`, `better-active-tab-indicator`


### Automatic Installer (Linux)

To install/upgrade any or all of these tweaks automatically on Linux, you can use the provided `install.sh` script.

```sh
curl -s https://raw.githubusercontent.com/abrahammurciano/firefox-css-tweaks/main/install.sh | bash -s install
```

The installer will prompt you to select which firefox profile you want to install the tweaks to as well as which tweaks you want to enable. Use `--all-tweaks`, `--all-profiles`, or `--all` to install all tweaks, to all profiles, or both respectively.

To uninstall the tweaks, run the script replacing `install` with `uninstall`.

### Manual Installation

To install any or all of these tweaks manually, you must first enable `userChrome.css` support in Firefox and then copy the desired CSS files to the appropriate folders in your user profile directory. To do this, follow these steps:

### 1. Find the User Profile Folder
1. Type in the address bar: `about:support`.
1. Look for the **Profile Folder** or **Profile Directory** section and click **Open Folder** or **Open Directory**.
1. Inside the profile folder, locate (or create if it doesn't exist) a folder named `chrome`, and inside it, another folder named `tweaks`.

### 2. Apply Tweaks
1. Each tweak in this repository has its own folder under `tweaks/`. Copy the folder of the tweak you want into the `chrome/tweaks` folder in your user profile directory (the one you located/created in the previous step).
1. Copy the `userChrome.css` file from this repository into the `chrome` folder. If it already exists, append the content of this file to the existing one.
1. Uncomment the `@import` line for the tweak you want to apply in the `userChrome.css` file by removing the `/*` and `*/` around it.
1. Restart Firefox for the changes to take effect.

## Customization

Each tweak specifies its customization options in `options.css`. You can override any of these options in `custom-options.css`. This way you can customize any tweak without modifying the original CSS files, so the installation script can update them while keeping your customizations.

For example, for `expand-vertical-tabs-on-hover`, the customization options may look like this:

```css
:root {
	--tweaks-evtoh-collapsed-width: 50px;
	--tweaks-evtoh-expanded-width: 250px;
	--tweaks-evtoh-tab-padding: 10px;
	--tweaks-evtoh-tab-margin: calc((var(--tweaks-evtoh-collapsed-width) - var(--tweaks-evtoh-tab-padding) * 2 - var(--icon-size-default)) / 2);
	--tweaks-evtoh-animation-duration: 50ms;
}
```

All customization options are in the `:root` selector and start with `--tweaks-<tweak-acronym>-`. Remember to restart Firefox after making changes to the customization options for them to take effect.
