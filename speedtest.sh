#
# Example usage: ./speedtest.sh www.mysite.com 20
#

url=$1
iterations=$2
times=""
echo testing load times for $url
for i in `seq 1 $iterations`
    do
        result=`wget -p $url 2>&1 | tail -n2 | head -n1`
	prefix="Total wall clock time: "
        time=${result#$prefix}
	if [[ $time == *m* ]] #convert Xm Ys times and Xs times to just int seconds
	    then
	        minutes=`echo $time | awk '{print $1}' | awk -F "m" '{print $1}'`
		seconds=`echo $time | awk '{print $2}' | awk -F "s" '{print $1}'`
		time=$(($minutes*60+$seconds)) #assumes int seconds, unlike if wget results are under 10s
	    else
	        time=`echo $time | awk -F "s" '{print $1}'` #may be int or float, doesn't matter
	fi
        if [ "$times" == "" ] #first pass, no times yet
	    then
	        times=$time
	    else #every other pass, add a space and then the next time
	        times="$times $time"
	fi
	echo test $i loaded in $time seconds
done

##Results
echo There were $iterations test page loads of $url
echo $times | awk '{
    min = max = sum = $1;
    sum_of_squares = $1 * $1;
    for (n=2; n <= NF; n++) {
        if ($n < min) min = $n;
        if ($n > max) max = $n;
        sum += $n;
        sum_of_squares += $n * $n;
    }
    avg = sum/NF;
    sum2 = 0;
    for (n=1; n <= NF; n++) {
        sum2 += ($n-avg)^2;
    }
    stddev = sqrt(sum2/NF);
    print "All units in seconds: min=" min ", max=" max ", avg=" sum/NF ", sum=" sum ", standard deviation=" stddev;
}'
