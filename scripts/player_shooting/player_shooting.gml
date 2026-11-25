function player_shooting_init() {
    shot_cooldown = 0;
    shot_interval = 10;
    missile_interval = 20;
    missiles_unlocked = false;
    missile_selected = false;
    shoot_pose_steps = 0;
    weapon_heat = 0;
    weapon_overheated = false;
    heat_recovery_delay = 0;
}

function player_shooting_step() {
    shot_cooldown = max(0, shot_cooldown - 1);
    shoot_pose_steps = max(0, shoot_pose_steps - 1);
    heat_recovery_delay = max(0, heat_recovery_delay - 1);
    if (!keyboard_check(ord("Z")) && heat_recovery_delay == 0) {
        weapon_heat = max(0, weapon_heat - 2);
        if (weapon_heat <= 35) {
            weapon_overheated = false;
        }
    }

    if (missiles_unlocked && keyboard_check_pressed(ord("Q"))) {
        missile_selected = !missile_selected;
    }
}

function player_shooting_aim() {
    return {
        x: keyboard_check(ord("L")) - keyboard_check(ord("J")),
        y: keyboard_check(ord("K")) - keyboard_check(ord("I"))
    };
}

function player_shooting_fire(_terrain, _aim) {
    if (shot_cooldown > 0 || !keyboard_check(ord("Z"))) {
        return;
    }

    var aim_x = _aim.x;
    var aim_y = _aim.y;
    if (aim_x == 0 && aim_y == 0) {
        aim_x = facing_right ? 1 : -1;
    }

    var shot_angle = point_direction(0, 0, aim_x, aim_y);
    var beam_x = x + 16;
    var beam_y = y + 12;
    var base_damage = missile_selected ? 24 : 10;
    weapon_heat = min(100, weapon_heat + (missile_selected ? 26 : 18));
    weapon_overheated = weapon_overheated || weapon_heat >= 100;
    heat_recovery_delay = 12;
    instance_create_layer(beam_x, beam_y, layer, obj_test_beam, {
        direction: shot_angle,
        is_missile: missile_selected,
        shot_damage: weapon_overheated ? base_damage * 0.5 : base_damage,
        terrain: _terrain
    });

    var base_interval = missile_selected ? missile_interval : shot_interval;
    shot_cooldown = weapon_overheated ? base_interval * 2 : base_interval;
    shoot_pose_steps = aim_y == 0 ? shot_interval : 0;
}
