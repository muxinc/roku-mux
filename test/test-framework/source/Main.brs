function Main()

    print "#######################"
    print "       Running unit tests!          "
    print "#######################"

    ' Debug().initialise(Debug().FILTER_NONE)

    screen = createObject("roSGScreen")
    port = createObject("roMessagePort")
    screen.setMessagePort(port)
    screen.show()

    scene = screen.CreateScene("MuxAnalytics")
    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent"
        end if
    end while

    print "########################"
    print "        Test suite complete         "
    print "########################"

end function
