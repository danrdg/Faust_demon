#!/bin/bash

#Fausto.sh, codificado por Daniel Rodríguez González

#Recibe órdenes creando los procesos y listas adecuadas
#Si el Demonio no está vivo lo crea
#Al leer/escribir en las listas hay que usar bloqueo para no coincidir con el Demonio

#Función que genera el mensaje de ayuda

ayuda () { 
         echo "Fausto.sh run comando - Ejecuta el comando una sola vez"
         echo "Fausto.sh run-servicio comando - Ejecuta el comando como servicio"
         echo "Fausto.sh run-periodic T comando - Ejecuta el comado durante un periodo T"
         echo "Fausto.sh list - Muestra el contenido de las listas procesos, procesos_servicio y procesos_periodicos por pantalla"
         echo "Fausto.sh help - Muestra la lista de comandos disponibles y su sintáxis"
         echo "Fausto stop PID - Comprueba si PID es un proceso creado por Fausto o Demonio para que Demonio lo termine"
         echo "Fausto end - Crea fichero Apocalipsis para que Demonio termine todos los procesos y a si mismo"
         }




#Comprueba si existe Demonio, si no existe lo crea

cadena=`ps gl | grep [D]emonio`
if [ "$cadena" = "" ];
then 
  #Primero borra (si existen) las estructuras usadas por ambos procesos

  rm -f procesos procesos_servicio procesos_periodicos Biblia.txt Apocalipsis SanPedro
  rm -fr Infierno

  #Vuelve a crear las estructuras previamente eliminadas a excepción de Apocalipsis

  touch procesos procesos_servicio procesos_periodicos Biblia.txt SanPedro
  mkdir Infierno

  #Lanza el proceso Demonio
  bash -c 'nohup ./Demonio.sh &' > /dev/null

  #Generamos entrada en la Biblia

  fecha=`date | awk '{print $4}'`
  (
   flock 200
   echo ""$fecha" "------------GENESIS------------"" > ./Biblia.txt
   echo ""$fecha" "El demonio ha sido creado"" >> ./Biblia.txt
  )200<./SanPedro
  
fi


#Analizamos los argumentos de entrada de Fausto

if [ "$1" = "" ];
then
echo "Error, no ha introducido argumentos de entrada, consulte los comandos disponibles con ./Fausto.sh help"

#Primero los casos en los que solo hay un argumento de entrada
else
  if [ "$2" = "" ];
  then
    #Solo un argumento de entrada
    if [ "$1" = "list" ];
    then
      echo "Fichero procesos"
      flock -s SanPedro -c 'cat procesos'
      echo "Fichero procesos_servicio"
      flock -s SanPedro -c 'cat procesos_servicio'
      echo "Fichero procesos_periodicos"
      flock -s SanPedro -c 'cat procesos_periodicos'
    else
      if [ "$1" = "help" ];
      then
        ayuda
      else
        if [ "$1" = "end" ];
        then
          touch Apocalipsis   
        else 
          #Cuando no reconoce el comando
          echo "Error, comando "$1" no reconocido, consulte los comandos disponibles con ./Fausto.sh help"      
        fi
      fi
    fi
  else
    #Dos argumentos o más de entrada para Fausto
      # Ejecutar un comando una sola vez
      if [ "$1" = "run" ];
      then 
        sh -c "$2" &
        #$! contiene el pid del último sh 
        #Registramos el evento al final del fichero procesos
        (
         flock 200
         echo ""$!" "$2"" >> ./procesos
         #También en la Biblia
         fecha=`date | awk '{print $4}'`
         echo ""$fecha" El proceso "$!" "$2" ha nacido." >> ./Biblia.txt
        )200<./SanPedro
        
      else
        # Ejecutar comando como servicio
        if [ "$1" = "run-service" ];
        then 
          sh -c "$2" &
          #$! contiene el PID del último sh 
          #Registramos el evento al final del fichero procesos_servicio
          (
          flock 200
          echo ""$!" "$2"" >> ./procesos_servicio
          #También en la Biblia
          fecha=`date | awk '{print $4}'`
          echo ""$fecha" El proceso "$!" "$2" ha nacido." >> ./Biblia.txt
          )200<./SanPedro
        else
          # Ejecutar comando con reinicio periódico
          if [ "$1" = "run-periodic" ];
          then
            sh -c "$3" &
            #$! contiene el el pid del último sh 
            #Registramos el evento al final del fichero procesos_periodicos
            (
            flock 200
            echo "0 "$2" "$!" "$3"" >> ./procesos_periodicos
            #También en la biblia
            fecha=`date | awk '{print $4}'`
            echo ""$fecha" El proceso "$!" "$3" ha nacido." >> ./Biblia.txt
            )200<./SanPedro
          else
            # Ordenar al demonio terminar procesos 
            if [ "$1" = "stop" ];
            then
              (
              flock -s 200
              #buscamos proceso en los ficheros de listas
              resultado=`cat procesos | grep "$2"`
              if [ "$resultado" = "" ];
              then
                resultado=`cat procesos_servicio | grep "$2"`
                if [ "$resultado" = "" ];
                then
                  resultado=`cat procesos_periodicos | grep "$2"`
                  if [ "$resultado" = "" ];
                  then
                    echo "Error, el proceso no existe, ejecute ./Fausto.sh list para ver los procesos creados"
                  else
                    touch ./Infierno/"$2"
                  fi
                else
                  touch ./Infierno/"$2"
                fi
              else
                touch ./Infierno/"$2"
              fi
              )200<./SanPedro
            else
              #Cuando no reconoce el comando
              echo "Error, comando "$1" "$2" no reconocido, asegurese de que el número de argumentos es correcto, consulte los comandos disponibles con ./Fausto.sh help"
            fi  
          fi
        fi
      fi
    fi
fi
