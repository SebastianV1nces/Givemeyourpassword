

#                      **Give me your Password (Evil Twin Atack)** # 

![Banner](/archivos/imagenes/banner.png)

Herramienta en bash que genera un **ataque wifi** que levanta un AP con hostpad, dnsmasq y php.

No se necesita diccionarios ni fuerza bruta para obtener la contraseña, solo un poco de tiempo y el desconocimiento o igenuidad de la victima.

Las contraseñas se guardan en una base de datos con mysql que utiliza las credenciales predeterminadas para su uso.

Se necesita tarjeta de red disponible con modo monitor.

## Herramientas necesarias

* hostapd 
* dnsmasq 
* php 
* xterm 
* mysql 
* aircrack-ng 
* mysqldump

![dependencias](/archivos/imagenes/dependencias.png)

Si el nombre de la depencia esta en rojo significa que no esta instalada por lo que deberias hacer uso de **"apt install"** para instalarla.

**NOTA:** La herramienta no funcionaria si no tiene todas las dependencias instaladas.

##     **Funcionamiento de la herramienta**

### **Modo monitor**

![monitor](/archivos/imagenes/monitor.png)

#Escribimos en nombre de nuestra **tarjeta de red disponible con modo monitor** para configurarla para el correcto funcionamiento.

+ mata todos los procesos de conexion
+ inicia el modo monitor
+ verifica que todo este bien 

### **Hostapd**

Crea el punto de acceso wifi con el nombre  y el canal que eligas (el nombre de la red dependera del uso que le demos).

![hostpad](/archivos/imagenes/hostapd.png)

#Si todo esta bien se abrira una terminal con **xterm** 

![hostapd](/archivos/imagenes/hostapd2.png)

### **Servicio DHCP y servidor PHP**

Utiliza la herramienta "dnsmasq" para asignar las IP a los dispositivos que se conecten a la red hecha con hostapd y "php" la montar.

El portal que ves en pantalla se lo debemos a "athanstan" el creador de este mismo.

[github del proyecto][https://github.com/athanstan/EvilTwin_AP_CaptivePortal]

el servidor web que captura la contraseña en texto plano y la guarda en la base de datos con mysql. 

![dnsmasq](/archivos/imagenes/dnsmasq.png)

![dhcp](/archivos/imagenes/dhcp.png)

![php](/archivos/imagenes/php.png)

### **Base de datos con mysql**

Se captura un dumpeo de la base de datos con **mysqldump** y se lo imprime en pantalla usando expresiones regulares para solo mostrar las contraseñas.

![mysql](/archivos/imagenes/msyql.png)

#Si todo esta bien con los procesos anteriores tendra un un punto de acceso sin contraseña a la que las personas podran conectarse e ingresar a un **portal captivo** en el que con un panel phising podras o no obtenter la contraseña del wifi victima.

![kali](/archivos/imagenes/kali.png)

### **Punto de acceso**

#La victima tendria que ver un red con el nombre que pusimos anteriormente 

![prueba](/archivos/imagenes/prueba.png)

Aqui la victima tendria que poner su clave del wifi(.... claro si esque se la cree) y se redirigira a un panel de carga.

![portal](/archivos/imagenes/portal.png)

Y la contraseña aparecera en pantalla

![carga](/archivos/imagenes/carga.png)

Asi se veria la pantalla principal al ver movimiento dentro de la red y al recibir una contraseña de la victima.

![final](/archivos/imagenes/kali3.png)

Por ultimo si precionamos "Control + C" en la terminal principal(si lo hacemos en las pequeñas se cerra el proceso como tal) se cerrara la herramienta pregutando si queremos guardar o no la base de datos.

![base](/archivos/imagenes/del.png)

y finalizando con un bonito mensaje

![base](/archivos/imagenes/dia.png)

#### Solo con fines educativos y uso en entornos controlados (usar con responsabilidad)😉

##Nota:
###Le hace falta un ataque Deauth para que sea efectivo. **EN PROCESO** parece que necesitara otra tarjeta de red :(

