#!/bin/bash
objetivo="192.168.30.19"
modelos_file="./modelos.txt"
esc_mod_dir="./escaneos/modelos/"
to_file="timeouts.txt"
iteracciones=10
tiempo_espera=300
# Usage ./escaneos_modelos.sh > escaneos_modelos_$(date +"%Y%m%d_%H%M%S").log 2>&1 &

echo "--Iniciando $0--"
# Crea el dir $esc_mod_dir si no existe
mkdir -p "$esc_mod_dir"
# Inicializa el fichero  $to_file
[ ! -e "$esc_mod_dir$to_file" ] && touch "$esc_mod_dir$to_file" || > "$esc_mod_dir$to_file"

exec 3< "$modelos_file"
while IFS='/' read -r -u 3 modelo1 modelo2; do

  if [ -n "$modelo1" ] || [ -n "$modelo2" ] && [[ ! "$modelo1" =~ ^[[:space:]]*# ]]; then
    for ((i=1; i<=iteracciones; i++)); do

      timestamp=$(date +"%Y%m%d_%H%M%S_%N")
      comando="sgpt --no-cache --model $modelo1/$modelo2 'Compórtate como un experto en PenTest e indica como escanear el objetivo: $objetivo' > $esc_mod_dir$timestamp"_"$modelo2".txt" 2> $esc_mod_dir$timestamp"_"$modelo2"_error.txt
      echo "Ejecutando: [$comando]"
      #Establece un timeout de $tiempo_espera segundos para $comando, guardando el error en su caso
      eval timeout $tiempo_espera "$comando"
      if [ $? -eq 124 ]; then echo "Timeout error: [$comando]" >> $to_file; fi

      timestamp=$(date +"%Y%m%d_%H%M%S_%N")
      comando="sgpt --no-cache --code --model $modelo1/$modelo2 'Compórtate como un experto en PenTest e indica como escanear el objetivo: $objetivo' > $esc_mod_dir$timestamp"_"$modelo2"_code.txt" 2> $esc_mod_dir$timestamp"_"$modelo2"_code_error.txt
      echo "Ejecutando: [$comando]"
      #Establece un timeout de $tiempo_espera segundos para $comando, guardando el error en su caso
      eval timeout $tiempo_espera "$comando"
      if [ $? -eq 124 ]; then echo "$comando" >> $esc_mod_dir$to_file; fi

    done
  fi

done
exec 3<&- 

echo "--Echo $0--"
