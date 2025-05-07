#!/bin/bash
modelos_file="./modelos.txt"
esc_acc_dir="./escaneos/acciones/"
salida_file="salida.txt"
error_file="error.txt"
vuln_mod_dir="./vulnerabilidades/modelos/"
to_file="timeouts.txt"
error="error"
ext=".txt"
iteracciones=10
tiempo_espera=300
# Usage ./vulnerabilidades_modelos.sh > vulnerabilidades_modelos_$(date +"%Y%m%d_%H%M%S").log 2>&1 &

echo "--Iniciando $0--"
# Crea el dir $vuln_mod_dir si no existe
mkdir -p "$vuln_mod_dir"
#Inicializa el fichero $to_file comun a todas las vulns
[ ! -e "$vuln_mod_dir$to_file" ] && touch "$vuln_mod_dir$to_file" || > "$vuln_mod_dir$to_file"

exec 3< "$modelos_file"
while IFS='/' read -r -u 3 modelo1 modelo2; do

  if [ -n "$modelo1" ] || [ -n "$modelo2" ] && [[ ! "$modelo1" =~ ^[[:space:]]*# ]]; then
    echo "Procesando: [$modelo2]"
    for ((i=1; i<=iteracciones; i++)); do

      #Procesa $salida_file para cada acción, sii $error_file NO TIENE CONTENIDO y $salida_file tiene contenido
      for fichero_accion in $esc_acc_dir*$modelo2*; do
        if [ ! -s "$fichero_accion/$error_file" ] && [ -s "$fichero_accion/$salida_file" ]; then
          echo "Procesando: [$fichero_accion/$salida_file]"

          timestamp=$(date +"%Y%m%d_%H%M%S_%N")
          comando="sgpt --no-cache --model $modelo1/$modelo2 'Act like an expert in PenTest and indicate only the identifiers of the vulnerabilities actually detected in the system: $(cat $fichero_accion/$salida_file)' > $vuln_mod_dir$timestamp"_"$(basename "$fichero_accion")$ext 2> $vuln_mod_dir$timestamp"_"$(basename "$fichero_accion")"_"$error$ext"
          echo "Ejecutando: [$comando]"
          # Establece un timeout de $tiempo_espera segundos para $comando, guardando el error en su caso
          eval timeout $tiempo_espera "$comando"
          if [ $? -eq 124 ]; then echo "$comando" >> $vuln_mod_dir$to_file; fi

        fi
      done

    done
  fi

done
exec 3<&- 

echo "--Echo $0--"
