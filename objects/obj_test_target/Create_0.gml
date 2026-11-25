max_health = 100;
health = max_health;
last_damage = 0;
reset_steps = 0;

apply_damage = function(_amount) {
    if (health <= 0) {
        return;
    }

    last_damage = _amount;
    health = max(0, health - _amount);
    if (health == 0) {
        reset_steps = 60;
    }
};
