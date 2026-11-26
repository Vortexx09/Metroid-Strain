function player_movement_init() {
    move_speed = 2.5;
    ground_startup_time = 0.06;
    ground_startup_speed = 0.28;
    ground_startup_friction = 0.1;
    ground_acceleration_per_step = 0.75;
    air_acceleration_per_step = 0.25;
    ground_friction = 0.5;
    run_jump_move_speed = 2;
    idle_jump_move_speed = 1.5;
    move_turn_delay = 0.1;
    move_start_delay = 0;
    held_move_direction = 0;
    move_hold_time = 0;
    horizontal_speed = 0;
    horizontal_remainder = 0;
    ground_run_started = false;
    ground_contact = false;
    foot_overhang = 2;
    jump_height = 72;
    jump_speed = 6.13;
    gravity_per_step = 0.25;
    apex_hold_duration = 3;
    apex_hold_steps = 0;
    terminal_speed = 10.5;
    wall_jump_speed = 6;
    wall_jump_duration = 7;
    wall_jump_steps = 0;
    wall_jump_direction = 0;
    vertical_speed = 0;
    vertical_remainder = 0;
    jump_start_y = y;
    fall_start_y = y;
    facing_right = true;
    spin_jump = false;
    hanging = false;
    climb_x = x;
    climb_y = y;
}

function player_movement_has_support(_terrain) {
    if (place_meeting(x, y + 1, _terrain)) {
        return true;
    }

    // Los pies visibles sobresalen dos píxeles a cada lado de la máscara del torso.
    var _floor_y = bbox_bottom + 1;
    var _left_support = false;
    var _right_support = false;
    for (var _offset = 1; _offset <= foot_overhang; _offset++) {
        var _left_x = bbox_left - _offset;
        var _right_x = bbox_right + _offset;
        _left_support = _left_support || (position_meeting(_left_x, _floor_y, _terrain)
            && !position_meeting(_left_x, _floor_y - 1, _terrain));
        _right_support = _right_support || (position_meeting(_right_x, _floor_y, _terrain)
            && !position_meeting(_right_x, _floor_y - 1, _terrain));
    }
    // Si solo se tocan los dos labios del hueco, el torso ya tiene espacio para caer.
    return _left_support != _right_support;
}

function player_movement_step(_fire_pressed) {
    var move_left = keyboard_check(vk_left);
    var move_right = keyboard_check(vk_right);
    var up_pressed = keyboard_check_pressed(ord("W"));
    var space_pressed = keyboard_check_pressed(vk_space);
    var jump_pressed = space_pressed || up_pressed;
    var jump_held = keyboard_check(vk_space) || keyboard_check(ord("W"));
    var input_direction = move_right - move_left;
    var horizontal_step = input_direction;

    if (hanging) {
        if (up_pressed || keyboard_check_pressed(vk_up)) {
            x = climb_x;
            y = climb_y;
            hanging = false;
            return undefined;
        }

        var away_from_ledge = facing_right ? -1 : 1;
        if (!space_pressed || horizontal_step != away_from_ledge) {
            return undefined;
        }

        hanging = false;
        vertical_speed = -jump_speed;
        jump_start_y = y;
        fall_start_y = y;
        horizontal_speed = away_from_ledge * run_jump_move_speed;
        vertical_remainder = 0;
        apex_hold_steps = 0;
        spin_jump = true;
        jump_pressed = false;
    }

    var terrain = [obj_test_solid, obj_test_ramp];
    var following_ground = vertical_speed >= 0
        && (place_meeting(x, y + 1, terrain) || (ground_contact && player_movement_has_support(terrain)));
    var started_grounded = following_ground;
    if (following_ground) {
        jump_start_y = y;
        fall_start_y = y;
    }
    if (_fire_pressed && !following_ground && spin_jump) {
        spin_jump = false;
        wall_jump_steps = 0;
        horizontal_remainder = 0;
    }

    if (jump_pressed && !following_ground) {
        var wall_side = facing_right ? 1 : -1;
        if (!place_meeting(x + wall_side, y, obj_test_solid)) {
            wall_side = -wall_side;
        }

        if (place_meeting(x + wall_side, y, obj_test_solid)) {
            wall_jump_direction = -wall_side;
            wall_jump_steps = wall_jump_duration;
            vertical_speed = -jump_speed;
            jump_start_y = y;
            fall_start_y = y;
            vertical_remainder = 0;
            apex_hold_steps = 0;
            spin_jump = true;
            jump_pressed = false;
        }
    }

    var air_move_speed = spin_jump ? run_jump_move_speed : idle_jump_move_speed;
    var ground_motion = false;
    var look_direction = input_direction;
    var direction_changed = input_direction != held_move_direction;
    if (direction_changed) {
        held_move_direction = input_direction;
        move_hold_time = 0;
        move_start_delay = 0;
        ground_run_started = false;
    } else if (following_ground && input_direction != 0) {
        move_hold_time = min(move_hold_time + delta_time / 1000000, move_turn_delay + ground_startup_time);
    }

    if (wall_jump_steps > 0) {
        look_direction = wall_jump_direction;
        horizontal_speed = wall_jump_direction * wall_jump_speed;
        wall_jump_steps--;
    } else if (following_ground) {
        if (input_direction != 0 && facing_right != (input_direction > 0)) {
            horizontal_speed = 0;
            move_hold_time = 0;
            move_start_delay = move_turn_delay;
            horizontal_remainder = 0;
            ground_run_started = false;
        } else if (input_direction == 0) {
            var speed_limit = jump_pressed ? idle_jump_move_speed : move_speed;
            var braking = abs(horizontal_speed) <= ground_startup_speed ? ground_startup_friction : ground_friction;
            horizontal_speed = sign(horizontal_speed) * max(0, min(abs(horizontal_speed), speed_limit) - braking);
            if (horizontal_speed == 0) {
                horizontal_remainder = 0;
            }
            ground_motion = horizontal_speed != 0;
        } else if (move_hold_time >= move_start_delay) {
            var speed_limit = jump_pressed ? run_jump_move_speed : move_speed;
            var starting = move_hold_time < move_start_delay + ground_startup_time;
            var acceleration = starting ? ground_startup_speed : ground_acceleration_per_step;
            if (starting) {
                speed_limit = ground_startup_speed;
            }
            horizontal_speed = clamp(horizontal_speed + input_direction * acceleration, -speed_limit, speed_limit);
            ground_motion = true;
        }
    } else if (spin_jump && input_direction != 0) {
        if (sign(horizontal_speed) != input_direction) {
            horizontal_remainder = 0;
        }
        horizontal_speed = input_direction * run_jump_move_speed;
    } else if (input_direction != 0) {
        horizontal_speed = clamp(horizontal_speed + input_direction * air_acceleration_per_step, -air_move_speed, air_move_speed);
    } else if (spin_jump) {
        horizontal_speed = clamp(horizontal_speed, -air_move_speed, air_move_speed);
    } else {
        horizontal_speed = 0;
        horizontal_remainder = 0;
    }

    if (look_direction != 0) {
        facing_right = look_direction > 0;
    }

    var start_x = x;
    var side_solid = noone;
    var horizontal_total = horizontal_speed + horizontal_remainder;
    // En suelo, redondea al píxel más cercano y conserva la diferencia para el siguiente paso.
    var horizontal_pixels = following_ground ? floor(horizontal_total + 0.5) : sign(horizontal_total) * floor(abs(horizontal_total));
    horizontal_step = sign(horizontal_pixels);
    horizontal_remainder = horizontal_total - horizontal_pixels;
    horizontal_pixels = abs(horizontal_pixels);
    repeat (horizontal_pixels) {
        var next_x = x + horizontal_step;
        side_solid = instance_place(next_x, y, obj_test_solid);
        if (side_solid != noone) {
            horizontal_speed = 0;
            horizontal_remainder = 0;
            wall_jump_steps = 0;
            break;
        }
        if (place_meeting(next_x, y, obj_test_ramp)) {
            if (!following_ground || place_meeting(next_x, y - 1, terrain)) {
                horizontal_speed = 0;
                horizontal_remainder = 0;
                break;
            }
            y--;
        } else if (following_ground && !place_meeting(next_x, y + 1, terrain)
            && (place_meeting(x, y + 1, obj_test_ramp) || place_meeting(next_x, y + 2, obj_test_ramp))
            && place_meeting(next_x, y + 2, terrain)) {
            y++;
        }
        x = next_x;
        if (following_ground && !player_movement_has_support(terrain)) {
            following_ground = false;
            if (!jump_pressed) {
                // Entra al hueco antes de consumir los píxeles horizontales restantes.
                y++;
                horizontal_remainder = 0;
                break;
            }
        }
    }

    var moved_horizontally = x != start_x;
    // Conserva la carrera si el siguiente píxel todavía se está acumulando.
    ground_run_started = ground_motion
        && (moved_horizontally || (horizontal_pixels == 0 && ground_run_started));

    if (jump_pressed && vertical_speed >= 0
        && (place_meeting(x, y + 1, terrain) || (following_ground && player_movement_has_support(terrain)))) {
        spin_jump = input_direction != 0;
        if (spin_jump) {
            // La voltereta tiene su propio impulso desde el despegue.
            horizontal_speed = input_direction * run_jump_move_speed;
            horizontal_remainder = 0;
        }
        vertical_speed = -jump_speed;
        jump_start_y = y;
        fall_start_y = y;
        vertical_remainder = 0;
        apex_hold_steps = 0;
    }
    // Soltar la tecla termina el ascenso antes de aplicar gravedad.
    if (!jump_held && vertical_speed < 0) {
        vertical_speed = 0;
        vertical_remainder = 0;
    }
    if (apex_hold_steps > 0) {
        apex_hold_steps--;
    } else {
        var next_vertical_speed = min(vertical_speed + gravity_per_step, terminal_speed);
        if (vertical_speed < 0 && next_vertical_speed >= 0) {
            vertical_speed = 0;
            vertical_remainder = 0;
            apex_hold_steps = apex_hold_duration - 1;
        } else {
            vertical_speed = next_vertical_speed;
        }
    }

    if (side_solid != noone && input_direction == horizontal_step && vertical_speed >= 0 && apex_hold_steps == 0
        && !player_movement_has_support(terrain)) {
        // Use the same collision query as horizontal movement to find the wall.
        var ledge_top = side_solid.bbox_top;
        var ledge_offset = ledge_top - bbox_top;
        if (ledge_offset >= -2 && ledge_offset <= 16) {
            var hang_y = y + ledge_offset - 8;
            var stand_y = y + ledge_top - bbox_bottom - 1;
            var mask_width = bbox_right - bbox_left + 1;
            var stand_x = x + horizontal_step * mask_width;

            // Check the climb route before allowing the grab.
            var clear_path = true;
            for (var check_y = hang_y; clear_path && check_y >= stand_y; check_y--) {
                clear_path = !place_meeting(x, check_y, terrain);
            }
            for (var offset = 1; clear_path && offset <= mask_width; offset++) {
                clear_path = !place_meeting(x + horizontal_step * offset, stand_y, terrain);
            }

            if (clear_path && place_meeting(stand_x, stand_y + 1, obj_test_solid)) {
                y = hang_y;
                climb_x = stand_x;
                climb_y = stand_y;
                vertical_speed = 0;
                vertical_remainder = 0;
                horizontal_speed = 0;
                horizontal_remainder = 0;
                spin_jump = false;
                wall_jump_steps = 0;
                ground_contact = false;
                hanging = true;
                return undefined;
            }
        }
    }

    vertical_remainder += vertical_speed;
    var vertical_pixels = floor(abs(vertical_remainder));
    var vertical_step = sign(vertical_remainder);
    vertical_remainder -= vertical_pixels * vertical_step;
    repeat (vertical_pixels) {
        // Los sensores amplían el apoyo al caminar, pero el torso resuelve el aterrizaje.
        var blocked = place_meeting(x, y + vertical_step, terrain)
            || (vertical_step > 0 && following_ground && player_movement_has_support(terrain));
        if (blocked) {
            vertical_speed = 0;
            vertical_remainder = 0;
            break;
        }
        y += vertical_step;
    }
    fall_start_y = min(fall_start_y, y);

    var grounded = vertical_speed >= 0
        && (place_meeting(x, y + 1, terrain) || (following_ground && player_movement_has_support(terrain)));
    ground_contact = grounded;
    var landed = grounded && !started_grounded;
    if (landed) {
        vertical_speed = 0;
        vertical_remainder = 0;
        horizontal_speed = 0;
        horizontal_remainder = 0;
        ground_run_started = false;
    }
    // -1 al despegar, 0 en el punto más alto y 1 al recorrer la altura del salto en la caída.
    var rise_distance = jump_start_y - fall_start_y;
    var fall_distance = rise_distance > 0 ? rise_distance : jump_height;
    var jump_progress = 0;
    if (vertical_speed < 0) {
        jump_progress = clamp((jump_start_y - y) / jump_height - 1, -1, -0.001);
    } else if (vertical_speed > 0) {
        jump_progress = clamp((y - fall_start_y) / fall_distance, 0.001, 1);
    }
    return {
        grounded: grounded,
        moving: !landed && (moved_horizontally || ground_run_started),
        jump_progress: jump_progress,
        terrain: terrain
    };
}
