#initialize the variables
set val(chan)           Channel/WirelessChannel     ;#Channel Type
set val(prop)           Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)          Phy/WirelessPhy             ;# network interface type WAVELAN DSSS 2.4GHz
set val(mac)            Mac/802_11                  ;# MAC type
set val(ifq)            Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)             LL                          ;# link layer type
set val(ant)            Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)         50                          ;# max packet in ifq
set val(nn)             6                           ;# number of mobilenodes
set val(rp)             AODV                        ;# routing protocol
set val(x)		        500                        	;# in metres
set val(y)		        500			            	;# in metres

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
#to include a new trace format
$ns use-newtrace

#create topography
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)

#GOD Creation - General Operations Director
create-god $val(nn)

set channel1 [new $val(chan)]
set channel2 [new $val(chan)]
set channel3 [new $val(chan)]

#configure the node
$ns node-config -adhocRouting $val(rp) \
		-llType $val(ll) \
		-macType $val(mac) \
		-ifqType $val(ifq) \
		-ifqLen $val(ifqlen) \
		-antType $val(ant) \
		-propType $val(prop) \
		-phyType $val(netif) \
		-energyModel "EnergyModel" \
		-initialEnergy 100.0 \
		-txPower 0.9 \
		-rxPower 0.5 \
		-idlePower 0.45 \
		-sleepPower 0.05 \
		-topoInstance $topo \
		-agentTrace ON \
		-macTrace ON \
		-routerTrace ON \
		-movementTrace ON \
		-channel $channel1 

#Energy Model
# the unit of energy is joules = Power (Watts) * time (Seconds)

set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]
set n4 [$ns node]
set n5 [$ns node]
set n6 [$ns node]
set n7 [$ns node]
set n8 [$ns node]
set n9 [$ns node]

$n0 random-motion 0
$n1 random-motion 0
$n2 random-motion 0
$n3 random-motion 0
$n4 random-motion 0
$n5 random-motion 0
$n6 random-motion 0
$n7 random-motion 0
$n7 random-motion 0
$n8 random-motion 0
$n9 random-motion 0

$ns initial_node_pos $n0 20
$ns initial_node_pos $n1 20
$ns initial_node_pos $n2 20
$ns initial_node_pos $n3 20
$ns initial_node_pos $n4 20
$ns initial_node_pos $n5 50
$ns initial_node_pos $n6 50
$ns initial_node_pos $n7 50
$ns initial_node_pos $n8 50
$ns initial_node_pos $n9 50

#mobility of the nodes
#At what Time? Which node? Where to? at What Speed?
# Time? Node? x2? y2? speed?
# $ns at 1.0 "$n1 setdest 490.0 340.0 25.0"

# position of the nodes
$n0 set X_ 70.0
$n0 set Y_ 500.0
$n0 set Z_ 0.0
$ns at 1.0 "$n0 setdest 490.0 340.0 60.0"

$n1 set X_ 30.0
$n1 set Y_ 500.0
$n1 set Z_ 0.0
$ns at 1.0 "$n1 setdest 490.0 340.0 70.0"

$n2 set X_ 10.0
$n2 set Y_ 500.0
$n2 set Z_ 0.0
$ns at 1.0 "$n2 setdest 490.0 340.0 -70.0"

$n3 set X_ 20.0
$n3 set Y_ 250.0
$n3 set Z_ 0.0
$ns at 1.0 "$n3 setdest 490.0 340.0 65.0"

$n4 set X_ 20.0
$n4 set Y_ 500.0
$n4 set Z_ 0.0
$ns at 1.0 "$n4 setdest 490.0 340.0 -75.0"

$n5 set X_ 40.0
$n5 set Y_ 500.0
$n5 set Z_ 0.0
$ns at 1.0 "$n5 setdest 490.0 340.0 90.0"

$n6 set X_ 50.0
$n6 set Y_ 250.0
$n6 set Z_ 0.0
$ns at 1.0 "$n6 setdest 490.0 340.0 120.0"

$n7 set X_ 60.0
$n7 set Y_ 250.0
$n7 set Z_ 0.0
$ns at 1.0 "$n7 setdest 490.0 340.0 -60.0"

$n8 set X_ 60.0
$n8 set Y_ 500.0
$n8 set Z_ 0.0
$ns at 1.0 "$n8 setdest 490.0 340.0 95.0"

$n9 set X_ 80.0
$n9 set Y_ 500.0
$n9 set Z_ 0.0
$ns at 1.0 "$n9 setdest 490.0 340.0 110.0"

# vel = [60,70,-70,65,-75,90,120,-60,95,110]

#  Slurp up the data file
set fp [open "Input.txt"]
set file_data [read $fp]
close $fp
set lines [split $file_data "\n"]
set inr 0
foreach line $lines {
    # puts "$line"
    set words [split $line " "]
	set cH $words(0) 
    foreach it $words {
        # puts "$it"
        $ns at 0.5 "$node($it) color $colors($inr)"
        $node($it) color $colors($inr)
		if($it == $cH){
			continue;
		}
		# Comms between head and node
		set tcp [new Agent/TCP]
		set sink [new Agent/TCPSink]
		$ns attach-agent $cH $tcp
		$ns attach-agent $it $sink
		$ns connect $tcp $sink
		set ftp [new Application/FTP]
		$ftp attach-agent $tcp
		$ns at 2.0 "$ftp start"
    }
    set inr [incr inr]
}

$ns at 20.0 "finish"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam wireless.nam &
	exec awk -f awk_files/avg_throu.awk out.tr > avg_throu_out &
	exec awk -f awk_files/pdr.awk out.tr > pdr_out &
    exit 0
}

puts "Starting Simulation"
$ns run
