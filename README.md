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
3. Pulsa **F5** para abrir `rm_basic_movement_test`. Si falla la compilación, revisa el primer error en **Output**. [Manual del menú Build](https://manual.gamemaker.io/lts/en/IDE_Navigation/Menus/The_Build_Menu.htm)

## Controles de la sala de pruebas

| Acción | Controles |
| --- | --- |
| Moverse | **← / →** o **A / D** |
| Saltar | **Espacio**, **↑** o **W**. Saltar con dirección inicia una voltereta que conserva el impulso al soltar la tecla. |
| Agarrarse a un borde | Mantén la dirección hacia la plataforma al caer junto al borde. |
| Subir desde un borde | **↑** o **W** |
| Saltar desde un borde | **Espacio** + dirección contraria al borde |
| Saltar desde una pared | Pulsa **Espacio** mientras tocas una pared en el aire. |
| Apuntar | **I / J / K / L** para arriba, izquierda, abajo y derecha. Combina una dirección vertical con una horizontal para apuntar en diagonal. |
| Disparar | **Z**. Sin teclas de apuntado, dispara hacia donde mira el personaje. |
| Cambiar de arma | **Q**, después de recoger el power-up naranja en la primera plataforma. |

`rm_overworld` es la sala de previsualización de animaciones. Para iniciarla, ponla temporalmente primero en el orden de salas.

## Entregas del curso

- **Primer avance (30–50 %)**. Mostrar el concepto y un tramo jugable del mismo plataformas que se presentará al final.
- **Entrega final**. Completar un nivel con inicio, objetivo y final reconocibles. Incorporar ambiente y efectos sonoros. Preparar la demostración ante el curso y la sustentación oral.
- **Equipo y repositorio**. Hasta tres integrantes. El repositorio es público y cada integrante debe aportar commits con su propia cuenta. Incluye código y recursos propios o con autorización para redistribuirlos.
- **Contenido**. Mantener el nivel apto para exposición. Consultar al profesor si la historia incluye drogas, sexo, política o religión.
