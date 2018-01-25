' ********** Copyright 2017 Roku Corp.  All Rights Reserved. ********** 

'Roku Advertising Framework for Video Ads Main Entry Point
function main()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)
    screen.show()
    gAA = GetGlobalAA()
    gAA.whatAmI = "zanders globalAA"
    m.global = screen.getGlobalNode()
    success1 = m.global.addFields( {whereAmIFrom: "dundee and shit"} )
    success2 = m.global.addField("whatIsMyPurpose", "string", true)
    success2 = m.global.setField("whatIsMyPurpose", "to live, to love")
    Print "[Main] success1|success2: ",success1, success2
    Print "[Main]        gAA: ",gAA
    ' Print "[Main] gAA.global: ",gAA.global
    scene = screen.CreateScene("VideoScene")
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then exit while
        end if
    end while

end function
