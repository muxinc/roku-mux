'Channel entry point
sub RunUserInterface(args)
    Print "[Main]",args.RunTests
    APPInfo = createObject("roAPPInfo")
    'if channel is in dev mode and in deep linking parameters was specified RunTests parameter as true
    'then we run test cases, that is specified in folder pkg:/source/tests
    
    'screen, scene and port initialization
    m.screen = CreateObject("roSGScreen")
    m.scene = m.screen.CreateScene("VideoScene")
    m.port = CreateObject("roMessagePort")
    'getting acess to global node
    m.global = m.screen.getGlobalNode()

    'Set the roMessagePort to be used for all events from the screen.
    m.screen.SetMessagePort(m.port)

    'Show Scene Graph canvas that displays the contents
    'of a Scene Graph Scene node tree
    m.screen.Show()


    if args.RunTests = "true" and type(TestRunner) = "Function" then
    Print "[Main]2"
        Runner = TestRunner()
        Runner.logger.SetVerbosity(2)
        Runner.logger.SetEcho(true)
        Runner.SetFailFast(true)
        Runner.Run()
    end if
end sub

' Part of channel specific logic, where you will work with some
' external resources, like REST API, etc. You may get raw data from feed, then
' parse it and return as a native BrightScript object(roAA, roArray, etc)
' with some proper Content Meta-Data structure.
'
' If you will have a complex parsing process with a lot of external resourses,
' then it will be a good practice to move all logic to separate files.
Function GetApiArray()
    url = CreateObject("roUrlTransfer")
    'External resource
    url.SetUrl("http://api.delvenetworks.com/rest/organizations/59021fabe3b645968e382ac726cd6c7b/channels/1cfd09ab38e54f48be8498e0249f5c83/media.rss")
    rsp = url.GetToString()

    'Utility function for XML parsing.
    'Bassed on native Bright Script XML parser.
    responseXML = Utils_ParseXML(rsp)
    If responseXML <> invalid then
        responseXML   = responseXML.GetChildElements()
        responseArray = responseXML.GetChildElements()
    End if

    'The result will be roArray object.
    result = []

    if responseArray <> invalid AND GetInterface(responseArray, "ifArray") <> invalid then 
        'Work with parsed XML and add to roArray some data.
        for each xmlItem in responseArray
            if xmlItem.getName() = "item"
                itemAA = xmlItem.GetChildElements()
                if itemAA <> invalid
                    item = {}
                    for each xmlItem in itemAA
                        if xmlItem.getName() = "media:content"
                            item.stream = {url : xmlItem.getAttributes().url}
                            item.url = xmlItem.getAttributes().url
                            item.streamFormat = "mp4"
                            mediaContent = xmlItem.GetChildElements()
                            for each mediaContentItem in mediaContent
                                if mediaContentItem.getName() = "media:thumbnail"
                                    item.HDPosterUrl = mediaContentItem.getattributes().url
                                    item.hdBackgroundImageUrl = mediaContentItem.getattributes().url
                                end if
                            end for
                        else
                            item[xmlItem.getName()] = xmlItem.getText()
                        end if
                    end for
                    result.push(item)
                end if
            end if
        end for
    end if
    return result
End Function

'----------------------------------------------------------------
' Prepends a prefix to every entry in Assoc Array
'
' @return An Assoc Array with new values if all values are Strings
' or invalid if one or more value is not String.
'----------------------------------------------------------------
Function AddPrefixToAAItems(AssocArray as Object) as Object
    prefix = "prefix__"

    for each key in AssocArray
        'Get current item
        item = AssocArray[key]

        'Check if current item is string
        if GetInterface(item, "ifString") <> invalid then
            'Prepend a prefix to current item
            item = prefix + item
        else
            'Return invalid if item is not string
            return invalid
        end if
    end for

    return AssocArray
End Function