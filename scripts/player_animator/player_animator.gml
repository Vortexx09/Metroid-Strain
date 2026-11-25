enum PlayerAnimationState {
    Idle,
    Run,
    IdleJump,
    RunJump,
    IdleShoot,
    RunShoot
}

enum PlayerIdleAim {
    Forward,
    Up,
    DiagonalUp,
    DiagonalDown,
    Down
}

function PlayerAnimator(_player) constructor {
    player = _player;
    facing_left = false;
    state = PlayerAnimationState.Idle;
    run_shoot_direction = 0;
    was_shooting = false;
    turn_time = 0;
    idle_jump_frame = 1;

    // Las filas siguen el orden de PlayerAnimationState. Cada par es izquierda/derecha.
    static sprites = [
        [spr_samus_idle_l, spr_samus_idle_r],
        [spr_samus_run_l, spr_samus_run_r],
        [spr_samus_idlejump_l, spr_samus_idlejump_r],
        [spr_samus_runjump_l, spr_samus_runjump_r],
        [spr_samus_idleshoot_l, spr_samus_idleshoot_r],
        [spr_samus_runshoot_l, spr_samus_runshoot_r]
    ];

    static idle_aim_sprites = [
        [spr_samus_idle_l, spr_samus_idle_r],
        [spr_samus_idle_u_l, spr_samus_idle_u_r],
        [spr_samus_idle_du_l, spr_samus_idle_du_r],
        [spr_samus_idle_dd_l, spr_samus_idle_dd_r],
        [spr_samus_idle_d_l, spr_samus_idle_d_r]
    ];

    static idle_jump_aim_sprites = [
        [spr_samus_idlejump_l, spr_samus_idlejump_r],
        [spr_samus_idlejump_u_l, spr_samus_idlejump_u_r],
        [spr_samus_idlejump_du_l, spr_samus_idlejump_du_r],
        [spr_samus_idlejump_dd_l, spr_samus_idlejump_dd_r],
        [spr_samus_idlejump_d_l, spr_samus_idlejump_d_r]
    ];

    static idle_shoot_aim_sprites = [
        [spr_samus_idleshoot_l, spr_samus_idleshoot_r],
        [spr_samus_idleshoot_u_l, spr_samus_idleshoot_u_r],
        [spr_samus_idleshoot_du_l, spr_samus_idleshoot_du_r],
        [spr_samus_idleshoot_dd_l, spr_samus_idleshoot_dd_r],
        [spr_samus_idleshoot_d_l, spr_samus_idleshoot_d_r]
    ];

    static run_shoot_up_sprites = [spr_samus_runshoot_du_l, spr_samus_runshoot_du_r];
    static run_shoot_down_sprites = [spr_samus_runshoot_dd_l, spr_samus_runshoot_dd_r];

    static play = function(_sprite, _frame, _manual = false) {
        player.sprite_index = _sprite;
        player.image_speed = _manual ? 0 : 1;
        player.image_index = _frame;
    };

    static hang = function(_facing_left) {
        facing_left = _facing_left;
        state = PlayerAnimationState.IdleJump;
        idle_jump_frame = 1;
        turn_time = 0;
        play(sprites[state][facing_left ? 0 : 1], idle_jump_frame, true);
    };

    static update = function(_direction, _moving, _grounded, _shooting, _jump_pressed,
        _idle_aim = PlayerIdleAim.Forward, _spin_jump = undefined) {
        var _previous_facing_left = facing_left;
        var _previous_state = state;
        var _shoot_pressed = _shooting && !was_shooting;
        was_shooting = _shooting;
        var _aim_up = _idle_aim == PlayerIdleAim.Up || _idle_aim == PlayerIdleAim.DiagonalUp;
        var _aim_down = _idle_aim == PlayerIdleAim.Down || _idle_aim == PlayerIdleAim.DiagonalDown;

        if (_direction != 0) {
            facing_left = _direction < 0;
        }

        if (!_moving || _direction != run_shoot_direction) {
            run_shoot_direction = 0;
        }
        if (_grounded && _moving && _shoot_pressed) {
            run_shoot_direction = _direction;
        }

        var _was_jumping = _previous_state == PlayerAnimationState.IdleJump
            || _previous_state == PlayerAnimationState.RunJump;
        if (!_grounded) {
            if (!is_undefined(_spin_jump)) {
                state = _spin_jump ? PlayerAnimationState.RunJump : PlayerAnimationState.IdleJump;
            } else if (!_was_jumping) {
                state = _moving ? PlayerAnimationState.RunJump : PlayerAnimationState.IdleJump;
            } else if (_previous_state == PlayerAnimationState.RunJump && (_shoot_pressed || _jump_pressed)) {
                state = PlayerAnimationState.IdleJump;
            }
        } else if (_moving) {
            var _run_shooting = is_undefined(_spin_jump) ? run_shoot_direction != 0 : _shooting;
            state = (_run_shooting || _aim_up || _aim_down)
                ? PlayerAnimationState.RunShoot : PlayerAnimationState.Run;
        } else {
            state = _shooting ? PlayerAnimationState.IdleShoot : PlayerAnimationState.Idle;
        }

        var _facing_index = facing_left ? 0 : 1;
        var _is_idle = state == PlayerAnimationState.Idle;
        var _is_idle_jump = state == PlayerAnimationState.IdleJump;
        var _sprite = sprites[state][_facing_index];
        if (_is_idle) {
            _sprite = idle_aim_sprites[_idle_aim][_facing_index];
        } else if (_is_idle_jump) {
            _sprite = idle_jump_aim_sprites[_idle_aim][_facing_index];
        } else if (state == PlayerAnimationState.IdleShoot) {
            _sprite = idle_shoot_aim_sprites[_idle_aim][_facing_index];
        } else if (state == PlayerAnimationState.RunShoot) {
            if (_aim_up) {
                _sprite = run_shoot_up_sprites[_facing_index];
            } else if (_aim_down) {
                _sprite = run_shoot_down_sprites[_facing_index];
            }
        }
        var _was_running = _previous_state == PlayerAnimationState.Run
            || _previous_state == PlayerAnimationState.RunShoot;
        var _is_running = state == PlayerAnimationState.Run || state == PlayerAnimationState.RunShoot;
        var _ground_turn = (_is_idle || _is_running)
            && (_previous_state == PlayerAnimationState.Idle || _was_running);
        var _air_turn = _is_idle_jump && _previous_state == PlayerAnimationState.IdleJump;

        // Los giros activos terminan aunque cambie el input. El sprite final sigue la última dirección.
        if (turn_time > 0 && (_ground_turn || _air_turn)) {
            turn_time = max(0, turn_time - delta_time / 1000000);
            if (turn_time == 0) {
                if (_air_turn) {
                    idle_jump_frame = 2;
                    play(_sprite, min(idle_jump_frame, sprite_get_number(_sprite) - 1), true);
                } else {
                    play(_sprite, _is_idle ? 1 : 0, _is_idle);
                }
            }
            return;
        }
        turn_time = 0;

        if (_previous_facing_left != facing_left && (_ground_turn || _air_turn)) {
            turn_time = 0.05;
            if (_air_turn) {
                play(_sprite, 0, true);
            } else {
                var _turn_aim = _idle_aim;
                if (_is_running) {
                    if (_aim_up) {
                        _turn_aim = PlayerIdleAim.DiagonalUp;
                    } else if (_aim_down) {
                        _turn_aim = PlayerIdleAim.DiagonalDown;
                    }
                }
                play(idle_aim_sprites[_turn_aim][_facing_index], 0, true);
            }
            return;
        }

        if (_is_idle) {
            // El fotograma 0 es la pose de giro. El bucle normal empieza en el 1.
            if (player.sprite_index != _sprite || player.image_index < 1) {
                play(_sprite, 1, true);
            } else {
                var _advance = sprite_get_speed(_sprite) * delta_time / 1000000;
                var _loop_length = sprite_get_number(_sprite) - 1;
                var _loop_progress = (player.image_index - 1 + _advance) / _loop_length;
                player.image_index = 1 + frac(_loop_progress) * _loop_length;
            }
        } else if (_is_idle_jump) {
            // La fase del salto se conserva al cambiar de apuntado, incluso en sprites cortos.
            if (_previous_state != PlayerAnimationState.IdleJump) {
                idle_jump_frame = 1;
            } else {
                idle_jump_frame += sprite_get_speed(_sprite) * delta_time / 1000000;
            }
            var _frame = min(idle_jump_frame, sprite_get_number(_sprite) - 1);
            if (player.sprite_index != _sprite) {
                play(_sprite, _frame, true);
            } else {
                player.image_index = _frame;
            }
        } else if (player.sprite_index != _sprite) {
            // Carrera y carrera con disparo comparten el mismo ciclo de diez fotogramas.
            var _continue_run = _was_running && _is_running && _previous_facing_left == facing_left;
            var _turn_during_jump = _was_jumping && state == _previous_state;
            var _frame = (_continue_run || _turn_during_jump) ? player.image_index : 0;
            play(_sprite, _frame);
        }
    };
}
