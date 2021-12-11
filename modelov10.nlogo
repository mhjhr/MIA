extensions [table csv]

globals [
  actual-time
  hours
  minutes
  seconds
  time_box
  counter_time
  num_descargas_zona_norte
  num_descargas_zona_sur
  temp_total_descargas
  camiones_a_comer_flota1_t1
  camiones_a_comer_flota2_t1
  camiones_a_comer_flota1_t2
  camiones_a_comer_flota2_t2
  capacity_max_lunch_t1
  capacity_max_lunch_t2
  number_car_finish
  production
  preparation
  loading
  launching
  tb-memory
  num_turtle
  num_turtle_zn
  num_turtle_zs
  tail_uploading
  tail_downloading_zn
  tail_downloading_zs
  next_truck_move
  next_truck_move_zn
  next_truck_move_zs
]

turtles-own [
  speed
  speed-min
  wait-time
  wait-time-descarga
  wait-time-carga
  last-wait-time-descarga
  last-wait-time-carga
  last-wait-time
  return
  uploading
  downloading
  numero-viajes
  flota
  way ; to download = 1 , to upload = 0 OR way = 0 descargado, way = 1 cargado
  comer? ; true have to go to lunch , false have to work
  comiendo? ; true = lunching, false = working
  comido?; true if truck lunched, false if truck not lunched
  lento? ; true if slow, false is normal
  turno_finalizado? ; true, finish loading activities to the truck and finish work
  time_start_lunch;
  time_finish_lunch;
  cargado_inicio?;
  ready?;
  preparation_time
  mi_velocidad_limite
  mi_velocidad_inicial
  reposo?
]

patches-own
[
]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INICIALIZACION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to setup
  clear-all
  ask patches [setup-road]
  ask patches with [pxcor =   3 and pycor = -4] [set plabel " Casino"]
  ask patches with [pxcor = -18 and pycor = -2] [set plabel "Zona Carga"]
  ask patches with [pxcor =  24 and pycor = -2] [set plabel "Zona Norte Descarga"]
  ask patches with [pxcor = 30 and pycor = -38] [set plabel "Zona Sur Descarga"]
  ask patches with [pxcor = -41 and pycor = -2] [set plabel "Zona de Inicio - Preparación"]
  setup-cars
  setup-time
  setup_descargas
  setup_casino
  reset-ticks
end

to setup-road ;; patch procedure
  if pycor < 2 and pycor = 0 and pxcor <= 23[ set pcolor white ]
  if pycor < 0 and pycor > -2 and pxcor <= 23 [ set pcolor orange ]
  if pycor < 1 and pycor > -2 and pxcor = 23 [set pcolor red]
  if pycor < 1 and pycor > -2 and pxcor > -20 and pxcor < -17 [set pcolor yellow]

  if pycor < 1 and pycor > -2 and pxcor = 6  [set pcolor grey]
  if pycor < 1 and pycor > -2 and pxcor = 7  [set pcolor grey]

  if pxcor = 6 and pycor < -1 and pycor >= -37 [ set pcolor orange ]
  if pxcor = 7 and pycor < -1 and pycor >= -35 [ set pcolor white ]

  if pxcor > 1 and pxcor < 5 and pycor < -1 and pycor > -6 [set pcolor pink]
  if pxcor = 3 and pycor = -2  [set pcolor brown]

  if pxcor > 6  and pxcor < 31 and pycor = -36 [ set pcolor white ]
  if pxcor >= 7  and pxcor < 31 and pycor = -37  [ set pcolor orange ]

  if pycor <= -36 and pycor >= -37 and pxcor = 31 [set pcolor green]
end

to setup-cars
  set-default-shape turtles "truck"
  create-turtles numero-de-camiones-flota1
  [
    set color blue
    set size 0.8
    set xcor -22
    set heading 90
    set speed random-normal Velocidad 0.01       ; 32 km/hora = 0,27 pt/ticks ; 50 km/hora = 0,42 pt/ticks ; 95 km/hora = 0,80 pt/ticks
    set speed-min 0
    set wait-time 0
    set return 0
    set uploading 0
    set downloading 0
    set numero-viajes 0
    set flota 1
    set way 1
    set lento? false
    set comer? false
    set comiendo? false
    set comido? false
    set turno_finalizado? false
    set time_start_lunch 0
    set time_finish_lunch 0
    set cargado_inicio? false
    set ready? false
    set preparation_time random-normal Media_perdida_inicio_turno Std_perdida_inicio_turno
    set mi_velocidad_limite velocidad-limite
    set mi_velocidad_inicial speed
    set reposo? false
    record-data
    record-data-zona-descarga
    record-data-zona-carga
  ]
  create-turtles numero-de-camiones-flota2
  [
    set color red
    set size 0.8
    set xcor -22
    set shape "truck"
    set heading 90
    set speed random-normal Velocidad 0.01  ; 32 km/hora = 0,27 pt/ticks
    set speed-min 0
    set wait-time 0
    set return 0
    set uploading 0
    set downloading 0
    set numero-viajes 0
    set flota 2
    set way 1
    set lento? false
    set comer? false
    set comiendo? false
    set comido? false
    set turno_finalizado? false
    set time_start_lunch 0
    set time_finish_lunch 0
    set cargado_inicio? false
    set ready? false
    set preparation_time random-normal Media_perdida_inicio_turno Std_perdida_inicio_turno
    set mi_velocidad_limite velocidad-limite
    set mi_velocidad_inicial speed
    set reposo? false
    record-data
    record-data-zona-descarga
    record-data-zona-carga
  ]
  setup_inicio_cars
end

to setup_inicio_cars
  ask n-of camiones_cargados_inicio_flota1 turtles with [flota = 1] [ set cargado_inicio? true set xcor -20]   ;; selecciona al azar turtles cargadas al azar
  ask n-of camiones_cargados_inicio_flota2 turtles with [flota = 2] [ set cargado_inicio? true set xcor -20]   ;; selecciona al azar turtles cargadas al azar
  ask turtles with [cargado_inicio? = false] [set ycor -1 set xcor  -17 set heading 270 set shape "truck-flip" ]
  ask n-of  ((numero-de-camiones-flota1 + numero-de-camiones-flota2) * %_camiones_lentos / 100 ) turtles [ set lento? true set mi_velocidad_limite velocidad-limite-lentos  set speed speed * 0.5 set mi_velocidad_inicial speed  ]   ;; selecciona al azar turtles lentas
end

to setup-time
  set hours 29
  set minutes 0
  set seconds 0
  set counter_time 0
  set time_box 0
end

to setup_descargas
  set num_descargas_zona_norte 0
  set num_descargas_zona_sur 0
  set temp_total_descargas 0
  set production []
  set preparation []
  set loading []
  set launching []
  set num_turtle 0
  set num_turtle_zn 0
  set num_turtle_zs 0
  set tail_uploading []
  set tail_downloading_zn []
  set tail_downloading_zs []
  set next_truck_move -1
  set next_truck_move_zn -1
  set next_truck_move_zs -1

end

to setup_casino
  set capacity_max_lunch_t1 0
  set capacity_max_lunch_t2 0
  set camiones_a_comer_flota1_t1 0
  set camiones_a_comer_flota2_t1 0
  set camiones_a_comer_flota1_t2 0
  set camiones_a_comer_flota2_t2 0
  set number_car_finish 0
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SIMULACION ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
to go

  ;; Stop simulation if all trucks are finalizaded work in the end of turn.
  if (number_car_finish = numero-de-camiones-flota1 + numero-de-camiones-flota2) [stop]

  ;; Define plot variables segun horario
       ;; [8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37]
  ;let y.a [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
  let y.a [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
  let y.b [0 6 12 18 24 30 36 42 48 54 60 66 72 78 84 90 96 102 108 114 120 126 132 138 144 150 156 162 168 174 ]
  let plotname "produccion"
  let ydata (list y.a y.b)
  let pencols (list 16 56)
  let barwidth 2
  let step 0.01
  let j 2
  let value 30
  ;; Call the plotting procedure
  ;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INICIO DE TURNO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask turtles with [ready? = false ][ if actual-time >= preparation_time [set ready? true record-preparation who flota actual-time] ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask turtles with [flota = 1 and turno_finalizado? = false and ready? = true]
  [
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SI HAY UN CAMION DELANTE DESACELERA EN CASO CONTRARIO ACELERA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if [ pcolor ] of patch-here != red and [ pcolor ] of patch-here != yellow and comiendo? != true
    [
      let car-ahead one-of turtles-on patch-ahead 1.0
      ifelse car-ahead != nobody [ slow-down-car car-ahead ] [ speed-up-car ] ;; otherwise, speed up
    ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PRIMER TURNO DE ALMUERZO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if time_box >= 4 and time_box <= 5 and way = 0 and uploading != 1 and comido? = false and comiendo? = false and comer? = false and [ pxcor ] of patch-here >= 3
      [
      if (capacity_max_lunch_t1 < capacidad_maxima_casino )
        [
        set camiones_a_comer_flota1_t1 camiones_a_comer_flota1_t1 + 1
        set capacity_max_lunch_t1 capacity_max_lunch_t1 + 1
        set comer? true
        set color green
        ]
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SEGUNDO TURNO DE ALMUERZO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if time_box >= 5 and way = 0 and uploading != 1 and comido? = false and comiendo? = false and comer? = false and [ pxcor ] of patch-here >= 3
      [
       set camiones_a_comer_flota1_t2 camiones_a_comer_flota1_t2 + 1
       set capacity_max_lunch_t2 capacity_max_lunch_t2 + 1
       set comer? true
       set color green
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INGRESO A CASINO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comer? = true
      [
      if [ pxcor ] of patch-here = 3 and [ pycor ] of patch-here = -1 and heading = 270 ; hacia la izquierda a la zona de carga y antes del casino
       [
        set heading 180
        set shape "truck abajo"
        fd 2
        set speed 0
        set comiendo? true
        set time_start_lunch actual-time
        set time_finish_lunch actual-time + 240 + random 60
        record-launching who flota time_start_lunch time_finish_lunch
       ]
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SALIDA DE CASINO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comiendo? = true and time_finish_lunch < actual-time     ; finish launch
      [
      set comiendo? false
      set xcor 3
      set ycor -1
      set heading 270
      set color blue
      set shape "truck-flip"
      set speed mi_velocidad_inicial
      set comer? false
      set comido? true
      ]

;;;;;;;;;;;;;;;;;;;;;;; ANTES DE LLEGAR A LA ZONA DE CARGA, SI HAY N CAMIONES CARGANDO REPOSA EN LA ZONA DESCARGA POS X -19, Y -1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if [pxcor] of patch-ahead 1 = -19 and [pycor] of patch-ahead 1 = -1 and heading = 270 and count turtles with [uploading = 1 and pxcor = -19 and pycor = -1] >= max_camiones_carga and reposo? = false
      [ set color black set speed 0 set reposo? true  set tail_uploading lput who tail_uploading set xcor -18 set ycor -1]

;;;;;;;;;;;;;;;;;;;;;;; ANTES DE LLEGAR A LA ZONA DE DESCARGA, SI HAY N CAMIONES DESCARGANDO REPOSA EN LA ZONA DESCARGA POS X 22, Y 0 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if [pxcor] of patch-ahead 1 = 23 and [pycor] of patch-ahead 1 = 0 and heading = 90 and count turtles with [downloading = 1 and pxcor = 23 and pycor = 0] >= max_camiones_desc_zn and reposo? = false
      [ set color black set speed 0 set reposo? true  set tail_downloading_zn lput who tail_downloading_zn set xcor 22 set ycor 0]

 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMION AVANZA Y AJUSTA SU VELOCIDAD  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comiendo? != true and reposo? = false
      [

      if speed < speed-min [ set speed speed-min ]
      if speed > mi_velocidad_limite [ set speed mi_velocidad_limite ]
      fd speed

      ]
    record-data
    record-data-zona-descarga
    record-data-zona-carga
  ]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIN FLOTA 1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask turtles with [flota = 2 and turno_finalizado? = false and ready? = true]
  [
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SI HAY UN CAMION DELANTE DESACELERA EN CASO CONTRARIO ACELERA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if [ pcolor ] of patch-here != green and [ pcolor ] of patch-here != yellow and comiendo? != true
      [
      let car-ahead one-of turtles-on patch-ahead 1.0
       ifelse car-ahead != nobody [ slow-down-car car-ahead ] [ speed-up-car ] ;; otherwise, speed up
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMBIO DE DIRECCION EN PRIMERA INTERSECCION IDA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if [ pxcor ] of patch-here = 7 and heading = 90 and comer? != true and way = 1
      [
      set xcor 7
      set heading 180
      set shape "truck abajo"
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMBIO DE DIRECCION EN SEGUNDA INTERSECCION IDA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if [ pxcor ] of patch-here = 7 and [ pycor ] of patch-here = -36 and heading = 180 and comer? != true and way = 1
      [
      set ycor -36
      set heading 90
      set shape "truck"
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMBIO DE DIRECCION EN PRIMERA INTERSECCION VUELTA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
     if [ pxcor ] of patch-here = 6 and [ pycor ] of patch-here = -37 and heading = 270 and way = 0
       [
       set xcor 6
       set heading 0
       set shape "truck arriba"
       ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMBIO DE DIRECCION EN SEGUNDA INTERSECCION VUELTA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if [ pxcor ] of patch-here = 6 and heading = 0 and [ pycor ] of patch-here = -1
      [
      set ycor -1
      set heading 270
      set shape "truck-flip"
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PRIMER TURNO DE ALMUERZO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if time_box >= 4 and time_box <= 5 and way = 0 and uploading != 1 and comido? = false  and comiendo? = false and comer? = false and [ pxcor ] of patch-here >= 3
      [
      if (capacity_max_lunch_t1 < capacidad_maxima_casino)
        [
        set camiones_a_comer_flota2_t1 camiones_a_comer_flota2_t1 + 1
        set capacity_max_lunch_t1 capacity_max_lunch_t1 + 1
        set comer? true
        set color black
        ]
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SEGUNDO TURNO DE ALMUERZO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if time_box >= 5 and way = 0 and uploading != 1 and comido? = false and comiendo? = false and comer? = false and [ pxcor ] of patch-here >= 3
      [
       set camiones_a_comer_flota2_t2 camiones_a_comer_flota2_t2 + 1
       set capacity_max_lunch_t2 capacity_max_lunch_t2 + 1
       set comer? true
       set color black
      ]
    ;record-data
    ;record-data-zona-descarga
    ;record-data-zona-carga
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; INGRESO A CASINO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comer? = true
      [
      if [ pxcor ] of patch-here = 3 and [ pycor ] of patch-here = -1 and heading = 270       ; hacia la izquierda a la zona de carga y antes del casino
        [
        set heading 180
        set shape "truck abajo"
        fd 2
        set speed 0
        set comiendo? true
        set time_start_lunch actual-time
        set time_finish_lunch actual-time + 240 + random 60
        record-launching who flota time_start_lunch time_finish_lunch
        ]
      ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; SALIDA DE CASINO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comiendo? = true  and time_finish_lunch < actual-time
      [
      set xcor 3
      set ycor -1
      set heading 270
      set color red
      set shape "truck-flip"
      set speed mi_velocidad_inicial
      set comer? false
      set comiendo? false
      set comido? true
      ]


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ANTES DE LLEGAR A LA ZONA DE CARGA X -19, Y -1, SI HAY N CAMIONES CARGANDO REPOSA EN LA ZONA DESCARGA POS X -18, Y -1 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if [pxcor] of patch-ahead 1 = -19 and [pycor] of patch-ahead 1 = -1 and heading = 270 and count turtles with [uploading = 1 and pxcor = -19 and pycor = -1] >= max_camiones_carga and reposo? = false
      [ set color black set speed 0 set reposo? true  set tail_uploading lput who tail_uploading set xcor -18 set ycor -1] ; set turn of trucks at repose zone

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; ANTES DE LLEGAR A LA ZONA DE DESCARGA, SI HAY N CAMIONES DESCARGANDO REPOSA EN LA ZONA DESCARGA SUR POS X 30, Y -36 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

      if [pxcor] of patch-ahead 1 = 31 and [pycor] of patch-ahead 1 = -36 and heading = 90 and count turtles with [downloading = 1 and pxcor = 31 and pycor = -36] >= max_camiones_desc_zn and reposo? = false
      [ set color black set speed 0 set reposo? true  set tail_downloading_zn lput who tail_downloading_zn set xcor 30 set ycor -36]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; CAMION AVANZA Y AJUSTA SU VELOCIDAD ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
    if comiendo? != true and reposo? = false        ;; don't slow down below speed minimum or speed up beyond speed limit
      [

      if speed < speed-min [ set speed speed-min ]
      if speed > mi_velocidad_limite [ set speed mi_velocidad_limite ]
      fd speed
      ]



    record-data
    record-data-zona-descarga
    record-data-zona-carga
  ]  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIN FLOTA 2 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 1 EN ZONA DE DESCARGA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask patches with [pycor = 0 and pxcor = 23 ]
  [
    ask turtles-here with [flota = 1 and ready? = true]
    [
      if downloading = 0
      [
        set color pink
        set speed 0
        set last-wait-time-descarga tiempo-min-de-descarga + random (tiempo-max-de-descarga - tiempo-min-de-descarga)
        set wait-time-descarga actual-time + last-wait-time-descarga
        set downloading 1
      ]
      if wait-time-descarga = actual-time
      [
        set xcor 23
        set ycor -1
        set shape "truck-flip"
        set color blue
        ;rt 180
        set heading 270
        set numero-viajes numero-viajes + 1
        set downloading 0
        set way 0
        set num_descargas_zona_norte num_descargas_zona_norte  + 1
        set speed mi_velocidad_inicial
        record-production who flota 1 last-wait-time-descarga wait-time-descarga
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 2 EN ZONA DE DESCARGA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ask patches with [pycor = -36 and pxcor = 31]
  [
    ask turtles-here with [flota = 2 and ready? = true]
    [

      if downloading = 0
      [
        set color pink
        set speed 0
        set last-wait-time-descarga tiempo-min-de-descarga + random (tiempo-max-de-descarga - tiempo-min-de-descarga)
        set wait-time-descarga actual-time + last-wait-time-descarga
        set downloading 1
      ]
      if wait-time-descarga = actual-time
      [
        set xcor 31
        set ycor -37
        set shape "truck-flip"
        set color red
        set heading 270
        set numero-viajes numero-viajes + 1
        set downloading 0
        set way 0
        set num_descargas_zona_sur  num_descargas_zona_sur + 1
        set speed mi_velocidad_inicial
        record-production who flota 1 last-wait-time-descarga wait-time-descarga
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 1 EN ZONA DE CARGA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


  ask patches with [pycor = -1 and pxcor = -19]
  [

    ask turtles-here with [flota = 1 and ready? = true]
    [
      if time_box < Hora_termino_turno and turno_finalizado? = false
      [
        if comer? != true
        [

          if uploading = 0
          [
            set color pink
            set speed 0
            set last-wait-time-carga tiempo-min-de-carga + random (tiempo-max-de-carga - tiempo-min-de-carga)
            set wait-time-carga actual-time + last-wait-time-carga
            set uploading 1
          ]


          if wait-time-carga = actual-time
          [
            set ycor 0
            set shape "truck"
            rt 180
            set numero-viajes numero-viajes + 1
            set uploading 0
            set way 1
            set color blue
            set speed mi_velocidad_inicial
            record-loading who flota last-wait-time-carga wait-time-carga
          ]
        ]
        if comer? = true
        [
          set ycor 0
          set shape "truck"
          set color green
          rt 180
        ]
      ]
      if time_box >= Hora_termino_turno and turno_finalizado? != true    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FINALIZACION DEL TURNO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      [
        set turno_finalizado? true
        set xcor -22
        set number_car_finish  number_car_finish + 1
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FLOTA 2 EN ZONA DE CARGA ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;



  ask patches with [pycor = -1 and pxcor = -19]
  [

    ask turtles-here with [flota = 2 and ready? = true]
    [
      if time_box < Hora_termino_turno and turno_finalizado? = false
      [
        if comer? != true
        [

          if uploading = 0
          [
            set color pink
            set speed 0
            set last-wait-time-carga tiempo-min-de-carga + random (tiempo-max-de-carga - tiempo-min-de-carga)
            set wait-time-carga actual-time + last-wait-time-carga
            set uploading 1
          ]

          if wait-time-carga = actual-time
          [
            set ycor 0
            set shape "truck"
            rt 180
            set numero-viajes numero-viajes + 1
            set uploading 0
            set way 1
            set color red
            set speed mi_velocidad_inicial
            record-loading who flota last-wait-time-carga wait-time-carga
          ]
        ]
        if comer? = true
        [
          set ycor 0
          set shape "truck"
          set color orange
          rt 180
        ]
      ]
      if time_box >= Hora_termino_turno and turno_finalizado? != true    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FINALIZACION DEL TURNO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
      [
        set turno_finalizado? true
        set xcor -22
        set number_car_finish  number_car_finish + 1
      ]
    ]
  ]
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PROCEDIMIENTO DE TIEMPO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  tick
  set actual-time ticks
  ; set actual hours, minutes and seconds
  ; Turno comienza 8:00 - tick 0
  ; 1 segundo = 1/15 ticks
  ; 1 minuto = 4 ticks
  ; 60 minutos/ 1 hora = 4x60 ticks = 240 ticks

  set seconds 15 + seconds
  if seconds = 60
  [
    set seconds 0
    set minutes minutes + 1
    if minutes = 60
    [
      set minutes 0
      set hours hours + 1
      ; time_box = 0 when time is 8:00 hrs.
      ; create production bar plot
      if time_box < 30
      [
        set time_box hours - 29
        let total_descargas  num_descargas_zona_norte + num_descargas_zona_sur - temp_total_descargas
        set temp_total_descargas num_descargas_zona_norte + num_descargas_zona_sur
        productionsbarplot plotname y.a pencols barwidth step total_descargas time_box
      ]
    ]
  ]

  ;; ENTREGA EL TURNO PARA ZONA DE CARGA AL SIGUIENTE CAMION

     set num_turtle count turtles with [uploading = 1 and pxcor = -19 and pycor = -1 and heading = 270 ]


    if num_turtle < max_camiones_carga and length tail_uploading > 0
    [
      let next_truck first tail_uploading
      next_turn_uploading next_truck ]

    ;; ENTREGA EL TURNO PARA ZONA DE DESCARGA AL SIGUIENTE CAMION EN ZONA DE DESCARGA  NORTE

     set num_turtle_zn count turtles with [downloading = 1 and pxcor = 23 and pycor = 0 and heading = 90 ]
;     print num_turtle_zn
;     print tail_downloading_zn

    if num_turtle_zn < max_camiones_desc_zn and length tail_downloading_zn > 0
    [
      let next_truck_zn first tail_downloading_zn
      next_turn_downloading next_truck_zn ]

    ;; ENTREGA EL TURNO PARA ZONA DE DESCARGA AL SIGUIENTE CAMION EN ZONA DE DESCARGA  SUR

     set num_turtle_zs count turtles with [downloading = 1 and pxcor = 31 and pycor = -36 and heading = 90 ]
;     print num_turtle_zs
;     print tail_downloading_zs

    if num_turtle_zs < max_camiones_desc_zs and length tail_downloading_zs > 0
    [
      let next_truck_zs first tail_downloading_zs
      next_turn_downloading next_truck_zs ]


end    ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; FIN GO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PROCEDIMIENTOS DE AGENTES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to next_turn_uploading [ntruck]

   ask turtles with [who = ntruck]
    [
       set speed mi_velocidad_inicial
       set reposo? false
       set tail_uploading remove-item 0 tail_uploading
   ]
end

to next_turn_downloading [ntruck]

   ask turtles with [who = ntruck]
    [
       set speed mi_velocidad_inicial
       set reposo? false
       set tail_downloading_zn remove-item 0 tail_downloading_zn
   ]
end


to slow-down-car [ car-ahead ] ;; turtle procedure slow down so you are driving more slowly than the car ahead of you
  set speed [ speed ] of car-ahead - 0.01           ;;;;; set speed [ speed ] of car-ahead - desaceleracion
end

to speed-up-car ;; turtle procedure
  set speed speed + 0.01                     ;;;;;;; set speed speed + aceleracion
end

;; keep track of the number of stopped turtles and the amount of time a turtle has been stopped
;; if its speed is 0
to record-data  ;; turtle procedure
  ifelse speed = 0
  [
    ;set num-cars-stopped num-cars-stopped + 1
    set last-wait-time last-wait-time + 1
  ]
  [ set last-wait-time 0 ]
end

to record-data-zona-carga  ;; turtle procedure
  ifelse speed = 0
  [
    ;set num-cars-stopped num-cars-stopped + 1
    set last-wait-time-carga last-wait-time-carga + 1
  ]
  [ set last-wait-time-carga 0 ]
end

to record-data-zona-descarga  ;; turtle procedure
  ifelse speed = 0
  [
    ;set num-cars-stopped num-cars-stopped + 1
    set last-wait-time-descarga last-wait-time-descarga + 1
  ]
  [ set last-wait-time-descarga 0 ]
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; PLOTEO ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to productionsbarplot [plotname ydata pencols barwidth step num_total_descargas box ]

  ;; Get n from ydata -> number of groups (colors)
  let n length ydata
  let i 0

  ;show ydata
  ;show  item 1 ydata
  ;set ydata replace-item 1 ydata 69
  set ydata replace-item box ydata num_total_descargas
  ;show ydata

  let y ydata
  let x [0 6 12 18 24 30 36 42 48 54 60 66 72 78 84 90 96]

   ;; Initialize the plot (create a pen, set the color, set to bar mode and set plot-pen interval)
    set-current-plot plotname
    create-temporary-plot-pen (word i)
    set-plot-pen-color 56
    set-plot-pen-mode 1
    set-plot-pen-interval step

   ;; Loop over xy values from the two lists:
    let j 0
    while [j < length x]
    [
      ;; Select current item from x and y and set x.max for current bar, depending on barwidth
      let x.temp item j x
      let x.max x.temp + (barwidth * 0.97)
      let y.temp item j y

      ;; Loop over x-> xmax and plot repeatedly with increasing x.temp to create a filled barplot
      while [x.temp < x.max]
      [
        plotxy x.temp y.temp
        set x.temp (x.temp + step)
      ] ;; End of x->xmax loop
      set j (j + 1)
    ] ;; End of dataloop for current group (i)
end
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; REPORTES ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

to record-production [quien zone down lw wt]

    let prod []
    set prod lput who prod ; Id turttle
    set prod lput zone prod ; ID zone = 1 North Zone
    set prod lput down prod  ; one download
    set prod lput last-wait-time-descarga prod ; duration in ticks
    set prod lput wait-time-descarga prod ; time in ticks
    set production lput prod production


end

to record-preparation [quien fl time]

    let prep []
    set prep lput quien prep ; Id turttle
    set prep lput fl prep ; ID zone = 1 North Zone
    set prep lput time prep ; time in ticks
    set preparation lput prep preparation
end

to record-loading [quien zone lw wt]

    let prod []
    set prod lput who prod ; Id turttle
    set prod lput zone prod ; ID zone = 1 North Zone
    set prod lput last-wait-time-carga prod ; duration in ticks
    set prod lput wait-time-carga prod ; time in ticks
    set loading lput prod loading
end

to record-launching [quien fl time_start time_finish]

    let launch []
    set launch lput who launch ; Id turttle
    set launch lput flota launch ; ID zone = 1 North Zone
    set launch lput time_start launch ; duration in ticks
    set launch lput time_finish launch ; time in ticks
    set launching lput launch launching


end

to simulation_report  ;; Report of main information of simulation

  print "---Reporte de simulación---"
  print "Tiempos de preparación:[Id tortuga, flota, tiempo preparacion]"
  print preparation
  print "Tiempos de carga: [Id tortuga, zona, duracion ticks, hora ticks]"
  print loading
  print "Tiempos de almuerzo: [Id tortuga, flota, hora inicio almuerzo ticks, hora fin almuerzo ticks]"
  print  launching
  print "Producción: [Id tortuga, zona, 1 descarga, duracion ticks, hora ticks]"
  print production

  ; create a file with results

  ;set tb-memory table:from-list preparation
  ;set tb-memory table:from-list [[1 2] [3 4] [5 6]]
  ;file-open "simulation.csv"
  ;file-print csv:to-string table:to-list tb-memory

  csv:to-file "simulation-preparation.csv" preparation
  csv:to-file "simulation-loading.csv" loading
  csv:to-file "simulation-launching.csv" launching
  csv:to-file "simulation-production.csv" production
  print "Archivo creado!"

end





; Copyright 2021 Jorge Gonzalez -  Mario Herrera  - Adolfo Ibañez Univerity - Chile.
; See Info tab for full copyright and license.
@#$#@#$#@
GRAPHICS-WINDOW
625
10
1278
563
-1
-1
11.121
1
10
1
1
1
0
0
0
1
-22
35
-45
3
1
1
1
ticks
300.0

BUTTON
15
10
85
43
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
90
10
160
43
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
15
50
210
83
numero-de-camiones-flota1
numero-de-camiones-flota1
1
30
15.0
1
1
NIL
HORIZONTAL

PLOT
15
300
315
465
Velocidad camiones
time
speed
0.0
300.0
0.0
1.1
true
true
"" ""
PENS
"Max" 1.0 0 -2674135 true "" "plot max [speed] of turtles"
"Min" 1.0 0 -13345367 true "" "plot min [speed] of turtles"
"Prom" 1.0 0 -10899396 true "" "plot mean [speed] of turtles"

MONITOR
295
250
355
295
Velocidad
mean [speed] of turtles
3
1
11

SLIDER
1295
55
1490
88
tiempo-min-de-carga
tiempo-min-de-carga
1
100
55.0
1
1
NIL
HORIZONTAL

SLIDER
1295
135
1490
168
tiempo-min-de-descarga
tiempo-min-de-descarga
1
100
23.0
1
1
NIL
HORIZONTAL

SLIDER
1295
215
1490
248
velocidad-limite
velocidad-limite
0.5
0.8
0.8
0.1
1
NIL
HORIZONTAL

PLOT
15
600
315
765
Tiempo promedio espera camiones
Tiempo
Espera promedio
0.0
100.0
0.0
5.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot mean [last-wait-time] of turtles"

SLIDER
1295
95
1490
128
tiempo-max-de-carga
tiempo-max-de-carga
1
100
61.0
1
1
NIL
HORIZONTAL

SLIDER
1295
175
1490
208
tiempo-max-de-descarga
tiempo-max-de-descarga
1
100
33.0
1
1
NIL
HORIZONTAL

MONITOR
360
250
440
295
Tiempo Carga
mean [last-wait-time-carga] of turtles
2
1
11

MONITOR
445
250
540
295
Tiempo descarga
mean [last-wait-time-descarga] of turtles
2
1
11

PLOT
320
600
620
765
Tiempo promedio zonas carga/descarga
Tiempo
Espera promedio
0.0
100.0
0.0
10.0
true
true
"" ""
PENS
"Descarga" 1.0 0 -2674135 true "" "plot mean [last-wait-time-descarga] of turtles"
"Carga f1" 1.0 0 -1184463 true "" "plot mean [last-wait-time-carga] of turtles with [flota = 1]"
"Carga f2" 1.0 0 -13840069 true "" "plot mean [last-wait-time-carga] of turtles with [flota = 2]"

SLIDER
215
50
410
83
numero-de-camiones-flota2
numero-de-camiones-flota2
1
30
15.0
1
1
NIL
HORIZONTAL

MONITOR
15
250
65
295
Hora
hours - 21
0
1
11

MONITOR
70
250
120
295
Minutos
minutes
0
1
11

PLOT
320
300
620
465
produccion
Tiempos
Descargas
0.0
70.0
0.0
22.0
true
true
"" ""
PENS

MONITOR
545
250
620
295
# Descargas
num_descargas_zona_norte + num_descargas_zona_sur
0
1
11

SLIDER
415
90
610
123
%_camiones_lentos
%_camiones_lentos
0
50
15.0
1
1
NIL
HORIZONTAL

MONITOR
200
250
290
295
camiones lentos
(numero-de-camiones-flota1 + numero-de-camiones-flota2) * %_camiones_lentos / 100
0
1
11

MONITOR
215
470
410
515
# comidos f1 t1
camiones_a_comer_flota1_t1
0
1
11

MONITOR
415
470
610
515
# comidos f2 t1
camiones_a_comer_flota2_t1
0
1
11

MONITOR
215
520
410
565
# comidos f1 t2
camiones_a_comer_flota1_t2
0
1
11

MONITOR
415
520
610
565
# comidos f2 t2
camiones_a_comer_flota2_t2
0
1
11

SLIDER
1295
15
1490
48
capacidad_maxima_casino
capacidad_maxima_casino
1
50
15.0
1
1
NIL
HORIZONTAL

MONITOR
15
470
210
515
a comer turno 1
capacity_max_lunch_t1
0
1
11

MONITOR
15
520
210
565
a comer turno 2
capacity_max_lunch_t2
0
1
11

MONITOR
125
250
195
295
Actual Ticks
actual-time
0
1
11

SLIDER
15
90
210
123
camiones_cargados_inicio_flota1
camiones_cargados_inicio_flota1
0
30
2.0
1
1
NIL
HORIZONTAL

SLIDER
215
90
410
123
camiones_cargados_inicio_flota2
camiones_cargados_inicio_flota2
0
30
3.0
1
1
NIL
HORIZONTAL

SLIDER
1295
255
1490
288
velocidad-limite-lentos
velocidad-limite-lentos
0.5
1
0.5
0.1
1
NIL
HORIZONTAL

BUTTON
165
10
235
43
Reporte
simulation_report
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
15
130
210
163
max_camiones_carga
max_camiones_carga
1
10
4.0
1
1
NIL
HORIZONTAL

SLIDER
215
130
410
163
max_camiones_desc_zn
max_camiones_desc_zn
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
415
130
610
163
max_camiones_desc_zs
max_camiones_desc_zs
0
10
1.0
1
1
NIL
HORIZONTAL

SLIDER
15
170
210
203
Media_perdida_inicio_turno
Media_perdida_inicio_turno
0
400
326.0
1
1
NIL
HORIZONTAL

SLIDER
215
170
410
203
Std_perdida_inicio_turno
Std_perdida_inicio_turno
0
400
302.0
1
1
NIL
HORIZONTAL

SLIDER
415
50
610
83
Velocidad
Velocidad
0
0.8
0.8
0.1
1
NIL
HORIZONTAL

SLIDER
415
170
610
203
Hora_termino_turno
Hora_termino_turno
10
11
11.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
## QUE ES?

La flota 1 tiene como objetivo cargar en la zona amarilla y descargar en la zona roja. La flota 2 tiene como objetivo cargar en la zona amarilla y descargar en la zona verde.  


## DISEÑO


* Configuración del mundo:

Una zona de preparación-inicio
Una zona de carga (Zona amarilla)
Dos zonas de descarga. Zona norte (Zona Roja) y zona sur  (Zona Verde)
Un Casino (Zona café y Rosada)
Una interseccion. (Zona gris)
Distancias de zona de origen a la zona de descarga norte: 9 km, ida-vuelta = 18 km       

* Variables:

Número de camiones flota 1, camiones color azul y descargan en zona norte.
Número de camiones flota 2, camiones color rojo y descargan en zona sur.
Velocidad máxima de los camiones es 44 km/hora
Velocidad promedio de los camiones es 31-32 km/hora       

* Horario y ticks:

1 segundo = 1/15 ticks
15 segundos = 1 ticks
1 minuto = 4 ticks
60 minutos/ 1 hora = 4x60 ticks = 240 ticks
600 minutos /10 horas = 10x4x60 = 2400 ticks 
Turno comienza 8:00 - tick 0
 09:00 - tick 240,10:00 - tick 480, 11:00 - tick 720, etc.. (240 ticks * N )

Tiempos:

Tiempo de inicio de turno: 8 a 9 hrs - 81 minutos media.
Tiempo de ciclo = 57 minutos
Tiempo de carga = 15 minutos de media
Tiempo de fin de turno:
Duración del turno: 8:00 a 20:00 / 12 horas de duración.

08:00 - tick 0 - Inicio de Turno
09:00 - tick 240
10:00 - tick 480
11:00 - tick 720
12:00 - tick 960
13:00 - tick 1200
14:00 - tick 1440
15:00 - tick 1680
16:00 - tick 1920
17:00 - tick 2160
18:00 - tick 2400 - inicio finalizacion del turno+
19:00 - tick 2640
20:00 - tick 2880 - Fin turno


* Distancias:

1 KM = 2 PATCHES
60 minutos = 1 hora = 4x60 ticks = 240 ticks
1 KM/HORA = 2 PT / 240 ticks  =  0,0083
10 KM/HORA = 0,083 PT/ticks

Velocidad máxima de los camiones es 44 km/hora = 0,37 pt/ticks
Velocidad promedio de los camiones es 32 km/hora   = 0,27 pt/ticks
1 fd =  1 patch = 0.5 km


* Turno:

El turno comienza a las 8:00 y se espera finalice a las 20:00 horas.

Todos los camiones al inicio del turno comienzan en la zona de preparación-inicio

Camiones se preparan en la zona de preparación y están separados.

Al inicio existen camiones aleatorios que ya están cargados

El orden de salida de los camiones es aleatorio

Existe un tiempo aleatorio de 40 minutos +/- 40 minutos aleatorio (rango 40 a 80 minutos) preparación de inicio para cada camión, segun culmina su tiempo de preparación inician su trabajo, ya sea de carga (para camiones no cargados)  como el camino a la descarga (para camiones inicialmente cargados)

Desde las 19:00 los camiones que están descargados no siguen cargando y se van a la zona de preparación, finalizando sus viajes. Los camiones que están cargados van a su zona a descargar y luego finalizan su turno, dirigiéndose a la zona de preparación.

Con el último camión ingresando a la zona de preparación, finaliza el turno (debería ser aproximado a las 20 hrs), deteniéndose automáticamente la simulación.

* Viaje:

Los camiones se agrupan en flota 1 y flota 2.

Si se encuentran con un camión delante bajan su velocidad para no chocar.

La flota 1 debe cargar material en la zona de carga y descarga en la zona de descarga zona norte.

La flota 2 debe cargar material en la zona de carga y descarga en la zona de descarga zona sur.

Existe un tiempo aleatorio de tiempo de carga y tiempo de descarga en la zona norte y en la zona sur.


* Almuerzo en el casino:

Existen dos turnos de almuerzo: turno 1 a las  13:00  horas y turno 3 a las 14:30 horas.

Entre  las 12:30 hrs y 13:00 hrs los camiones que están descargados y están camino al casino deben ir a comer al casino, hasta alcanzar la capacidad máxima del casino.

El resto de los camiones deben ir a almorzar desde las 14:30 hrs.

Los operadores de los camiones almuerzan una hora + delta de tiempo aleatorio  en el rango de 15 minutos.

Luego de almorzar los camiones están 100% descansados.

* Camiones lentos y velocidad:

Existen camiones lentos. Se puede definir el % de números de camiones lentos y la velocidad límite del camión lento. 

El camión lento tiene una velocidad límite lenta, que debe ser inferior a la velocidad límite normal. Además su velocidad se define como un 10% menor a la velocidad de un camión normal aleatorio.


* Salidas y mediciones:

Producción: número de descargas de ambas flotas realizadas en periodos de una hora durante el turno. 

Cantidad de descargas

Total Pérdida = Tiempo inicio de turno + fin de turno + perdida de la colacion
Excede de la hora
Perdida por colas.




## COMO USARLO?

Cliquear el boton SETUP para definir el las rutas y camiones.

indicar el número de camiones de la flota 1 y flota 2

indicar el % de camiones que seran lentos.

indicar número de camiones que se consideran cargados al inicio del turno.




## COPYRIGHT AND LICENSE

Copyright 2021 
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

truck abajo
false
0
Rectangle -7500403 true true 45 4 187 195
Polygon -7500403 true true 193 296 150 296 134 259 104 244 104 208 194 207
Rectangle -1 true false 60 195 105 195
Polygon -16777216 true false 112 238 141 252 141 219 112 218
Circle -16777216 true false 174 234 42
Rectangle -7500403 true true 185 181 194 214
Circle -16777216 true false 174 144 42
Circle -16777216 true false 174 24 42
Circle -7500403 false true 174 24 42
Circle -7500403 false true 174 144 42
Circle -7500403 false true 174 234 42

truck arriba
false
0
Rectangle -7500403 true true 45 105 187 296
Polygon -7500403 true true 193 4 150 4 134 41 104 56 104 92 194 93
Rectangle -1 true false 60 105 105 105
Polygon -16777216 true false 112 62 141 48 141 81 112 82
Circle -16777216 true false 174 24 42
Rectangle -7500403 true true 185 86 194 119
Circle -16777216 true false 174 114 42
Circle -16777216 true false 174 234 42
Circle -7500403 false true 174 234 42
Circle -7500403 false true 174 114 42
Circle -7500403 false true 174 24 42

truck-flip
false
0
Rectangle -7500403 true true 105 45 296 187
Polygon -7500403 true true 4 193 4 150 41 134 56 104 92 104 93 194
Rectangle -1 true false 105 60 105 105
Polygon -16777216 true false 62 112 48 141 81 141 82 112
Circle -16777216 true false 24 174 42
Rectangle -7500403 true true 86 185 119 194
Circle -16777216 true false 114 174 42
Circle -16777216 true false 234 174 42
Circle -7500403 false true 234 174 42
Circle -7500403 false true 114 174 42
Circle -7500403 false true 24 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.1
@#$#@#$#@
setup
repeat 180 [ go ]
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="Validacion" repetitions="40" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota1">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacidad_maxima_casino">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-max-de-carga">
      <value value="61"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota2">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_desc_zs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-camiones-flota1">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-camiones-flota2">
      <value value="13"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_carga">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_desc_zn">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-min-de-descarga">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Media_perdida_inicio_turno">
      <value value="326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Velocidad">
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-max-de-descarga">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hora_termino_turno">
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-min-de-carga">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%_camiones_lentos">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Std_perdida_inicio_turno">
      <value value="302"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="velocidad-limite-lentos">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="velocidad-limite">
      <value value="0.8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Eventos_cercania" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="%_camiones_lentos">
      <value value="5"/>
      <value value="50"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Camiones_cargados_fin_turno" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota1">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota2">
      <value value="1"/>
      <value value="10"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Perdidas_inicio_turno" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="Media_perdida_inicio_turno">
      <value value="60"/>
      <value value="326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Std_perdida_inicio_turno">
      <value value="60"/>
      <value value="302"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Perdidas_fin_turno" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="Hora_termino_turno">
      <value value="10"/>
      <value value="11"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Cantidad_excavadora" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="max_camiones_carga">
      <value value="1"/>
      <value value="8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Cantidad_zona_descarga" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="max_camiones_desc_zs">
      <value value="1"/>
      <value value="8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_desc_zn">
      <value value="1"/>
      <value value="8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Cantidad_camiones" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="numero-de-camiones-flota1">
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-camiones-flota2">
      <value value="10"/>
      <value value="30"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="Velocidad_camiones" repetitions="20" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="Velocidad">
      <value value="0.5"/>
      <value value="0.8"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="experiment" repetitions="290" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="2880"/>
    <metric>num_descargas_zona_norte + num_descargas_zona_sur</metric>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota1">
      <value value="2"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="capacidad_maxima_casino">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-max-de-carga">
      <value value="61"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="camiones_cargados_inicio_flota2">
      <value value="3"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_desc_zs">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-camiones-flota1">
      <value value="12"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="numero-de-camiones-flota2">
      <value value="12"/>
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_carga">
      <value value="4"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="max_camiones_desc_zn">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-min-de-descarga">
      <value value="23"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Media_perdida_inicio_turno">
      <value value="326"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Velocidad">
      <value value="0.5"/>
      <value value="0.8"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-max-de-descarga">
      <value value="33"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Hora_termino_turno">
      <value value="10"/>
      <value value="11"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="tiempo-min-de-carga">
      <value value="55"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="%_camiones_lentos">
      <value value="15"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="Std_perdida_inicio_turno">
      <value value="302"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="velocidad-limite-lentos">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="velocidad-limite">
      <value value="0.8"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@
