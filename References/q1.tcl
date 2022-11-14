# Define options
set val(chan)    Channel/WirelessChannel     ;# channel type
set val(prop)    Propagation/TwoRayGround    ;# radio-propagation model
set val(netif)   Phy/WirelessPhy             ;# network interface type
set val(mac)     Mac/802_11                  ;# MAC type
set val(ifq)     Queue/DropTail/PriQueue     ;# interface queue type
set val(ll)      LL                          ;# link layer type
set val(ant)     Antenna/OmniAntenna         ;# antenna model
set val(ifqlen)  50                          ;# max packet in ifq
set val(rp)      DSDV                        ;# routing protocol
set val(x)       800                         ;# X dimension of topography
set val(y)       600                         ;# Y dimension of topography 
set val(stop)    10                          ;# time of simulation end
set NETWORK_NODE 10
set y1           500
set y2           250
set x1           100

# Array of colors
set colors(0) red
set colors(1) blue
set colors(2) green
set colors(3) yellow
set colors(4) orange
set colors(5) pink
set colors(6) black
set colors(7) brown

#Creating simulation:
set ns [new Simulator]

#Creating nam and trace file:
set tracefd [open kmeans.tr w]
set namtrace [open kmeans.nam w]   

$ns trace-all $tracefd
$ns namtrace-all-wireless $namtrace $val(x) $val(y)

# set up topography object
set topo [new Topography]
$topo load_flatgrid $val(x) $val(y)
set god_ [create-god $NETWORK_NODE]

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
         
# Creating node objects..         
for {set i 0} {$i < $NETWORK_NODE } { incr i } {
    set node($i) [$ns node]     
}
# Node representing color
for {set i 0} {$i < $NETWORK_NODE  } { incr i } {
    $node($i) color black
    $ns at 0.0 "$node($i) color black"
}

# Provide initial location of mobilenodes..
# Topography
set i 0 
while {$i  < $NETWORK_NODE} {
    set xx [expr $x1 + ($i*40)]
    set j [expr $i + 1]

    $node($i) set X_ $xx
    $node($i) set Y_ $y1
    set nodeXpos($i) $xx
    set nodeYpos($i) $y1
    set nodeZpos($i) 0.0

    $node($j) set X_ $xx
    $node($j) set Y_ $y2
    set nodeXpos($j) $xx
    set nodeYpos($j) $y2
    set nodeZpos($j) 0.0

    set i [expr $j + 1]
}

# Define node initial position in nam
for {set i 0} {$i < $NETWORK_NODE} { incr i } {
    $ns initial_node_pos $node($i) 30
}

#  Slurp up the data file
set fp [open "Input.txt"]
set file_data [read $fp]
close $fp
set lines [split $file_data "\n"]
set inr 0
foreach line $lines {
    # puts "$line"
    set words [split $line " "]
    foreach it $words {
        # puts "$it"
        $ns at 0.5 "$node($it) color $colors($inr)"
        $node($it) color $colors($inr)
    }
    set inr [incr inr]
}

#stop procedure..
proc stop {} {
    global ns tracefd namtrace
    $ns flush-trace
    close $tracefd
    close $namtrace
    exec nam kmeans.nam &
}

$ns at $val(stop) "stop"
$ns run