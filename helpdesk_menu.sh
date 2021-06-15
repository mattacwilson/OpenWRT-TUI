#!/bin/sh
#Matthew Wilson
#EC1841586
#Edinburgh College Scripting for Security
#Text User Interface for OpenWRT Router

#Start menu for selection of different options
while true;do
	choice=$(whiptail --title "Text User Interface - OpenWRT" --menu "Please choose from the following options: " 20 70 13 \
		"1" "Display interfaces on router" \
		"2" "Choose Interface and Display IP Address" \
		"3" "Choose Interface and Display MAC Address" \
		"4" "Show uptime of router" \
		"5" "Display Router Cpu and Disk Utilization" \
		"6" "Restart networking services" \
		"7" "Restart SSH services" \
		"8" "Choose port to scan on Router via nmap" \
		"9" "Return the value of the nmap scan" \
		"10" "Show Firewall Zones" \
		"11" "Show configuration for each Firewall Zone" \
		"12" "Reboot the router" \
		"13" "Exit" 3>&1 1>&2 2>&3)

	
	MENU_TEXT="Back"

	case $choice in
		#Display router interfaces
		1)	clear
			showint=$(ip link show)
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "Currently available interfaces" "$showint" 20 70
			;;

		#Asks for input on which interface to choose and to display IP Address

		2)	interface=$(whiptail --inputbox "Please input interfae (case sensitive): " --nocancel 15 70 3>&1 1>&2 2>&3)
			clear
			intip=$(ifconfig "$interface" | grep 'inet ')
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "Selected interfaces IP: " "$intip" 10 80
			;;

		#Ask for input on which interface to choose and to display MAC Address
		
		3)	interface=$(whiptail --inputbox "Please input interface (case sensitive): " 15 70 3>&1 1>&2 2>&3)
			clear
			intmac=$(ifconfig "$interface" | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "Selected interfaces MAC Address: " "$intmac" 10 80
			;;
			
		#Displays router uptime

		4)	clear
			rup=$(uptime | sed 's/.*up \([^,]*\), .*/\1/')
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "Uptime of router" "Routers current uptime is: $rup" 10 40
			;;

		#Disk and CPU utilization

		5)clear
			diskut=$(df -h)
			whiptail --msgbox --ok-button "CPU ussage" --title "Disk Usage" "$diskut" 30 80

			cpuut=$(top -n 1 -b)
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "CPU Usage" "$cpuut" 30 80
		;;
	
		# Restart Networking Services
		6)	/etc/init.d/network restart;

			whiptail --msgbox --title "Network Restart" "Restarting the network services - Please stand by." 10 80
		;;
	
		# Restart SSH Service

		7)
			/etc/init.d/dropbear restart;
			whiptail --msgbox --title "Restart" "Restarting SSH service - You may be disconnected." 10 80
		;;
	
		
		#Nmap Scan Port number
			
		8)	
			#Ask for port number and run scan
			portnum=$(whiptail --inputbox "Please enter port to scan on device: " 15 70 3>&1 1>&2 2>&3)
			nmap localhost -p "$portnum" > /tmp/.nmap.result
		;;
	
		#Scan results

		9)
			#Read from previous input variable from menu 8. Return results of scan.
			clear
			if [ -f /tmp/.nmap.result ];then 
				scanres=$(cat /tmp/.nmap.result)
			else
				message="Error. You have not entered a port in option 8."
			fi
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "Port scan results" "$scanres" 30 80	
		;;
	
		#Display Firewall Zones

		10)	clear
           		fz="$(uci show firewall | grep 'firewall.@zone\[[0-9]\].name')"
             		whiptail --msgbox --ok-button "$MENU_TEXT" --title "Devices Firewall Zones" "$fz" 30 80
		;;
	
		#Display Firewall Zone Configs


		11)	clear
			 fzc="$(uci show firewall | grep 'firewall.@zone\[[0-9]\]')"
			 whiptail --msgbox --ok-button "$MENU_TEXT" --title "Config for each of the firewalls zones" "$fzc" 30 80
		;;
	
		#Reboot router

		12)	whiptail --msgbox --title "Reboot" "Rebooting router. Your connection will be interrupted, please reconnect." 10 80
            		reboot
		;;
	
		#Exit by breaking loop

		13)
		  exit 0 ;;
		*)	
			whiptail --msgbox --ok-button "$MENU_TEXT" --title "ERROR!" "Incorrect Option Selected" 30 80
		;;
	esac
done
