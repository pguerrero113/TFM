#!/bin/bash
modelos_file="./modelos.txt"
esc_mod_dir="./escaneos/modelos/"
esc_acc_dir="./escaneos/acciones/"
code="code"
ext=".txt"
salida_file="salida.txt"
error_file="error.txt"
to_file="timeouts.txt"
tiempo_espera=300
# Usage ./escaneos_acciones.sh > escaneos_acciones_$(date +"%Y%m%d_%H%M%S").log 2>&1 &

echo "--Iniciando $0--"
# Crea el dir $esc_acc_dir si no existe
mkdir -p "$esc_acc_dir"
#Inicializa el fichero $to_file comun a todas las acciones
[ ! -e "$esc_acc_dir$to_file" ] && touch "$esc_acc_dir$to_file" || > "$esc_acc_dir$to_file"

exec 3< "$modelos_file"
while IFS='/' read -r -u 3 modelo1 modelo2; do

  if [ -n "$modelo1" ] || [ -n "$modelo2" ] && [[ ! "$modelo1" =~ ^[[:space:]]*# ]]; then

    #Procesa todos los ficheros de solo código
    for fichero_code in $esc_mod_dir*$modelo2*_$code$ext; do
      echo "Procesando fichero: [$fichero_code]"

      exec 4< "$fichero_code"
      #cada linea de $fichero_code es una accion
      while IFS= read -r -u 4 accion; do

        #Elimina espacios al inicio y final de $accion, porque es la misma acción
        accion=$(echo "$accion" | xargs)
        if [ -n "$accion" ]; then
          echo "Procesando accion: [$accion]"

          #Elimina el timestamp (26 primeros chars) de $fichero_code, porque la ejecución de ficheros no devuelve un resultado distinto con cada ejecución como sucede con la llamada a un modelo
          #Elimina path y extensión de $fichero_code, concatenandole un hash del contenido de $accion
          loc=$esc_acc_dir"$(basename "$fichero_code" "$ext" | cut -c27-)_$(echo -n $accion | sha256sum | awk '{print $1}')"
          #Si el dir NO existe significa que la $accion NO ha sido ejecutada -> la ejecuta
          #Si el directorio existe significa que $accion ya fué ejecutada y NO es tenida en cuenta
          if [ ! -d $loc ]; then
            #Crea un dir por $accion y entra en él porque porque las acciones pueden generar ficheros como efectos laterales
            dir_pwd=$(pwd);  mkdir $loc; cd $loc
              #Crea un fichero con el contenido de $accion, para que sea más fácil saber qué ejecuta
              echo "$accion" > "$code$ext"
              comando="$accion > $salida_file 2> $error_file"
              echo "Ejecutando: [$loc][$comando]"
              #Establece un timeout de $tiempo_espera segundos para $comando, guardando el error en su caso
              timeout "$tiempo_espera" bash -c "$comando"
              salida_timeout=$?
            cd $dir_pwd  #Sale al dir base
            if [ $salida_timeout -eq 124 ]; then echo "$(basename "$loc")" >> $esc_acc_dir$to_file; fi
          fi

        fi

      done
      exec 4<&- 

    done
  fi

done
exec 3<&- 

echo "--Echo $0--"
