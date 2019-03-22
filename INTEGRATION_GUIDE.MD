Mux Data is the best way to monitor video streaming performance.

Integration is easy - just initialize the Mux SDK, pass in some metadata, and you're up and running in minutes.

### 1. Getting Started

This documents integration instructions for Roku. For other players, see the additional Integration Guides.


### 2. Architecture
Mux's Roku integration supports Roku SceneGraph applications, in conjunction with standard `Video` nodes. Mux runs as a `Task` alongside the `Video` node, and supports instances where the `Video` nodes are reused with additional content as well as when the `Video` nodes are reset between content.

### 3. Include the SDK
Place the SDK file in your libs folder. The latest version of the SDK can be found at https://src.litix.io/roku/0/mux-analytics.brs.

### 4. Setup a new Mux Task
Create a new `Task` XML named `MuxTask.xml` inside your `components` folder and give it the following interface. This is used to link the `mux-analytics.brs` file into your application.

```xml
<component name="MuxTask" extends="Task">
  <interface>
    <field id="video" type="node" alwaysNotify="true"/>
    <field id="config" type="assocarray" alwaysNotify="true"/>
    <field id="rafEvent" type="assocarray" alwaysNotify="true"/>
    <field id="error" type="assocarray" alwaysNotify="true"/>
    <field id="view" type="String" alwaysNotify="true"/>
    <field id="exit" type="Boolean" alwaysNotify="true"/>
  </interface>
  <script type="text/brightscript" uri="pkg:/libs/mux-analytics.brs"/>
</component>
```

### 5. Setup the task to respond to video events
Within your main application, create the Mux Task node, and pass the `Video` node that you are tracking to it. This should be done before the content is set into the `Video` node so that Mux can track the load process.

```
m.mux = m.top.CreateNode("mux")
m.mux.setField("video", m.video)

muxConfig = {
  property_key: "EXAMPLE_PROPERTY_KEY",
}

m.mux.setField("config", muxConfig)
m.mux.control = "RUN"

' Load the video into the Video node (e.g. `m.video.content = contentNode`)
```

### 6. Test It
After you've integrated, start playing a video in the player you've integrated with. A few minutes after you stop watching, you'll see the results in your Mux account. We'll also email you when your first video view has been recorded.

You can also test that Mux is receiving data in the Mux Data dashboard. Login to the dashboard and find the environment that corresponds to your property_key and look for video views.

Note that it may take a few minutes for views to show up in the Mux Data dashboard.

### 7. Debugging

To help you with the integration process and ensure you have successfully incorporated the SDK within your player, we have provided a number of optional manifest attributes. Those attribute can help you better understand how the MUX SDK event tracking works as well as show you the actual data being collected. Some of the benefits of using some of the debugging attributes (mentioned below) are that you will be able to see instantly the SDK events and data collected as it occurs.

---

#### mux_debug_events

##### Values
`full`, `partial` or `none`

##### Description
Outputs the event at the time it occurs.

##### Example output

Property set to `partial`: 

`[mux-analytics] EVENT playerready`

Property set to `full`:

```javascript
[mux-analytics] EVENT playerready 
{
  pmxpive: 0.0.11,
  ake: ,
  ualve: 9.00,
  e: playerready
}
```
---
#### mux_minification

##### Values
`true` or `false`

##### Description
Transforms the data property keys to a user friendly format so you can see and understand what is actually captured and sent and determine if the values are what they are expected to be.

**NOTE:** If minification is set to false the data will not be recognized and used.

##### Example output

Property set to `false`:

```json
{  
  "events": [{
    "Beacon_domain": "litix.io",
    "e": "playerready",
    "mux_api_version": "2.0",
    "player_country_code": "GB"
  }]
}
``` 

Property set to `true`:   

```json
{   
  "events": [{     
    "ake": "",     
    "bdm": "litix.io",     
    "e": "play",     
    "mapve": "2.0",     
    "pcycd": "GB"
  }]
}
```
#### mux_debug_beacons

##### Values
`full`, `partial` or `none`

##### Description
Outputs the data (full) or event(s) (partial) that is being sent (at the time of sending).

##### Example output

None                                                                       

----

#### mux_base_url

##### Values
Protocol + domain name. Eg. `https://img.litix.io`

##### Description
Controls to which domain the data should be sent. Useful for environmental builds of your project

##### Example output

None

----


### 8. Add Metadata
The Roku SDK supports adding metadata via two different mechanisms.

The majority of the metadata should be passed inside the `muxConfig` object that is passed to the Mux Task. You can read detailed information about the fields that are supported in [Metadata](https://docs.mux.com/v1/docs/metadata). To update any field, update this within `muxConfig` and then call `m.mux.setField("config", muxConfig)`.

Some other underlying information is mapped from standard [Roku content metadata](https://sdkdocs.roku.com/display/sdkdoc/Content+Meta-Data), most of which you probably already set when creating your video. In particular, the metadata fields that you should set (if you do not already) are:
 - *ContentType*
 - *Url*
 - *Live*
 - *StreamFormat*
 - *Length*

### 9. Advertising Configuration
If advertising is to be used, you must send the appropriate events to the Mux Task, as shown below.

```
function setUpRokuAdFramework
  adIface.SetTrackingCallback(adTrackingCallback, adIface)
end function

function adTrackingCallback(obj = Invalid as Dynamic, eventType = Invalid as Dynamic, ctx = Invalid as Dynamic)
  m.mux = GetGlobalAA().global.findNode("mux")
  m.mux.setField("rafEvent", {obj:obj, eventType:eventType, ctx:ctx})
end function
```

### 10. Additional Configuration
In some situations, it is necessary to directly signal the beginning or ending of a `view` to Mux. This is necessary when the `Video` Node is recycled (i.e. more pieces of content are loaded into the same Video node), or when using advertising, as the ads run outside of the lifecycle of the Video.

Note: A `view` is defined as the user watching a single piece of _content_, which includes any advertising.

```
mux = GetGlobalAA().global.findNode("mux")

' To signal the start of a view:
mux.setField("view", "start")

' To signal the end of a view:
mux.setField("view", "end")
```
