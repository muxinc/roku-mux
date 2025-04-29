# README #

mux analytics. SDK and Sample Application for testing.

The version number is found in src/mux-analytics.brs

### What is this repository for? ###

This is the single source for the mux-analytics SDK for Roku.

### Releasing ###

Releasing this SDK is handled via *Releases* (tags, more specifically). To release a feature:

1) Merge any feature changes and bug fixes that you want. You can merge individual PRs to master in any order; until you make a Release, nothing will be pushed to production.
2) In your last PR to make a release, bump the version in `src/mux-analytics.brs` _and_ in `package.json`. It's important that these are the same: the version in `mux-analytics.brs` controls the version of the SDK for Mux Data, and the version in `package.json` controls the version where it is deployed on src.litix.io.
3) Once all bug fixes and features are merged, and the versions updated, cut a Release from within Github. Specify a new tag off of `master`, with the name `v2.0.2` (or whatever version you're releasing). This will kick off a deploy through buildkite, hosting the updated script in the correct location.

### How do I get set up? ###

You will need golang to build the tool used to build, run and test. Once you have installed golang run
`go build`
Then "test_runner" or "test_runner.exe" will be built depending on your platform.

Edit local.properties to reflect the setup of your roku device. You can also use environment variables.

Linting (optional) requires installing [BSLint](https://github.com/rokucommunity/bslint) and dependencies. (Note this is different from the previously used linter also called BSLint).

Install the linter is:

`npm install brighterscript @rokucommunity/bslint`

**Development Environment**

Visual Studio Code has an [extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) for BrightScript that provides syntax highlighting, linting, and debugging. To install and configure this functionality:

Install [BrighterScript](https://github.com/rokucommunity/brighterscript), which provides a BrightScript compiler and CLI. 

`npm install brighterscript --location=global`

Install [BSLint](https://github.com/rokucommunity/bslint):

`npm install @rokucommunity/bslint`

Install the [BrightScript Language extension](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) for Visual Studio Code.

You should now see syntax highlighting and other Roku tools in Visual Studio Code.

### To Run Sample App ###

To simply run the sample app on a physical device, set ip of box in local.properties.

`./test_runner install`

- or -

To remote debug the sample app on a physical device from within VS Code, be sure to install the [BrightScript Language](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) VS Code extension.

After that, launch the "BrightScript Debug: Launch" configuration from the "Run and Debug" section in VS Code.

### Exploring the example code

An example channel with a mux integration is available in the [sampleapp_source](https://github.com/muxinc/roku-mux/tree/master/sampleapp_source) folder. The components belonging to the interactive sample app can be found in [sampleapp_source/components_reset](https://github.com/muxinc/roku-mux/tree/master/sampleapp_source/components_reset/components)

### Configuration ###

Please configure mux settings in manifest.

`mux_dry_run` - Will not send actual requests  
`mux_base_url` - Baseurl of all mux requests  
`mux_debug_events` = none: show nothing, partial: ignores progress events, full: Show all  
`mux_debug_beacons` = none: show nothing, partial: ignores beacon properties, full: Show everything  

### To Run Unit Tests ###

`./test_runner test`

### To Run Linter ###

`./test_runner lint`

Other useful tasks are defined in the `test_runner.go` file.

### Who do I talk to? ###

* help@mux.com

### Instructions ###

There are 5 possible options to set in the manifest of any app which uses mux.

```
mux_dry_run=true
mux_base_url=http://img.litix.io
mux_debug_events=none
mux_debug_beacons=full
mux_minification=false
```

`mux_dry_run` - If true, will not send any actual requests. This is to stop us hammering the server during testing.
`mux_base_url` - Set to http if you want to see reqs in charles.
`mux_debug_events` - Debugs the events as they are created. [none, partial, full]
`mux_debug_beacons` - Debugs the beacons as they are created.[none, partial, full]
`mux_minification` - Turns minification on or off, set to false for more readable outputs.

If you leave these unset. They will default to the following settings.

`mux_dry_run` - false
`mux_base_url` - https://img.litix.io
`mux_debug_events` - none
`mux_debug_beacons` - none
`mux_minification` - true
