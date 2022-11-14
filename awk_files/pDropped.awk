 BEGIN {
 seqno = -1; 
 droppedPackets = 0;
 receivedPackets = 0;
 count = 0;
 }
 {
 #For Calculating Dropped Packets
 if($4 == "AGT" && $1 == "s" && seqno < $6) {
   seqno = $6;
   } else if(($4 == "AGT") && ($1 == "r")) {
   receivedPackets++;
   } else if ($1 == "D" && $7 == "tcp" && $8 > 512){
   droppedPackets++; 
   }
}
END { 
   print droppedPackets;
}