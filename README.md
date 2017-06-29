# store_sizer plugin

[![fastlane Plugin Badge](https://rawcdn.githack.com/fastlane/fastlane/master/fastlane/assets/plugin-badge.svg)](https://rubygems.org/gems/fastlane-plugin-store_sizer)

## Getting Started

This project is a [_fastlane_](https://github.com/fastlane/fastlane) plugin. To get started with `fastlane-plugin-store_sizer`, add it to your project by running:

```bash
fastlane add_plugin store_sizer
```

## About store_sizer

Estimates download and install sizes for your app, optionally checks and raise an error if the size exceeds given thresholds.

Some apps, specially games, struggle to keep their download sizes below the **100Mb** limit, due to carrier network download limits on iOS, however the way people usually get around it is to send the build to iTunesConnect and later check the sizes reported by Apple.

It works by **simulating the Apple encryption** of the app executable (random bytes are written to the TEXT segments of the executable file), plus some artificially added files, followed by an ad-hoc export of the archive with the exportOptionsPlist thinning set to _thin-for-all-variants_

Also check for Apple's [executable size constaints](https://developer.apple.com/library/content/documentation/LanguagesUtilities/Conceptual/iTunesConnect_Guide/Chapters/SubmittingTheApp.html)

Requires the Xcode _.xcarchive_, currently only **iOS** is supported.

### Actions
#### `store_size_xcarchive`
Simulates encryption and returns a hash containing the reported size for all variants plus some info about the executable.

Parameters:
- `archive_path`: path to your .xcarchive

#### `store_size_xcarchive_check`
Checks executable size constraints and max download size, raise an error if exceeded.

Parameters:
- `report`: hash reported by the `store_size_xcarchive` action
- `ignore_universal`: should the universal variant be ignored? true per default (only devices <= iOS 8 uses the universal variant)
- `max_wifi_size`: overrides default 100Mb size check, pass 0 to disable wi-fi download size check

## Example

Check out the [example `Fastfile`](fastlane/Fastfile) to see how to use this plugin.

Unfortunately an example _.xcarchive_ can't be supplied since it will require distributing a signed executable, you will need to use your own.

Try it by cloning the repo, running `fastlane install_plugins` and `bundle exec fastlane test archive_path:YourArchive.xcarchive`.

## Run tests for this plugin

To run both the tests, and code style validation, run

```
rake
```

To automatically fix many of the styling issues, use
```
rubocop -a
```

## Issues and Feedback

For any other issues and feedback about this plugin, please submit it to this repository.

## Troubleshooting

If you have trouble using plugins, check out the [Plugins Troubleshooting](https://docs.fastlane.tools/plugins/plugins-troubleshooting/) guide.

## Using _fastlane_ Plugins

For more information about how the `fastlane` plugin system works, check out the [Plugins documentation](https://docs.fastlane.tools/plugins/create-plugin/).

## About _fastlane_

_fastlane_ is the easiest way to automate beta deployments and releases for your iOS and Android apps. To learn more, check out [fastlane.tools](https://fastlane.tools).
