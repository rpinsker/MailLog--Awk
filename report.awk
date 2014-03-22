#!/usr/bin/awk -f 
# set variables to 0
BEGIN { spam = 0; ham=0; infected=0; spamScoreSum=0 }
#find lines with "SMTP::"
{ match($0,"SMTP::") }
#if the line has "SMTP::", get the sender and reciever
{ if (RLENGTH  > 0) {
    match($0,"\<[^>]*\>.\-\>.\<[^\>]*\>")  
    senderAndReceiver = substr($0,RSTART,RLENGTH)
    split(senderAndReceiver,sAndR," -> ")
    senders[sAndR[1]]++
    receivers[sAndR[2]]++
}
}  
#find lines with "Passed Clean" to increase ham count
{ match($0,"Passed CLEAN") }
{ if (RLENGTH > 0)
	ham++ }
#find lines with "Blocked SPAM" to increase spam count. Keep track of spamScoreSum
{ match ($0,"Blocked SPAM") }
{ if (RLENGTH > 0) {
	spam++
	match($0,"Hits: [^,]*")
	spamScoreSum = spamScoreSum + substr(substr($0,RSTART,RLENGTH),7)	
    } }
#find lines with "Block INFECTED" to increase infected count
{ match ($0,"Blocked INFECTED") }
{ if (RLENGTH > 0)
	infected++ }
#print out the statistics
END {
    print("Stats:\n-------\nHam: ",ham,"\nSPAM: ",spam)
    print("Average SPAM score: ", spamScoreSum/spam)
    print("SPAM to Ham ratio: ", spam/ham)
    print("Infected :", infected)
    print("-------")
    print("10 top recipients")
    asort(receivers,newR)
    count = 0
    for (r in receivers) {
	topTenR[count] = (r" "receiver[r])
	count++
    }
    for (i = 0; i < 10; i++)
	print(topTenR[i])
    print("-------")
    print("10 top senders")
    n = asort(senders,newS)
    for (i = n; i >= n-9; i--) {
	for (s in senders)
	    if (senders[s] == newS[i])
		print(s," ",newS[i])
    }    
}