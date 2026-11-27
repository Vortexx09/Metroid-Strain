# Metroid - Strain

Proyecto universitario de plataformas 2D y exploración, en desarrollo con GameMaker y GML Code. El primer hito es una sala de pruebas con movimiento horizontal, salto y colisiones. Para el nivel de la entrega, la propuesta es comenzar tras un aterrizaje forzoso, recorrer una zona de la nave y llegar a una salida identificable.

## Instalar GameMaker en Ubuntu

1. Usa Ubuntu 24.04 LTS para las versiones recientes del IDE de Linux. Comprueba la compatibilidad de tu versión del IDE y su runtime en los [requisitos oficiales de GameMaker](https://gamemaker.io/en/help/articles/gamemaker-s-required-sdks).
2. Descarga el paquete `.deb` para Linux (Ubuntu) desde la [página oficial de descargas](https://gamemaker.io/en/download). Abre una terminal en la carpeta de descarga y sustituye el nombre del paquete por el del archivo descargado.

   ```bash
   sudo apt update
   sudo apt install git ./NOMBRE-DEL-PAQUETE.deb
   ```

3. Abre GameMaker desde el menú de aplicaciones, inicia sesión si el IDE lo solicita y espera a que termine de instalar el runtime. Consulta la [guía oficial para Ubuntu](https://gamemaker.io/en/help/articles/setting-up-for-ubuntu) para instalar las dependencias de compilación que pida tu versión.

## Abrir y ejecutar en el IDE

1. En GameMaker, selecciona **File → Open Project** y abre [Metroid-Strain.yyp](Metroid-Strain.yyp).
2. En el selector de destinos, elige **Windows → VM** o **Ubuntu → VM**, según tu sistema.
3. Pulsa **F5** para abrir `rm_overworld`. Para probar el daño, los misiles y los blancos, coloca `rm_basic_movement_test` primero en el orden de salas. Si falla la compilación, revisa el primer error en **Output**. [Manual del menú Build](https://manual.gamemaker.io/lts/en/IDE_Navigation/Menus/The_Build_Menu.htm)

## Controles de la sala de pruebas

| Acción | Controles |
| --- | --- |
| Moverse | **← / →**. Al invertir la dirección en suelo, el jugador gira en el sitio y arranca si mantienes la nueva flecha durante 100 ms. Al aterrizar, la velocidad vuelve a cero. Si mantienes la flecha, acelera de nuevo en el paso siguiente. |
| Saltar | **Espacio** o **W**. Suelta la tecla durante el ascenso para hacer un salto más bajo. Saltar con dirección inicia una voltereta que conserva la velocidad horizontal al soltar la flecha. |
| Agarrarse a un borde | Mantén la dirección hacia la plataforma al caer junto al borde. |
| Subir desde un borde | **↑** o **W** |
| Saltar desde un borde | **Espacio** + dirección contraria al borde |
| Saltar desde una pared | Pulsa **Espacio** mientras tocas una pared en el aire. |
| Apuntar | **A / S** para las diagonales, **↑ / ↓** para arriba y abajo. Al correr, **↑ / ↓** también apuntan en diagonal. **J / L** orientan al jugador a izquierda y derecha, e **I / K** también permiten apuntar arriba y abajo. |
| Disparar | Pulsa **Z** para disparar. Mientras corres, se mantiene la pose de disparo hasta que dejes de correr o cambies de dirección. Pulsar **Z** durante la voltereta pasa a un salto normal. Con el rayo seleccionado, mantén **Z** hasta que el HUD indique **Rayo cargado** y suéltala para lanzarlo. |
| Disparar un misil | Con los misiles seleccionados, pulsa y suelta **Z**. Mantén **Z** hasta alcanzar el 100 % de carga antes de soltarla para duplicar el daño. Cada disparo consume un misil. |
| Cambiar de arma | **Q**, después de recoger un power-up naranja. Cada power-up añade **5 misiles**. |

El rayo normal hace **10** de daño, el rayo cargado **30**, el misil normal **24** y el misil cargado **48**. Al sobrecalentarse, ambas armas hacen la mitad de daño y aumentan el tiempo entre disparos. Suelta **Z** hasta que el calor baje al **35 %** para recuperar el rendimiento normal.

## Entregas del curso

- **Primer avance (30–50 %)**. Mostrar el concepto y un tramo jugable del mismo plataformas que se presentará al final.
- **Entrega final**. Completar un nivel con inicio, objetivo y final reconocibles. Incorporar ambiente y efectos sonoros. Preparar la demostración ante el curso y la sustentación oral.
- **Equipo y repositorio**. Hasta tres integrantes. El repositorio es público y cada integrante debe aportar commits con su propia cuenta. Incluye código y recursos propios o con autorización para redistribuirlos.
- **Contenido**. Mantener el nivel apto para exposición. Consultar al profesor si la historia incluye drogas, sexo, política o religión.
