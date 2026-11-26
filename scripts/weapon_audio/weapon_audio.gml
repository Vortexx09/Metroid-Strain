function weapon_audio_init() {
    missile_charge_voice = noone;
}

function weapon_audio_charge_update(_charging) {
    if (_charging) {
        if (missile_charge_voice == noone) {
            missile_charge_voice = audio_play_sound(snd_missile_charge, 1, true);
        }
    } else if (missile_charge_voice != noone) {
        audio_stop_sound(missile_charge_voice);
        missile_charge_voice = noone;
    }
}

function weapon_audio_fired(_is_missile, _charged) {
    if (_is_missile) {
        weapon_audio_charge_update(false);
        audio_play_sound(_charged ? snd_missile_charged_fire : snd_missile_fire, 2, false);
    } else {
        audio_play_sound(snd_beam_fire, 1, false);
    }
}

function weapon_audio_impact(_is_missile) {
    if (_is_missile) {
        audio_play_sound(snd_missile_impact, 1, false);
    }
}

function weapon_audio_switch() {
    audio_play_sound(snd_weapon_switch, 1, false);
}

function weapon_audio_cleanup() {
    weapon_audio_charge_update(false);
}
