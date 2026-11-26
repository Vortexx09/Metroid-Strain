function player_controller_init() {
    animator = new PlayerAnimator(id);
    animator.update(0, false, true, false, false);
    weapon_audio_init();
    if (room == rm_overworld) {
        preview_jump_time = 0;
    } else {
        mask_index = spr_test_square;
        player_movement_init();
        player_shooting_init();
        player_audio_init();
    }
}

function player_controller_step() {
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
        return;
    }

    player_shooting_step();
    var movement = player_movement_step();
    if (is_undefined(movement)) {
        missile_charge_steps = 0;
        weapon_audio_charge_update(false);
        if (hanging) {
            shoot_pose_steps = 0;
            animator.hang(!facing_right);
        } else {
            animator.update(facing_right ? 1 : -1, false, true, false, false);
        }
        player_audio_step(movement);
        return;
    }

    var aim = player_shooting_aim();
    player_shooting_fire(movement.terrain, aim);
    weapon_audio_charge_update(missile_charge_steps >= 8);
    if (movement.grounded) {
        spin_jump = false;
        wall_jump_steps = 0;
    }

    var aim_style = PlayerIdleAim.Forward;
    if (aim.y < 0) {
        aim_style = aim.x == 0 ? PlayerIdleAim.Up : PlayerIdleAim.DiagonalUp;
    } else if (aim.y > 0) {
        aim_style = aim.x == 0 ? PlayerIdleAim.Down : PlayerIdleAim.DiagonalDown;
    }

    var look_direction = facing_right ? 1 : -1;
    if (!spin_jump && aim.x != 0) {
        look_direction = aim.x;
    }
    var shooting = (!missile_selected && keyboard_check(ord("Z"))) || shoot_pose_steps > 0;
    animator.update(look_direction, movement.moving, movement.grounded, shooting, false, aim_style, spin_jump);
    player_audio_step(movement);
}
