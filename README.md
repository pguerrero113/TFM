# Análisis de GenAI a través de modelos de LLM en automatización de PenTesting

Este repositorio contiene los scripts necesarios para las llamadas a los modelos, la ejecución de las acciones y la generación de la estadística necesaria para el estudio de la aplicación de  la inteligencia artificial generativa (GenAI), a través de una serie de modelos de LLM como son: anthropic/Claude 3.5 Haiku , deepseek/DeepSeek-R1 , google/Gemini 2.0 Flash 001, openai/GPT-4o y meta-llama/Llama 3.3-70B Instruct, para la automatización de PenTest, en particular las fases de: Automatización de Escaneos, Identificación de Vulnerabilidades y Explotación de Vulnerabilidades.

Las llamadas y ejecuciones se han ejecutado en idioma español e ingles, de ahí las dos carpetas incluidas:

El procedimiento y el orden para llevar a cabo es estudio se realiza a través de la ejecución de los scripts, en  cada una de las carpetas. 

Una vez descargado todo el código del proyecto, nos situamos en la carpeta resultados y ejecutamos los 8 pasos siguientes, repitiendo lo mismo para la carpeta resultados-ingles.

A continuación, un ejemplo de su uso:

1. Primero ejecutamos las llamadas a los modelos para realizar la Automatización de Escaneos.

    ./escaneos_modelos.sh > escaneos_modelos_$(date +"%Y%m%d_%H%M%S").log 2>&1 &
    Obteniendo un fichero de log donde se le indique.

2. Una vez terminado el script de paso 1, ejecutamos el siguiente:

    ./escaneos_acciones.sh > escaneos_acciones_$(date +"%Y%m%d_%H%M%S").log 2>&1 &
    Obteniendo un fichero de log donde se le indique.

3. Una vez terminado el script de paso 2, ejecutamos el siguiente:

    ./estadistica_escaneos.sh
    Obteniendo la estadística para la fase de Automatización de Escaneos.

4. Una vez terminado el script de paso 2, ejecutamos las llamadas a los modelos para realizar la Identificación de Vulnerabilidades 

    ./vulnerabilidades_modelos.sh > vulnerabilidades_modelos_$(date +"%Y%m%d_%H%M%S").log 2>&1 &
    Obteniendo un fichero de log donde se le indique.

5. Una vez terminado el script de paso 4, ejecutamos el siguiente:

    ./estadistica_vulnerabilidades.sh
    Obteniendo la estadística para la fase de Identificación de Vulnerabilidades.

6. Ejecutamos las llamadas a los modelos para realizar la Explotación de Vulnerabilidades.

    ./exploits_modelos.sh > exploits_modelos_$(date +"%Y%m%d_%H%M%S").log 2>&1 &
    Obteniendo un fichero de log donde se le indique.

7. Una vez terminado el script de paso 6, ejecutamos el siguiente:

    ./exploits_acciones.sh > exploits_acciones_$(date +"%Y%m%d_%H%M%S").log 2>&1 &
    Obteniendo un fichero de log donde se le indique.

8. Una vez terminado el script de paso 7, ejecutamos el siguiente:

    ./estadistica_exploits.sh
    Obteniendo la estadística para la fase de Explotación de Vulnerabilidades.
