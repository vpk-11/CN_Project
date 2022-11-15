BEGIN {
       recvdSize = 0
       startTime = 0
       stopTime = 50
  }
   
  {
             event = $1
             time = $2
             node_id = $3
             pkt_size = $8
             level = $7
   
  # Store start time
  if (level == "tcp" && event == "r" && pkt_size >= 100) { #default pkt_size = 1000
    if (time < startTime) {
             startTime = time
             }
       }
   
  # Update total received packets' size and store packets arrival time
  if (level == "tcp" && event == "r" && pkt_size >= 100) {
       if (time > stopTime) {
             stopTime = time
             }
       # Rip off the header
       #hdr_size = pkt_size % 512
       #pkt_size -= hdr_size
       # Store received packet's size
       recvdSize += pkt_size
       }
  }
   
  END {
       print (recvdSize/(stopTime-startTime))*(8/1000);
  }