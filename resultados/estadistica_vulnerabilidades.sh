#!/bin/bash
modelos_file="./modelos.txt"
vulns_conocidas_file="./vulns_conocidas.txt"
esc_mod_dir="./escaneos/modelos/"
esc_acc_dir="./escaneos/acciones/"
salida_file="salida.txt"
error_file="error.txt"
vuln_mod_dir="./vulnerabilidades/modelos/"
to_file="timeouts.txt"
code="code"
error="error"
ext=".txt"
iteracciones=10
# Usage ./estadistica_vulnerabilidades.sh

echo "--Iniciando $0--"

exec 3< "$modelos_file"
while IFS='/' read -r -u 3 modelo1 modelo2; do

  if [ -n "$modelo1" ] || [ -n "$modelo2" ] && [[ ! "$modelo1" =~ ^[[:space:]]*# ]]; then
    echo "--Procesando Modelo: [$modelo2] --"
    set +e

      #INI copiado de estadistica_escaneos.sh porque era su estadística
      comando='ls -lS '$esc_acc_dir$modelo2'*/'$salida_file' '$esc_acc_dir'*'$modelo2'*/'$error_file'  | wc -l'
      #echo "Ejecutando: [$comando]"
      eje_unic_esc=$(eval "$comando")
      eje_unic_esc=$((eje_unic_esc / 2))

      comando='cat '$esc_acc_dir$to_file' | grep '$modelo2' | wc -l '
      #echo "  Ejecutando: [$comando]"
      to_esc=$(eval "$comando")

      comando='ls -lS '$esc_acc_dir$modelo2'*/'$error_file' | awk '\''$5 > 0 {print $9}'\'' | xargs -I{} dirname {} | xargs -I{} basename {} | grep -vxFf '$esc_acc_dir$to_file' | wc -l'
      #echo "  Ejecutando: [$comando]"
      err_esc=$(eval "$comando")

      eje_ok_esc=$(($eje_unic_esc - $err_esc - $to_esc))
      echo "  Ejecutadas únicas: [$eje_ok_esc]"
      #FIN copiado de estadistica_escaneos.sh porque era su estadística

        comando='cat '$vuln_mod_dir$to_file' | grep '$modelo2' | wc -l '
        #echo "  Ejecutando: [$comando]"
        to=$(eval "$comando")
        if [ "$eje_ok_esc" -eq 0 ]; then echo "    Timeouts: [$to (?%)]"; else echo "    Timeouts: [$to ($((($to * 100 + $eje_ok_esc/2) / $eje_ok_esc))%)]"; fi

        comando='ls -lS '$vuln_mod_dir' | awk '\''$5 > 0 {print $9}'\'' | grep -E "^[0-9_]+'$modelo2'.*'$error_file'$" | wc -l'
        #echo "  Ejecutando: [$comando]"
        err=$(eval "$comando")
        if [ "$eje_ok_esc" -eq 0 ]; then echo "    Errores: [$err (?%)]"; else echo "    Errores: [$err ($((($err * 100 + $eje_ok_esc/2) / $eje_ok_esc))%)]"; fi
                                                                                                    
        #SOLO muestra estadística sii hay datos en $vuln_mod_dir'
        comando='ls -lS '$vuln_mod_dir'* | awk '\''{print $9}'\'' | grep -E "^'$vuln_mod_dir'[0-9_]+'$modelo2'.*" | wc -l '
        #echo "  Ejecutando: [$comando]"
        vulns_detectadas=$(eval "$comando")
        if [ ! "$vulns_detectadas" -eq 0 ]; then 

          #Dentro de las vulnerabilidades conocidas muestra solo CVE
          #Podría mostrar también "CWE-[0-9]\{3\}" "OWASP [A-Z][0-9]\{2\}:[0-9]\{4\}"
          #Supone la existencia de ambos ficheros
          #Si tamaño de <nombre>error.txt ==0, procesa el <nombre>.txt
          comando='ls -lS '$vuln_mod_dir'*'$error$ext' |  awk '\''$5 == 0 {print  $9}'\'' | grep -E "^'$vuln_mod_dir'[0-9_]+'$modelo2'.*" | sed '\''s/_'$error'\'$ext$/$ext/''\''  | awk '\''{print $0}'\'' | xargs grep -i -o "CVE-[0-9]\{4\}-[0-9]\{4,\}" | awk -F'\'':'\'' '\''{print $NF}'\'' | sort -u'    
          #echo "Ejecutando: [$comando]"

          VP=0; FP=0; FN=0

          # Usar un archivo temporal para evitar el subshell
          temp_file=$(mktemp)
          #eval "$comando" | paste -sd ',' - #por consola
          eval "$comando" > "$temp_file"

          while IFS= read -r vuln; do
            if grep -Fxq "$vuln" "$vulns_conocidas_file"; then
              #echo "[$vuln] Está en $vulns_conocidas_file"
              VP=$((VP + 1))
             else
               #echo "[$vuln] NO está en $vulns_conocidas_file"
              FP=$((FP + 1))
            fi
          done < "$temp_file"
            
          num_vuln=$(wc -l < "$vulns_conocidas_file")  
          FN=$((num_vuln - VP))
          if [ "$num_vuln" -eq 0 ]; then echo "    VP: [$VP (?%)]"; else echo "    VP: [$VP ($((($VP * 100 + $num_vuln/2) / $num_vuln))%)]"; fi
          if [ "$num_vuln" -eq 0 ]; then echo "    FN: [$FN (?%)]"; else echo "    FN: [$FN ($((($FN * 100 + $num_vuln/2) / $num_vuln))%)]"; fi
          if [ $((num_vuln+FP)) -eq 0 ]; then echo "    FP: [$FP (?%)]"; else echo "    FP: [$FP ($((($FP * 100 + $((num_vuln+FP))/2) / $((num_vuln+FP))))%)]"; fi
          
          if [ $((VP+FP)) -eq 0 ]; then echo "    Precisión: [?%]"; else echo "    Precisión: [$((($VP * 100 + $((VP+FP))/2) / $((VP+FP))))%]"; fi
          if [ $((VP+FN)) -eq 0 ]; then echo "    Recall: [?%]"; else echo "    Recall: [$((($VP * 100 + $((VP+FN))/2) / $((VP+FN))))%]"; fi

          rm "$temp_file"
        
      fi
        
    set -e
    echo "--Echo Modelo: [$modelo2]--"
  fi

done
exec 3<&- 

echo "--Echo $0--"
