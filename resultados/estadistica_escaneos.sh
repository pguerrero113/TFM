#!/bin/bash
modelos_file="./modelos.txt"
esc_mod_dir="./escaneos/modelos/"
salida_file="salida.txt"
error_file="error.txt"
esc_acc_dir="./escaneos/acciones/"
to_file="timeouts.txt"
code="code"
error="error"
ext=".txt"
# Usage ./estadistica_escaneos.sh

echo "--Iniciando $0--"

exec 3< "$modelos_file"
while IFS='/' read -r -u 3 modelo1 modelo2; do

  if [ -n "$modelo1" ] || [ -n "$modelo2" ] && [[ ! "$modelo1" =~ ^[[:space:]]*# ]]; then
    echo "--Procesando Modelo: [$modelo2]--"
    set +e
    
      #Cada una de las líneas es una recomendación accionable      
      comando='cat '$esc_mod_dir'*'$modelo2'_'$code'* | grep -v '\''^$'\'' | wc -l'
      #echo "Ejecutando: [$comando]"
      reco=$(eval "$comando")
      echo "Recomendaciones accionables: [$reco]"

        comando='ls -lS '$esc_acc_dir$modelo2'*/'$salida_file' '$esc_acc_dir'*'$modelo2'*/'$error_file'  | wc -l'
        #echo "Ejecutando: [$comando]"
        eje_unic=$(eval "$comando")
        eje_unic=$((eje_unic / 2))
        if [ "$reco" -eq 0 ]; then echo "  Ejecutadas únicas: [$eje_unic (?%)]"; else echo "  Ejecutadas únicas: [$eje_unic ($((($eje_unic * 100 + $reco/2) / $reco))%)]"; fi

          comando='cat '$esc_acc_dir$to_file' | grep '$modelo2' | wc -l '
          #echo "  Ejecutando: [$comando]"
          to=$(eval "$comando")
          if [ "$eje_unic" -eq 0 ]; then echo "    Timeouts: [$to (?%)]"; else echo "    Timeouts: [$to ($((($to * 100 + $eje_unic/2) / $eje_unic))%)]"; fi

          #Cuenta los errores, sii no son timeouts, los timeouts se cuentan en el párrafo anterior
          comando='ls -lS '$esc_acc_dir$modelo2'*/'$error_file' | awk '\''$5 > 0 {print $9}'\'' | xargs -I{} dirname {} | xargs -I{} basename {} | grep -vxFf '$esc_acc_dir$to_file' | wc -l'
          #echo "  Ejecutando: [$comando]"
          err=$(eval "$comando")
          if [ "$eje_unic" -eq 0 ]; then echo "    Errores: [$err (?%)]"; else echo "    Errores: [$err ($((($err * 100 + $eje_unic/2) / $eje_unic))%)]"; fi

          #Puede que devuelva datos en $salida_file y $error_file, o en $salida_file y $to_file. En estos casos, si devuelve datos en $error_file o en $to_file, NO los consideramos eje_ok para la estadística
          eje_ok=$(($eje_unic - $to - $err))
          if [ "$eje_unic" -eq 0 ]; then echo "    Capacidad: [$eje_ok (?%)]"; else echo "    Capacidad: [$eje_ok ($((($eje_ok * 100 + $eje_unic/2) / $eje_unic))%)]"; fi
          
    set -e
    echo "--Echo Modelo: [$modelo2]--"
  fi

done
exec 3<&- 

echo "--Echo $0--"
