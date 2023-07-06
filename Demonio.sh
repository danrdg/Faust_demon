#!/bin/bash

#Demonio Dummie, tenéis que completarlo para que haga algo

#Bucle mientras que no llegue el apocalipsis
#   -Espera un segundo
#   -Lee las listas y revive los procesos cuando sea necaario dejando entradas en la biblia
#   -Puede usar todos los ficheros temporales que quiera pero luego en el Apocalipsis hay que borrarlos
#   -Hay que usar un lock para no acceder a las listas a la vez que Fausto
#   -Ojo al cerrar los proceos, hay que terminar el arbol completo no sólo uno de ellos

#Función que actualiza la Biblia
actualiza_biblia() {
                    fecha=`date | awk '{print $4}'`
                    echo ""$fecha" "El proceso" "$1" "ha terminado"" >> ./Biblia.txt
                   }


#Bucle principal
condicion=true
while [ "$condicion" = true ]
do
  sleep 1
  #Recorremos lista de procesos, bloquando recursos antes de acceder
  (
  flock -s 200
  touch ./temporal
  while read linea;
  do
    pid=`echo "$linea" | awk '{print $1}'`
    resultado=`ls -l ./Infierno | grep "$pid"`
    #Comprobamos si existe el fichero en Infierno
    if [ "$resultado" = "" ];
    then
      #Si no existe comprobamos si el proceso sigue en activo
      activo=`ps -l | grep "$pid"`
      if [ "$activo" != "" ];
      then
        #Si sigue en activo copiamos la linea en una nueva lista temporal
        echo "$linea" >> temporal
      else
        #Si no sigue en activo actualizamos la Biblia
        actualiza_biblia "$pid"
      fi
    else
      #Si existe, borramos el fichero de Infierno
      rm -f ./Infierno/"$pid"
      #Terminamos el proceso junto con sus hijos 
      continua=true
      while [ "$continua" = true ]
      do
        pkill -P "$pid"
        activo=`ps -l | grep "$pid"`
        if ["$activo" = ""];
        then
          continua=false
        fi
      done
      #Y actualizamos entrada en la Biblia
      actualiza_biblia "$pid"
    fi
  done < ./procesos
  #Actualizamos la lista original
  cat ./temporal > ./procesos
  )200<./SanPedro
  #Borramos fichero temporal
  rm -f ./temporal

  
  #Recorremos la lista de procesos servicio, bloquando recursos antes de acceder
  (
  flock -s 200
  touch ./temporal
  while read linea;
  do
  pid=`echo "$linea" | awk '{print $1}'`
  resultado=`ls -l ./Infierno | grep "$pid"`
   #Comprobamos si existe el fichero en Infierno
    if [ "$resultado" = "" ];
    then
      #Si no existe comprobamos si el proceso sigue en activo
      activo=`ps -l | grep "$pid"`
      if [ "$activo" != "" ];
      then
        #Si sigue en activo copiamos la linea en una nueva lista temporal
        echo "$linea" >> temporal
      else
        #Si no sigue en activo lo resucitamos
         comando=`echo "$linea" | awk '{$1="";print}'`
         sh -c "$comando" &
         nuevopid="$!"
         echo ""$nuevopid" "$comando"" >> temporal 
         fecha=`date | awk '{print $4}'`
         echo ""$fecha" "El proceso" "$pid" "resucita con PID "$nuevopid" >> ./Biblia.txt
      fi
    else
       #Si existe, borramos el fichero de Infierno
      rm -f ./Infierno/"$pid"
      #Terminamos el proceso junto con sus hijos 
      continua=true
      while [ "$continua" = true ]
      do
        pkill -P "$pid"
        activo=`ps -l | grep "$pid"`
        if ["$activo" = ""];
        then
          continua=false
        fi
      done
      #Y actualizamos entrada en la Biblia
      actualiza_biblia "$pid"
    fi
  done <./procesos_servicio
  #Actualizamos la lista original
  cat ./temporal > ./procesos_servicio
   )200<./SanPedro
  
  #Borramos fichero temporal
  rm -f ./temporal

    #Recorremos la lista de procesos periodicos, bloquando recursos antes de acceder
  (
  flock -s 200
  touch ./temporal
  while read linea;
  do
  pid=`echo "$linea" | awk '{print $3}'`
  instruccion=`echo "$linea" | awk '{$1=$2=$3="";print}'`
  resultado=`ls -l ./Infierno | grep "$pid"`
   #Comprobamos si existe el fichero en Infierno
    if [ "$resultado" = "" ];
    then
      #Si no existe comprobamos periodo
      actual=`echo "$linea" | awk '{print $1}'`
      actual=$((actual))
      periodo=`echo "$linea" | awk '{print $2}'`
      periodo=$((periodo))
      #Comprobamos si el proceso sigue en activo
      activo=`ps -l | grep "$pid"`
      #Si está en activo aumentamos el contador
      if [ "$activo" != "" ];
      then
        actual=$((actual+1))
        echo ""$actual" "$periodo" "$pid" "$instruccion"" >> ./temporal
      else
        #Si no está activo y el contador es menor que el periodo lo aumentamos
        if [ $actual -lt $periodo ];
        then
          actual=$((actual+1))
          echo ""$actual" "$periodo" "$pid" "$instruccion"" >> ./temporal
          #Si no está activo y el contador es mayor o igual que el periodo lo resucitamos
        else
          sh -c "$instruccion" &
          nuevopid="$!"
          echo ""0" "$periodo" "$nuevopid" "$instruccion"" >> ./temporal
          fecha=`date | awk '{print $4}'`
          echo ""$fecha" "El proceso" "$pid" "se ha reencarnado en el PID "$nuevopid" >> ./Biblia.txt
        fi
      fi
    else
      #Si existe, borramos el fichero de Infierno
      rm -f ./Infierno/"$pid"
      #Terminamos el proceso junto con sus hijos 
      continua=true
      while [ "$continua" = true ]
      do
        pkill -P "$pid"
        activo=`ps -l | grep "$pid"`
        if ["$activo" = ""];
        then
          continua=false
        fi
      done
      #Y actualizamos entrada en la Biblia
      actualiza_biblia "$pid"
    fi
  done <./procesos_periodicos
  #Actualizamos la lista original
  cat ./temporal > ./procesos_periodicos
   )200<./SanPedro

  #Borramos fichero temporal
  rm -f ./temporal

#Comprobamos si existe Apocalipsis
if [ -e Apocalipsis ];
then
  condicion=false
fi
done
   
#Fin bucle

#Apocalipsis: termino todos los procesos y limpio todo dejando sólo Fausto, el Demonio y la Biblia


fecha=`date | awk '{print $4}'`
echo ""$fecha" "----------Apocalipsis----------"" >> ./Biblia.txt
while read linea;
do
  pid=`echo "$linea" | awk '{print $1}'`
  if [ "$pid" != "" ];
  then  
    #Terminamos el proceso junto con sus hijos 
    continua=true
    while [ "$continua" = true ]
    do
      pkill -P "$pid"
      activo=`ps -l | grep "$pid"`
      if ["$activo" = ""];
      then
        continua=false
      fi
    done
    actualiza_biblia "$pid"
  fi
done < ./procesos

while read linea;
do
  pid=`echo "$linea" | awk '{print $1}'`
  if [ "$pid" != "" ];
  then  
    #Terminamos el proceso junto con sus hijos 
    continua=true
    while [ "$continua" = true ]
    do
      pkill -P "$pid"
      activo=`ps -l | grep "$pid"`
      if ["$activo" = ""];
      then
        continua=false
      fi
    done
    actualiza_biblia "$pid"
  fi
done < ./procesos_servicio

#Para los procesos periodicos comprobamos que el pid no esté repetido
while read linea;
do
  pid=`echo "$linea" | awk '{print $3}'`
  if [ "$pid" != "" ];
  then  
    pideliminado=""
    pid=`echo "$linea" | awk '{print $3}'`
    if [ "$pid" != "$pideliminado" ];
    then
      #Terminamos el proceso junto con sus hijos 
      continua=true
      while [ "$continua" = true ]
      do
        pkill -P "$pid"
        activo=`ps -l | grep "$pid"`
        if ["$activo" = ""];
        then
          continua=false
        fi
      done
      pideliminado ="$pid"
      actualiza_biblia "$pid"
    fi
  fi
done < ./procesos_periodicos

#Eliminamos ficheros y directorios
rm -f procesos procesos_periodicos procesos_servicio SanPedro Apocalipsis
rm -fr Infierno

fecha=`date | awk '{print $4}'`
echo  ""$fecha" "Se acabó el mundo"" >>./Biblia.txt
 
