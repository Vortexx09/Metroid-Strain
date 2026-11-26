function player_audio_init() {
    audio_was_grounded = false;
    audio_was_hanging = false;
    audio_run_frame = -1;
}

function player_audio_step(_movement) {
    var has_movement = !is_undefined(_movement);
    var grounded = has_movement ? _movement.grounded : !hanging;

    if (hanging && !audio_was_hanging) {
        audio_play_sound(snd_player_hang, 1, false);
    } else if (audio_was_hanging && !hanging && !has_movement) {
        audio_play_sound(snd_player_climb, 1, false);
    } else if (has_movement) {
        switch (_movement.jump_kind) {
            case PlayerJumpKind.Upright:
                audio_play_sound(snd_player_jump, 1, false);
                break;
            case PlayerJumpKind.Spin:
                audio_play_sound(snd_player_spin_jump, 1, false);
                break;
            case PlayerJumpKind.Wall:
                audio_play_sound(snd_player_wall_jump, 1, false);
                break;
            case PlayerJumpKind.None:
                if (grounded && !audio_was_grounded) {
                    audio_play_sound(snd_player_land, 1, false);
                }
                break;
        }
    }

    if (has_movement && grounded && _movement.moving
        && (animator.state == PlayerAnimationState.Run || animator.state == PlayerAnimationState.RunShoot)) {
        var frame = floor(image_index);
        if (frame != audio_run_frame && (frame == 2 || frame == 7)) {
            audio_play_sound(snd_player_footstep, 0, false);
        }
        audio_run_frame = frame;
    } else {
        audio_run_frame = -1;
    }

    audio_was_grounded = grounded;
    audio_was_hanging = hanging;
}
