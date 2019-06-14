#!/bin/bash

#Portbalancer Version 1.1
#Authors: alexis.e.aguirre@gds.ey.com | diego.s.villegas@gds.ey.com

#Credentials
echo ""
echo -n "Enter Switch IP and press [ENTER]: "
read ip

echo -n "Enter Switch Username and press [ENTER]: "
read user

echo -n "Enter your Switch Password and press [ENTER]: "
read -s pass
printf "\r"

echo -n "Enter Storage Alias (Example: USSECSBVMAX007) and press [ENTER]: "
read alistor

echo -e "\e[92m

########## VERIFY INFORMATION ##########

Swith IP:         $ip
Switch Username:  $user  
Storage Alias:    $alistor 

########################################
\e[0m";

echo -n "Information Correct?: Y/N "
read aceptar
echo ""

    
    if [ "$aceptar" = "Y" ] || [ "$aceptar" = "y" ]
        then        
	#Collect Logs
	echo -n "Gathering info....."
        echo ""
	sshpass -p $pass ssh $user@$ip alishow |grep -i alias| grep -i $alistor > /tmp/alias_$alistor.txt
	sshpass -p $pass ssh $user@$ip cfgactvshow > /tmp/cfgactvshow_$ip.txt
	
            if [ "$?" -eq 0 ];then	
	        #Only alias
	        storports=$(cat /tmp/alias_$alistor.txt |awk '{print $2}')  
	        cfg=$(cat /tmp/cfgactvshow_$ip.txt)
          
                #Collect alias and wwpn from storage
       	         for iter in $storports;
	          do
	            sshpass -p $pass ssh $user@$ip alishow $iter >> /tmp/aliaswwpn_$ip.txt;
                  done
      
                #Save wwpn and alias in differents files
	        cat /tmp/aliaswwpn_$ip.txt |grep alias > /tmp/soloalias.txt
	        cat /tmp/aliaswwpn_$ip.txt |grep -v alias |sed '/^\s*$/d' > /tmp/solowwpn.txt
        
	        #Quantity of usage ports by wwpn
	        cat /tmp/solowwpn.txt |while read a
                   do
                   cat /tmp/cfgactvshow_$ip.txt |grep -i $a |wc -l >> /tmp/qty.txt; done

                #Show results in console
		echo ""
	        (printf "Aliases WWPN Quantity-Ports\n" \; 
		paste <(awk '{print $2}' /tmp/soloalias.txt ) <(awk '{print $1 $2}' /tmp/solowwpn.txt ) <(awk '{print $1}' /tmp/qty.txt ) |sed 1d) | column -t
             
            else
                 echo "Invalid Username or Password"
              exit	
	     fi   
    
    else
        exit 
fi

#Garabage collector
del="rm -r"
a="/tmp/alias_$alistor.txt"
b="/tmp/cfgactvshow_$ip.txt"
c="/tmp/aliaswwpn_$ip.txt"
d="/tmp/soloalias.txt"
e="/tmp/solowwpn.txt"
f="/tmp/qty.txt"

    for kk in "$a" "$b" "$c" "$d" "$e" "$f";
        do
            if [ -e "$kk" ]; then
                $del "$kk"
	      else :
	    fi
    done
