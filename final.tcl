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
set val(x)		        500                         ;# in metres
set val(y)		        500			                ;# in metres

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
set tracefile [open wireless.tr w]
$ns trace-all $tracefile

#Creation of Network Animation file
set namfile [open wireless.nam w]
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

# position of the nodes 
$n0 set X_ 10.0
$n0 set Y_ 20.0
$n0 set Z_ 0.0

$n1 set X_ 210.0
$n1 set Y_ 230.0
$n1 set Z_ 0.0

$n2 set X_ 100.0
$n2 set Y_ 200.0
$n2 set Z_ 0.0

$n3 set X_ 150.0
$n3 set Y_ 230.0
$n3 set Z_ 0.0

$n4 set X_ 430.0
$n4 set Y_ 320.0
$n4 set Z_ 0.0

$n5 set X_ 270.0
$n5 set Y_ 120.0
$n5 set Z_ 0.0

$n6 set X_ 270.0
$n6 set Y_ 120.0
$n6 set Z_ 0.0

$n7 set X_ 270.0
$n7 set Y_ 120.0
$n7 set Z_ 0.0

$n8 set X_ 270.0
$n8 set Y_ 120.0
$n8 set Z_ 0.0

$n9 set X_ 270.0
$n9 set Y_ 120.0
$n9 set Z_ 0.0

#mobility of the nodes
#At what Time? Which node? Where to? at What Speed?
# Time? Node? x2? y2? speed?
$ns at 1.0 "$n1 setdest 490.0 340.0 25.0"
$ns at 1.0 "$n4 setdest 300.0 130.0 5.0"
$ns at 1.0 "$n5 setdest 190.0 440.0 15.0"

#creation of agents
set tcp [new Agent/TCP]
set sink [new Agent/TCPSink]
$ns attach-agent $n0 $tcp
$ns attach-agent $n5 $sink
$ns connect $tcp $sink
set ftp [new Application/FTP]
$ftp attach-agent $tcp
$ns at 1.0 "$ftp start"

set udp [new Agent/UDP]
set null [new Agent/Null]
$ns attach-agent $n2 $udp
$ns attach-agent $n3 $null
$ns connect $udp $null
set cbr [new Application/Traffic/CBR]
$cbr attach-agent $udp
$ns at 1.0 "$cbr start"

$ns at 100.0 "finish"

proc finish {} {
    global ns tracefile namfile
    $ns flush-trace
    close $tracefile
    close $namfile
    exec nam wireless.nam &
    exit 0
}

puts "Starting Simulation"
$ns run
