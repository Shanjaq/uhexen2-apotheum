void apply_status (entity forent, float status_effect, float damage, float duration);
entity status_controller_get (entity forent, float query_flags);
entity T_RadiusDamageFlat (entity inflictor, entity attacker, float damage, float radius, entity ignore, float dmgflags);
void bubble_bob();
void hold(entity holdee);
void ThrowMoney(entity who);
void(float richter, entity source) MonsterQuake2;
vector aim2(entity prm1, float prm2) : 44;
void set_extra_flags(string a, float b) : 107;
void set_fx_color(string a, float b, float c, float d, float e) : 108;
float strhash(string a) : 109;
void centerprintf(entity client, string s, float num) : 110;
