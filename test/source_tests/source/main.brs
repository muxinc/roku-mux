'Channel entry point
sub RunUserInterface(args)
  if args.RunTests = "true" and type(TestRunner) = "Function"
      Runner = TestRunner()

      Runner.SetFunctions([
        TestSuite__Init
        TestSuite__GenerateVideoID
        TestSuite__GetBeaconUrl
        TestSuite__GetDynamicProperties
        TestSuite__GetSessionProperties
        TestSuite__Minification
        TestSuite__RAFHandling
        TestSuite__URL_Utils
        TestSuite__VideoStateHandling
        TestSuite__ViewRobustness
    
      ])

      Runner.Logger.SetVerbosity(3)
      Runner.Logger.SetEcho(true)
      Runner.Logger.SetJUnit(false)
      Runner.SetFailFast(false)
      
      Runner.Run()
  end if
end sub
