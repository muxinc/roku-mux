# README #

mux analytics. SDK and Sample Application for testing.

### What is this repository for? ###

This is the single source for the mux-analytics SDK for Roku.

### How do I get set up? ###

`npm install`

### To Run Sample App ###

set ip of box as env variable.

`export ROKU_DEV_TARGET=<your ip>`

`gulp install`

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

* alex@loungelogic.tv
