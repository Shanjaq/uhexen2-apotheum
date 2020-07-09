void() darkness_fall = {
	if(self.cnt < 25) {
		self.cnt += 1;
		self.origin_z -= 5;
		self.think = darkness_fall;
	} else {
		self.cnt = 0;
		self.think = squelch;
	}
	thinktime self : 0.02;
};

void () dark_tendrils_think = {
	if (time < self.splash_time)
	{
		if (self.origin_z >= self.dest_z)
			self.velocity_z = 0;
		if (random(0.00000, 4.00000) < 1.00000)
		{
			particle2 ( (self.origin + randomv('-30 -30 40', '30 30 100')), '-30.00000 -30.00000 60.00000', '30.00000 30.00000 200.00000', random(128, 143), 2, random(2.00000, 24.00000));
			particle2 ( (self.origin + randomv('-100 -100 100', '100 100 400')), '-30.00000 -30.00000 -4.00000', '30.00000 30.00000 -16.00000', random(1, 6), 2, random(2.00000, 16.00000));
			self.avelocity_y = random(-40, 40);
			if ((T_RadiusDamageFlat (self, self.owner, (self.spelldamage + random(self.spelldamage*(-0.12500), self.spelldamage*0.12500))*0.12500, 145.00000 * self.spellradiusmod, self.owner, FALSE)) && (random() < 0.36250))
				sound (self, CHAN_VOICE, "hydra/tent.wav", 1.00000, ATTN_NORM);
		}
		
		self.frame = random(0, 3);
		self.think = dark_tendrils_think;
		thinktime self : random(0.06250, 0.25000);
	} else {
		self.velocity_z -= random(48, 64);
		sound (self, CHAN_AUTO, "dsamaln6.wav", 1.00000, ATTN_NORM);
		self.think = SUB_Remove;
		thinktime self : 1.5000;
	}
};

void(vector start) dark_tendrils = {
	traceline (start + '0 0 128', (start - '0 0 400'), TRUE, newmis);
	newmis = spawn();
	newmis.spelldamage = self.spelldamage;
	newmis.spellradiusmod = self.spellradiusmod;
	newmis.lifetime = 4.00000;
	newmis.splash_time = (time + newmis.lifetime);
	setorigin(newmis, trace_endpos - '0 0 100');
	newmis.owner = self.owner;
	newmis.dest = newmis.origin;
	newmis.dest_z += random(10, 40);
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_NOCLIP;
	setmodel(newmis, "models/bushbash.mdl");
	newmis.scale = random(0.9, 1.3);
	newmis.drawflags (+) MLS_ABSLIGHT;
	newmis.abslight += 0.05;
	newmis.avelocity_y += random(-200, 200);
	newmis.velocity_z += random(10, 40);
	newmis.effects = EF_DARKLIGHT;
	//sound ( newmis, CHAN_AUTO, "darkness.wav", 1.00000, ATTN_NORM);
	//sound ( newmis, CHAN_AUTO, "ambience/newhum1.wav", 1.00000, ATTN_NORM);
	thinktime newmis : 0.02;
	newmis.think = dark_tendrils_think;
};

void() darkbeam_remove = {
	stopSound(self,CHAN_AUTO);
	remove(self);
};

void() baddie_sink = {
	if (time < self.splash_time)
	{
		if ((self.lip - self.origin_z) < (self.size_z * 0.5))
			self.abslight = (0.75 * (((self.size_z * 0.5) - (self.lip - self.origin_z)) / (self.size_z * 0.5)));
		else
		{
			if (self.state == 0)
			{
				self.state = 1;
				self.cnt = random(0, 3);
				if (self.cnt < 1)
					sound ( self, CHAN_VOICE, "ambience/moan1.wav", 1.00000, ATTN_NORM);
				else if (self.cnt < 2)
					sound ( self, CHAN_VOICE, "ambience/moan2.wav", 1.00000, ATTN_NORM);
				else if (self.cnt < 3)
					sound ( self, CHAN_VOICE, "ambience/moan3.wav", 1.00000, ATTN_NORM);
				
			}
		}
		
		thinktime self : 0.1;
		self.think = baddie_sink;
	}
	else
		remove(self);
};

void() darkbeam_think = {
	local entity head;
	local vector start;
	local float effect_scale;

	if (time < self.splash_time)
	{
		effect_scale = (300.00000*(1.00000 - ((self.splash_time - time) / self.lifetime)))*self.spellradiusmod;
		if (random(0.00000, 3.00000) < 1.00000)
		{
			start = self.origin;
			start_x += random(effect_scale*(-1), effect_scale);
			start_y += random(effect_scale*(-1), effect_scale);
			dark_tendrils(start);
		}
		
		self.dmg = (self.spelldamage + random(self.spelldamage*(-0.12500), self.spelldamage*0.12500))*0.12500;
		head = findradius(self.origin, effect_scale);
		while(head) {
			if (((head.takedamage == DAMAGE_YES) || (head.halted == 1)) && (head != self.owner)) {
				if((head.origin_z - self.origin_z) < 20) {
					if (((head.health > self.dmg) && (head.halted == 0)) || (head.health <= -1.00000))
					{
						T_Damage (head, self, self.owner, self.dmg);
					} else {
						if (head.solid != SOLID_BSP) {
							if (head.classname == "player") {
								head.solid = SOLID_NOT;
								head.movetype = MOVETYPE_NOCLIP;
								head.origin_z -= 10;
								thinktime head : 0.1;
								head.think = darkness_fall;
							} else {
								if (head.halted == 0)
								{
									head.halted = 1;
									head.solid = SOLID_NOT;
									head.movetype = MOVETYPE_NOCLIP;
									head.velocity_z = -36;
									head.drawflags (+) MLS_ABSLIGHT;
									head.abslight = 0.75;
									head.splash_time = time + 3.5;
									head.lip = head.origin_z;
									head.state = 0;
									T_Damage ( head, self, self.owner, head.health);
									head.takedamage = DAMAGE_NO;
									
									if (self.owner != world)
										AwardExperience ( self.owner, head, head.experience_value);
									
									thinktime head : HX_FRAME_TIME;
									head.think = baddie_sink;
								} else {
									if (head.abslight > 0.07500)
										head.abslight -= 0.07500;
								}
							}
						} else {
							T_Damage ( head, self, self.owner, self.dmg);
						}
					}
				}
			}
			head = head.chain;
		}
		
		self.think = darkbeam_think;
		thinktime self : 0.10000;
	} else {
		sound ( self, CHAN_AUTO, "ambience/newhum1.wav", 1.00000, ATTN_NORM);
		self.think = darkbeam_remove;
		thinktime self : 3;
	}
};

void() darkbeam = {
	newmis = spawn();
	newmis.spelldamage = self.spelldamage;
	newmis.spellradiusmod = self.spellradiusmod;
	newmis.lifetime = 8.00000;
	newmis.splash_time = time + newmis.lifetime;
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_NOCLIP;
	newmis.effects = EF_DARKLIGHT;
	newmis.owner = self.owner;
	traceline (self.origin, (self.origin - '0 0 800'), TRUE, self);
	setorigin(newmis, trace_endpos);
	setmodel(newmis, "models/null.spr");
	sound ( self, CHAN_WEAPON, "darkblast.wav", 1.00000, ATTN_NORM);
	sound ( self, CHAN_BODY, "darkburst.wav", 1.00000, ATTN_NORM);
	sound ( newmis, CHAN_AUTO, "ambience/newhum1.wav", 1.00000, ATTN_NORM);
	thinktime newmis : 0.02;
	newmis.think = darkbeam_think;
};