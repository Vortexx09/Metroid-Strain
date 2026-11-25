// Controles de previsualización exclusivos de la sala de pruebas.
if (room == rm_overworld) {
    var _move_input = keyboard_check(vk_right) - keyboard_check(vk_left);
    // Q/D permiten probar el giro en reposo.
    var _turn_input = keyboard_check(ord("D")) - keyboard_check(ord("Q"));
    var _direction = _move_input != 0 ? _move_input : _turn_input;
    var _jump_pressed = keyboard_check_pressed(vk_space);
    var _shooting = keyboard_check(ord("Z"));

    var _idle_aim = PlayerIdleAim.Forward;
    if (keyboard_check(vk_up)) {
        _idle_aim = PlayerIdleAim.Up;
    } else if (keyboard_check(vk_down)) {
        _idle_aim = PlayerIdleAim.Down;
    } else if (keyboard_check(ord("A"))) {
        _idle_aim = PlayerIdleAim.DiagonalUp;
    } else if (keyboard_check(ord("S"))) {
        _idle_aim = PlayerIdleAim.DiagonalDown;
    }

    // Simula el tiempo en el aire para poder volver a pulsar salto.
    if (preview_jump_time > 0) {
        preview_jump_time = max(0, preview_jump_time - delta_time / 1000000);
    } else if (_jump_pressed) {
        preview_jump_time = 1.2;
    }

    animator.update(_direction, _move_input != 0, preview_jump_time == 0, _shooting, _jump_pressed, _idle_aim);
}
