' ********** Copyright 2017 Roku Corp.  All Rights Reserved. ********** 

'Roku Advertising Framework for Video Ads Main Entry Point
function main()
    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)
    screen.show()
    scene = screen.CreateScene("VideoScene")
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
            if msg.isScreenClosed() then exit while
        end if
    end while
end function
