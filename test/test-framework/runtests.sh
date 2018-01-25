#!/usr/bin/expect

set ip [lindex $argv 0]

# set timeout 60
log_user 0


send_user "Launching the App...\n"
spawn curl -d "" http://$ip:8060/launch/dev

send_user "Connecting to Telnet...\n"
spawn telnet $ip 8085

send_user "Running tests, please wait...\n"

set runningFlag 0
set runningFlagTwo 0
set runningFlagThree 0
set failed 0
set error 0
set skipCount 0
set skippedTests 0
set total 0

# Only care about the last time the app was run
while {$runningFlag == 0} {
	expect {
	-re {Running} {}
	default {set runningFlag 1}
	}

}

while {$runningFlagTwo == 0} {
	expect {
		-re {SKIP: test[a-zA-Z]* test_[a-zA-Z]*.brs [a-zA-Z\s]*} {append skippedTests \n $expect_out(0,string)}
		default {set runningFlagTwo 1}
	}

	#Count how many times a skipped Test is encountered
	set skipCount [expr {$skipCount + 1}]
}

#Subtract 1 to count for final loop
set skipCount [expr {$skipCount - 1}]

# Searches and saves the test results
while {$runningFlagThree == 0} {
	expect {
		-re {pkg.*(?=Ran)} {append failOne $expect_out(0,string)}
		default {set runningFlagThree 1}
	}
}

# Get total number of tests ran
expect {
	-re {Ran (\d+) tests} {set total $expect_out(1,string)}
}

# Get test suite outcome
expect {
	OK 		{send_user "\nPASSED: All tests passed.\n"}
	FAILED 	{send_user "\nFAILED: One or more tests failed.\n"}
	timeout {send_user "\nERROR: The connection timed out\n"}
}

# Get number of failures
expect {
	 -re {failures= (\d+)} {set failed $expect_out(1,string)}
}

expect {
	-re {errors= (\d+)} {set error $expect_out(1,string)}
}

set failures [expr $failed + $error]
set total [expr $total - $skipCount]
set passed [expr $total - $failures - $skipCount]

send_user "\n--------------------"
send_user "\n--------------------"
send_user "\nTests ran: $total"
send_user "\nTests passed: $passed"
send_user "\nTests failed: $failures"
send_user "\n--------------------"
send_user "\nTests skipped: $skipCount"
send_user "\n--------------------"
send_user "\n--------------------"

if {$failed > 0 || $error > 0} {
	# Extract and summarise the errors/failures ready for exporting
	set myFailureList [split [string map [list "======================================================================" \0] $failOne] \0]
	array set failureArray {}
	array set formattedFailures {}
	set i 0

	foreach section $myFailureList {
		set failureArray($i) [split [string map [list "\r\n" \0] $section] \0]
		array set thisFailure {}
		set j 0
		foreach line $failureArray($i) {
			if {[string compare $line ""] != 0} {
				set thisFailure($j) $line
				incr j
			}
		}
		set str $thisFailure(1)
		append str " " $thisFailure(0) " " $thisFailure(3)
		set formattedFailures($i) $str
		incr i
	}

	# Print summary of failures
	send_user "\n\nSummary of failures and errors (failed test/error, file, cause of failure/error): \n"
	foreach failure [array name formattedFailures] {
		send_user $formattedFailures($failure)
		send_user "\n"
	}
}

if {$skippedTests > 0 } {
send_user "\nSummary of skipped tests (skipped test, file, cause of skipping):"
send_user $skippedTests
}

#Prints out a 'PASS' statement for each test passed expected by sum2junit to create the XML
for {set i 0} {$i < $passed} {incr i 1} {
	send_user "\nPASS: Test $i passed"
}

# All done! Close the app, disconnect from telnet
send_user "\nClosing the App...\n"
spawn curl -d "" http://$ip:8060/keypress/home

sleep 0.1
close

send_user "Report complete."
