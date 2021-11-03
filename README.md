# Definiciones Modelo MIA

# Objetivo: 

La flota 1 tiene como objetivo cargar en la zona amarilla y descargar en la zona roja. La flota 2 tiene como objetivo cargar en la zona amarilla y descargar en la zona verde.       

# Configuración del mundo:

- Una zona de preparación-inicio
- Una zona de carga (Zona amarilla)
- Dos zonas de descarga. Zona norte (Zona Roja) y zona sur  (Zona Verde)
- Un Casino (Zona café y Rosada)
- Una interseccion. (Zona gris)

# Variables:

- Número de camiones flota 1, camiones color azul y descargan en zona norte.
- Número de camiones flota 2, camiones color rojo y descargan en zona sur.
- Velocidad máxima de los camiones es 44 km/hora
- Velocidad promedio de los camiones es 31-32 km/hora       

# Horario y ticks:

- 1 segundo = 1/15 ticks
- 15 segundos = 1 ticks
- 1 minuto = 4 ticks
- 60 minutos/ 1 hora = 4x60 ticks = 240 ticks
- 600 minutos /10 horas = 10x4x60 = 2400 ticks 
- Turno comienza 8:00 - tick 0
- 08:00 - tick 0 - Inicio de Turno
- 09:00 - tick 240 
- 10:00 - tick 480 
- 11:00 - tick 720 
- 12:00 - tick 960 
- 13:00 - tick 1200 
- 14:00 - tick 1440 
- 15:00 - tick 1680 
- 16:00 - tick 1920 
- 17:00 - tick 2160 
- 18:00 - tick 2400  
- 19:00 - tick 2640 - inicio finalizacion del turno
- 20:00 - tick 2880 - Fin turno - Puede ser que el turno termine unos minutos despues de las 20 horas.

# Tiempos:

- Tiempo de inicio de turno: 8 a 9 hrs - 81 minutos media.
- Tiempo de ciclo = 57 minutos
- Tiempo de carga = 15 minutos de media
- Tiempo de fin de turno:
- Duración del turno: 8:00 a 20:00 / 12 horas de duración.

# Distancias:

- 1 KM = 2 PATCHES
- 60 minutos = 1 hora = 4x60 ticks = 240 ticks
- 1 KM/HORA = 2 PT / 240 ticks  =  0,0083
- 10 KM/HORA = 0,083 PT/ticks

- Velocidad máxima de los camiones es 44 km/hora = 0,37 pt/ticks
- Velocidad promedio de los camiones es 32 km/hora   = 0,27 pt/ticks
- 1 fd =  1 patch = 0.5 km

- Mundo a escala: 

![alt text](https://github.com/mhjhr/MIA/blob/f8a924682e451c7f116e5ced85ebb0d90d1b9933/mundo%20a%20escala.png)

#  Turno:

- El turno comienza a las 8:00 y se espera finalice a las 20:00 horas.
- Todos los camiones al inicio del turno comienzan en la zona de preparación-inicio
- Camiones se preparan en la zona de preparación y están separados.
- Al inicio existen camiones aleatorios que ya están cargados
- El orden de salida de los camiones es aleatorio
- Existe un tiempo aleatorio de 40 minutos +/- 40 minutos aleatorio (rango 40 a 80 minutos) preparación de inicio para cada camión, segun culmina su tiempo de preparación inician su trabajo, ya sea de carga (para camiones no cargados)  como el camino a la descarga (para camiones inicialmente cargados)
- Desde las 19:00 los camiones que están descargados no siguen cargando y se van a la zona de preparación, finalizando sus viajes. Los camiones que están cargados van a su zona a descargar y luego finalizan su turno, dirigiéndose a la zona de preparación.
- Con el último camión ingresando a la zona de preparación, finaliza el turno (debería ser aproximado a las 20 hrs), deteniéndose automáticamente la simulación.

#  Viaje:
- Los camiones se agrupan en flota 1 y flota 2.
- Si se encuentran con un camión delante bajan su velocidad para no chocar.
- La flota 1 debe cargar material en la zona de carga y descarga en la zona de descarga zona norte.
- La flota 2 debe cargar material en la zona de carga y descarga en la zona de descarga zona sur.
- Existe un tiempo aleatorio de tiempo de carga y tiempo de descarga en la zona norte y en la zona sur.

# Almuerzo en el casino:

- Existen dos turnos de almuerzo: turno 1 a las  13:00  horas y turno 3 a las 14:30 horas.
- Entre  las 12:30 hrs y 13:00 hrs los camiones que están descargados y están camino al casino deben ir a comer al casino, hasta alcanzar la capacidad máxima del casino.
- El resto de los camiones deben ir a almorzar desde las 14:30 hrs.
- Los operadores de los camiones almuerzan una hora + delta de tiempo aleatorio  en el rango de 15 minutos.
- Luego de almorzar los camiones están 100% descansados.

#  Camiones lentos y velocidad:

- Existen camiones lentos. Se puede definir el % de números de camiones lentos y la velocidad límite del camión lento. 
- El camión lento tiene una velocidad límite lenta, que debe ser inferior a la velocidad límite normal. Además su velocidad se define como un 10% menor a la velocidad de un camión normal aleatorio.

# Salidas y mediciones:

- Producción: número de descargas de ambas flotas realizadas en periodos de una hora durante el turno. 
- Cantidad de descargas
- Total Pérdida
Tiempo inicio de turno + fin de turno + perdida de la colcacion

# Escenarios a Validar:

-  1.Velocidad de los camiones
-  2.Proactividad: dejar cargado de camiones cargados al inicio del turno
-  3.Tiempos de carga (Carga: numero de escavadoras por tiempo) 
-  4.Tiempo descargas (Descarga: Frentes y por tiempo) 
-  5.Inicio de turno (tiempo de preparación/inicio de turno)
-  6. Aviso de termino de turno (incluir slider con hora de aviso de termino de turno (19:00) )
-  7.Casino (slide con el tiempo delta)


