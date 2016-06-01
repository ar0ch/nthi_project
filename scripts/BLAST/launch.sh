ps auxw | grep sequenceserver | grep -v grep > /dev/null

if [ $? != 0 ]
then
    /usr/bin/screen -dmS ss /usr/local/bin/sequenceserver -d=/home/blast/public/blast/ -H 127.0.0.1 -p 4567 > /dev/null
fi
    
    
