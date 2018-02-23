'Channel entry point
sub RunUserInterface(args)
  Runner = TestRunner()
  Runner.logger.SetVerbosity(3)
  Runner.logger.SetEcho(true)
  Runner.SetFailFast(false)
  Runner.Run()
end sub
