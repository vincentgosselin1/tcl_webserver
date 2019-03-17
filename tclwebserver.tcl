proc main argv {
    set port 8080
    set ::buffer ""
    socket -server accept $port
    #puts waiting...$port
	puts "StartingWebServer at 127.0.0.1:8080"
    vwait forever
 }
 proc accept {socket adr port} {
    fileevent $socket readable [list webui_go $socket]
 }
 proc webui_go sock {
    global buffer
    set now [clock format [clock sec] -format %H:%M:%S]
    set query ""
    while 1 {
        gets $sock line
        lappend query $line
        if {$line eq ""} break
    }
    set cmd ""
    regexp {GET /_post\?CMD=(.+) HTTP} [lindex $query 0] -> cmd
    set cmd [unescape [string map {+ " "} $cmd]]
    catch {uplevel \#0 $cmd} res
    lappend ::buffer "$now % $cmd" $res
    puts $sock "HTTP/1.0 200 OK"
    puts $sock "Content-Type: text/html\n"    
    puts $sock "<html><head><h1>TclServe</h1>"
    foreach line $::buffer {
        puts $sock <br>$line
    }
    puts $sock "<hr/><form id='cpost' action='/_post' method='get'>
    <input id='cmsg' name='CMD' size='80' value='' />
    <input type='submit' value='Go' /></form>"    
    close $sock
 }
 proc unescape str {
    regsub -all {%(..)} [string map {+ " "} $str] {\u00\1} str
    subst $str
 }
 main $argv
