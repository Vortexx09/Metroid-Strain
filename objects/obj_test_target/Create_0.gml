max_health = 100;
target_hp = max_health;
last_damage = 0;
reset_steps = 0;

apply_damage = function(_amount) {
    if (target_hp <= 0) {
        return;
    }

    last_damage = _amount;
    target_hp = max(0, target_hp - _amount);
    if (target_hp == 0) {
        reset_steps = 60;
    }
};
