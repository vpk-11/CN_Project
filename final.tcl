#initialize the variables
set val(chan)    Channel/WirelessChannel     ;# channel type
set val(prop)    Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)   Phy/WirelessPhy             ;# network interface type
set val(mac)     Mac/802_11                  ;# MAC type
set val(ifq)     Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)      LL                          ;# link layer type
set val(ant)     Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)  50                          ;# max packet in ifq
set val(rp)      DSDV                        ;# routing protocol
set val(x)       1000                        ;# X dimension of topography
set val(y)       600                         ;# Y dimension of topography 
set val(stop)    10                          ;# time of simulation end
set val(nn)      30                   		 ;# number of mobilenodes

# Array of Colors
set colors(0) red
set colors(1) blue
set colors(2) green
set colors(3) yellow
set colors(4) orange
set colors(5) pink
set colors(6) black
set colors(7) brown

#creation of Simulator
set ns [new Simulator]

#creation of Trace and namfile 
set tracefile [open out.tr w]
$ns trace-all $tracefile

#Creation of Network Animation file
set namfile [open out.nam w]
$ns namtrace-all-wireless $namfile $val(x) $val(y)
# to include a new trace format
# $ns use-newtrace


#create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD Creation - General Operations Director
create-god $val(nn)

set channel1 [new $val(chan)]
set channel2 [new $val(chan)]
set channel3 [new $val(chan)]

# configure the nodes
$ns node-config -adhocRouting $val(rp) \
                -llType $val(ll) \
                -macType $val(mac) \
                -ifqType $val(ifq) \
                -ifqLen $val(ifqlen) \
                -antType $val(ant) \
                -propType $val(prop) \
                -phyType $val(netif) \
                -channelType $val(chan) \
                -topoInstance $topo \
                -agentTrace ON \
                -routerTrace ON \
                -macTrace OFF \
                -movementTrace ON

# #Energy Model
# # the unit of energy is joules = Power (Watts) * time (Seconds)

# set n(0) [$ns node]
# set n(1) [$ns node]
# set n(2) [$ns node]
# set n(3) [$ns node]
# set n(4) [$ns node]
# set n(5) [$ns node]
# set n(6) [$ns node]
# set n(7) [$ns node]
# set n(8) [$ns node]
# set n(9) [$ns node]

# $n(0) random-motion 0
# $n(1) random-motion 0
# $n(2) random-motion 0
# $n(3) random-motion 0
# $n(4) random-motion 0
# $n(5) random-motion 0
# $n(6) random-motion 0
# $n(7) random-motion 0
# $n(7) random-motion 0
# $n(8) random-motion 0
# $n(9) random-motion 0

# $ns initial_node_pos $n(0) 20
# $ns initial_node_pos $n(1) 20
# $ns initial_node_pos $n(2) 20
# $ns initial_node_pos $n(3) 20
# $ns initial_node_pos $n(4) 20
# $ns initial_node_pos $n(5) 20
# $ns initial_node_pos $n(6) 20
# $ns initial_node_pos $n(7) 20
# $ns initial_node_pos $n(8) 20
# $ns initial_node_pos $n(9) 20

# #mobility of the nodes
# #At what Time? Which node? Where to? at What Speed?
# # Time? Node? x2? y2? speed?
# # $ns at 1.0 "$n1 setdest 490.0 340.0 25.0"

# # position of the nodes
# $n(0) set X_ 70.0
# $n(0) set Y_ 50.0
# $n(0) set Z_ 0.0
# $ns at 0.0 "$n(0) setdest 200.0 50.0 60.0"

# $n(1) set X_ 30.0
# $n(1) set Y_ 50.0
# $n(1) set Z_ 0.0
# $ns at 0.0 "$n(1) setdest 200.0 50.0 70.0"

# $n(2) set X_ 10.0
# $n(2) set Y_ 50.0
# $n(2) set Z_ 0.0
# $ns at 0.0 "$n(2) setdest 200.0 50.0 70.0"

# $n(3) set X_ 20.0
# $n(3) set Y_ 25.0
# $n(3) set Z_ 0.0
# $ns at 0.0 "$n(3) setdest 200.0 25.0 65.0"

# $n(4) set X_ 20.0
# $n(4) set Y_ 50.0
# $n(4) set Z_ 0.0
# $ns at 0.0 "$n(4) setdest 200.0 50.0 75.0"

# $n(5) set X_ 40.0
# $n(5) set Y_ 50.0
# $n(5) set Z_ 0.0
# $ns at 0.0 "$n(5) setdest 200.0 50.0 90.0"

# $n(6) set X_ 50.0
# $n(6) set Y_ 25.0
# $n(6) set Z_ 0.0
# $ns at 0.0 "$n(6) setdest 200.0 25.0 120.0"

# $n(7) set X_ 60.0
# $n(7) set Y_ 25.0
# $n(7) set Z_ 0.0
# $ns at 0.0 "$n(7) setdest 200.0 25.0 60.0"

# $n(8) set X_ 60.0
# $n(8) set Y_ 50.0
# $n(8) set Z_ 0.0
# $ns at 0.0 "$n(8) setdest 200.0 50.0 95.0"

# $n(9) set X_ 80.0
# $n(9) set Y_ 50.0
# $n(9) set Z_ 0.0
# $ns at 0.0 "$n(9) setdest 200.0 50.0 110.0"

#  Slurp up the input file
set fp [open "Input.txt"]
set file_data [read $fp]
close $fp
set lines [split $file_data "\n"]
foreach line $lines {
    # puts "$line"
    set words [split $line " "]
	set it [lindex $words 0]
    set x1 [lindex $words 1]
    set y1 [lindex $words 2]
    set vel [lindex $words 3]
    set x2 [lindex $words 4]
    set y2 [lindex $words 5]
    set n($it) [$ns node]
    $n($it) random-motion 0
    $ns initial_node_pos $n($it) 20
    $n($it) set X_ $x1
    $n($it) set Y_ $y1
    $n($it) set Z_ 0.0
    $ns at 2.0 "$n($it) setdest $x2 $y2 $vel"
}

#  Slurp up the data file
set fp [open "Cluster.txt"]
set file_data [read $fp]
close $fp
set lines [split $file_data "\n"]
set inr 0
foreach line $lines {
    # puts "$line"
    set words [split $line " "]
	set cH [lindex $words 0]
    $ns at 0.5 "$n($cH) color $colors($inr)"
    $n($cH) color $colors($inr)
    # foreach it $words 
	set length [llength $words]
	for {set ind 1} { $ind < $length } { incr ind } {
        puts "$ind"
		set it [lindex $words $ind]
		puts "$it"
        $ns at 0.5 "$n($it) color $colors($inr)"
        $n($it) color $colors($inr)
		# Comms between head and node
		set tcp [new Agent/TCP]
		set sink [new Agent/TCPSink]
		$ns attach-agent $n($cH) $tcp
		$ns attach-agent $n($it) $sink
		$ns connect $tcp $sink
		set ftp [new Application/FTP]
		$ftp attach-agent $tcp
		$ns at 1.0 "$ftp start"
		puts "TCP Connected b/w $it and $cH"
    }
    set inr [incr inr]
}

$ns at 100.0 "finish"

proc finish {} {
    puts "Proc finish"
	global ns tracefile namfile
    $ns flush-trace
    # close $tracefile
    close $namfile
    exec nam out.nam &
	puts "exec nam"
	exec awk -f awk_files/throughput.awk out.tr > output/throu_out &
	exec awk -f awk_files/pdr_1.awk out.tr > output/pdr_out &
    exec awk -f awk_files/e2edelay.awk out.tr > output/e2edelay_out &
    exec awk -f awk_files/pDropped.awk out.tr > output/pDropped_out &
    exit 0
}

puts "Starting Simulation"
$ns run