function player_shooting_init() {
    shot_cooldown = 0;
    shot_interval = 6;
    missile_interval = 20;
    missiles_unlocked = false;
    missile_selected = false;
    shoot_pose_steps = 0;
    shoot_pose_duration = 6;
    beam_charge_steps = 0;
    beam_charge_delay = 15;
    beam_charge_full = 65;
}

function player_shooting_step() {
    shot_cooldown = max(0, shot_cooldown - 1);
    shoot_pose_steps = max(0, shoot_pose_steps - 1);

    if (missiles_unlocked && keyboard_check_pressed(ord("Q"))) {
        missile_selected = !missile_selected;
        beam_charge_steps = 0;
    }
}

function player_shooting_aim(_running) {
    var aim_x = keyboard_check(ord("L")) - keyboard_check(ord("J"));
    var aim_y = keyboard_check(ord("K")) - keyboard_check(ord("I"));
    var forward = facing_right ? 1 : -1;

    if (keyboard_check(vk_up)) {
        return { x: _running ? forward : 0, y: -1 };
    }
    if (keyboard_check(vk_down)) {
        return { x: _running ? forward : 0, y: 1 };
    }
    if (keyboard_check(ord("A"))) {
        return { x: forward, y: -1 };
    }
    if (keyboard_check(ord("S"))) {
        return { x: forward, y: 1 };
    }

    if (_running && aim_y != 0 && aim_x == 0) {
        aim_x = forward;
    }
    return { x: aim_x, y: aim_y };
}

function player_shooting_prepare(_pressed) {
    var fire_key = ord("Z");
    var released = keyboard_check_released(fire_key);
    var releasing_charge = !missile_selected && released && beam_charge_steps > beam_charge_delay;
    var charged = releasing_charge && beam_charge_steps >= beam_charge_full;
    if (!missile_selected && keyboard_check(fire_key)) {
        beam_charge_steps = min(beam_charge_steps + 1, beam_charge_full);
    } else {
        beam_charge_steps = 0;
    }
    if (shot_cooldown > 0 || (!_pressed && !releasing_charge)) {
        return undefined;
    }

    shoot_pose_steps = shoot_pose_duration;
    shot_cooldown = missile_selected ? missile_interval : (releasing_charge ? 16 : shot_interval);
    return charged;
}

function player_shooting_fire(_terrain, _aim, _charged) {
    var aim_x = _aim.x;
    var aim_y = _aim.y;
    if (aim_x == 0 && aim_y == 0) {
        aim_x = facing_right ? 1 : -1;
    }

    var shot_angle = point_direction(0, 0, aim_x, aim_y);
    var beam_x = x + 16;
    var beam_y = y + 12;
    var muzzle_x = beam_x + lengthdir_x(14, shot_angle);
    var muzzle_y = beam_y + lengthdir_y(14, shot_angle);
    var muzzle = player_shooting_muzzle(sprite_index, image_index);
    if (!is_undefined(muzzle)) {
        muzzle_x = x - 16 + muzzle[0];
        muzzle_y = y - 16 + muzzle[1];
    }
    if (collision_line(beam_x, beam_y, muzzle_x, muzzle_y, _terrain, true, true) == noone) {
        instance_create_layer(muzzle_x, muzzle_y, layer, obj_test_beam,
            { direction: shot_angle, is_missile: missile_selected, is_charged: _charged });
    }
}

// Punta del cañón en píxeles desde la esquina superior izquierda del fotograma.
function player_shooting_muzzle(_sprite, _frame) {
    var points;
    switch (_sprite) {
        case spr_samus_idleshoot_d_l:
            return [22, 42];
        case spr_samus_idleshoot_d_r:
            return [41, 42];
        case spr_samus_idleshoot_dd_l:
            return [16, 32];
        case spr_samus_idleshoot_dd_r:
            return [47, 33];
        case spr_samus_idleshoot_du_l:
            return [16, 11];
        case spr_samus_idleshoot_du_r:
            return [47, 11];
        case spr_samus_idleshoot_l:
            return [17, 26];
        case spr_samus_idleshoot_r:
            return [47, 26];
        case spr_samus_idleshoot_u_l:
            return [28, 3];
        case spr_samus_idleshoot_u_r:
            return [36, 3];
        case spr_samus_runshoot_dd_l:
            points = [
                [18, 31], [17, 30], [17, 30], [17, 29], [17, 30],
                [18, 31], [17, 30], [17, 30], [17, 29], [18, 30]
            ];
            break;
        case spr_samus_runshoot_dd_r:
            points = [
                [45, 31], [46, 30], [46, 30], [46, 29], [46, 30],
                [45, 31], [46, 30], [46, 30], [46, 29], [46, 30]
            ];
            break;
        case spr_samus_runshoot_du_l:
            points = [
                [18, 14], [18, 13], [16, 11], [16, 10], [17, 12],
                [18, 14], [17, 13], [16, 11], [17, 10], [17, 12]
            ];
            break;
        case spr_samus_runshoot_du_r:
            points = [
                [45, 14], [45, 13], [46, 12], [46, 10], [47, 13],
                [46, 14], [47, 14], [46, 12], [46, 10], [46, 12]
            ];
            break;
        case spr_samus_runshoot_l:
            points = [
                [17, 26], [16, 24], [15, 24], [15, 24], [16, 24],
                [17, 26], [16, 26], [15, 24], [15, 24], [16, 24]
            ];
            break;
        case spr_samus_runshoot_r:
            points = [
                [46, 26], [47, 24], [48, 24], [48, 24], [47, 24],
                [46, 26], [47, 26], [48, 24], [48, 24], [47, 24]
            ];
            break;
        case spr_samus_idlejump_d_l:
            points = [
                [20, 36], [24, 42]
            ];
            break;
        case spr_samus_idlejump_d_r:
            points = [
                [36, 36], [40, 42]
            ];
            break;
        case spr_samus_idlejump_dd_l:
            points = [
                [18, 34], [16, 29], [16, 27], [17, 29], [17, 29],
                [16, 30], [16, 27]
            ];
            break;
        case spr_samus_idlejump_dd_r:
            points = [
                [42, 33], [47, 29], [47, 27], [46, 28], [46, 28],
                [47, 27], [47, 26]
            ];
            break;
        case spr_samus_idlejump_du_l:
            points = [
                [18, 14], [16, 10], [17, 10], [18, 12], [18, 12],
                [17, 12], [17, 10]
            ];
            break;
        case spr_samus_idlejump_du_r:
            points = [
                [44, 14], [47, 10], [46, 10], [45, 12], [45, 12],
                [46, 10], [46, 9]
            ];
            break;
        case spr_samus_idlejump_l:
            points = [
                [21, 30], [15, 24], [16, 22], [17, 24], [17, 24],
                [16, 24], [15, 24]
            ];
            break;
        case spr_samus_idlejump_r:
            points = [
                [39, 24], [48, 24], [47, 22], [46, 24], [46, 24],
                [47, 24], [48, 24]
            ];
            break;
        case spr_samus_idlejump_u_l:
            points = [
                [28, 5], [28, 3], [28, 3], [28, 3], [28, 3],
                [26, 3], [28, 3]
            ];
            break;
        case spr_samus_idlejump_u_r:
            points = [
                [38, 5], [36, 3], [36, 3], [36, 3], [36, 3],
                [36, 3], [36, 3]
            ];
            break;
        default:
            return undefined;
    }
    return points[clamp(floor(_frame), 0, array_length(points) - 1)];
}
