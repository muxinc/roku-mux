# README #

mux analytics. SDK and Sample Application for testing.

### What is this repository for? ###

This is the single source for the mux-analytics SDK for Roku.

### How do I get set up? ###

`npm install`

### To Run Sample App ###

To simply run the sample app on a physical device, set ip of box as env variable.

`export ROKU_DEV_TARGET=<your ip>`

`gulp install`

- or -

To remote debug the sample app on a physical device from within VS Code, be sure to install the [BrightScript Language](https://marketplace.visualstudio.com/items?itemName=RokuCommunity.brightscript) VS Code extension.

You can configure the target device host and password using an `.env` file (make a copy of the `sample.env` file).  Leaving the defaults will cause the extension to prompt for input when running the debugger.  You can also hardcode the values in the `.env` file.

After that, launch the "BrightScript Debug: Launch" configuration from the "Run and Debug" section in VS Code.

### Configuration ###

Please configure mux settings in manifest.

`mux_dry_run` - Will not send actual requests  
`mux_base_url` - Baseurl of all mux requests  
`mux_debug_events` = none: show nothing, partial: ignores progress events, full: Show all  
`mux_debug_beacons` = none: show nothing, partial: ignores beacon properties, full: Show everything  


### To Run Unit Tests ###

`gulp test`

### To Run Linter ###

`gulp lint`

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
