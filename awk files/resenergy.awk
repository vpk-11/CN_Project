#residual energy of node
BEGIN {
	i=0
	n=0
	total_energy=0.0
	energy_avail[s] = initenergy;
}

{
event = $1
time =$3
node_id=$5
energy_value= $7
packet=$19
pkt_id=$41
pkt_type=$35

if(event == "N"){
	for(i=0;i<6;i++) {
		if(i==node_id) {
			energy_avail[i] = energy_avail[i]-(energy_avail[i] - energy_value);
#			printf("%d-%f \n",i,energy_avail[i]);
		}
	}
}
}

END {
for(i=0;i<6;i++) {
	printf("%d %f \n",i,energy_avail[i]);
total_energy = total_energy + energy_avail[i];
if(energy_avail[i] !=0)
n++
}
#printf("the total Residual energy of the network is %f \n",total_energy);
#printf("\n");
}

