function player_shooting_init() {
    shot_cooldown = 0;
    shot_interval = 10;
    missile_interval = 20;
    missiles_unlocked = false;
    missile_selected = false;
    missile_ammo = 0;
    missile_charge_steps = 0;
    missile_charge_duration = 45;
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
        missile_charge_steps = 0;
        weapon_audio_switch();
    }
}

function player_shooting_aim() {
    return {
        x: keyboard_check(ord("L")) - keyboard_check(ord("J")),
        y: keyboard_check(ord("K")) - keyboard_check(ord("I"))
    };
}

function player_shooting_fire(_terrain, _aim) {
    if (shot_cooldown > 0) {
        return;
    }

    var fire_held = keyboard_check(ord("Z"));
    var charged = false;
    if (missile_selected) {
        if (missile_ammo <= 0) {
            return;
        }
        if (fire_held) {
            missile_charge_steps = min(missile_charge_steps + 1, missile_charge_duration);
            return;
        }
        if (missile_charge_steps == 0) {
            return;
        }

        charged = missile_charge_steps == missile_charge_duration;
        missile_charge_steps = 0;
        missile_ammo--;
    } else if (!fire_held) {
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
    if (charged) {
        base_damage *= 2;
    }
    weapon_heat = min(100, weapon_heat + (missile_selected ? 26 : 9));
    weapon_overheated = weapon_overheated || weapon_heat >= 100;
    heat_recovery_delay = 12;
    instance_create_layer(beam_x, beam_y, layer, obj_test_beam, {
        direction: shot_angle,
        is_missile: missile_selected,
        is_charged: charged,
        shot_damage: weapon_overheated ? base_damage * 0.5 : base_damage,
        terrain: _terrain
    });
    weapon_audio_fired(missile_selected, charged);

    var base_interval = missile_selected ? missile_interval : shot_interval;
    shot_cooldown = weapon_overheated ? base_interval * 2 : base_interval;
    shoot_pose_steps = (missile_selected || aim_y == 0) ? shot_interval : 0;
}
