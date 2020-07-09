void() ShakeRattleAndRoll;

// BAER
void () ChunkShrink = 
{
	if (self.abslight > 1.1) {
		self.abslight -= 0.01;
		if (self.classname != "tsunami") {
			self.dmg = ((self.spelldamage + random(self.spelldamage*(-0.12500), self.spelldamage*0.12500))*0.06250)*self.abslight;
			particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 140.00000, 16, random(1, 15));
			T_RadiusDamageFlat (self, self.owner, self.dmg, (26.00000*self.abslight), self.owner, FALSE);
			//T_RadiusDamage (self, self.owner, (self.abslight * 18), other);
		}
	} else {
		self.scale -= 0.05;
	}

	if ((self.classname == "blackhole") && (self.scale < (0.75 * self.spellradiusmod))) {
		self.drawflags (-) DRF_TRANSLUCENT;
	}
	if (self.scale < 0.1) {
		if ((self.classname == "blackhole") || (self.classname == "basher") || (self.classname == "flame") || (self.classname == "liquid_chunk"))
			remove(self);
		else
			ChunkRemove();
		
	}
	self.think = ChunkShrink;
	self.nextthink = time + HX_FRAME_TIME;

};

void ()burn_flame_think = {
	if (time < self.splash_time)
	{
		if (self.goalentity.health)
		{
			setorigin (self, randomv(self.goalentity.absmin, self.goalentity.absmax));
			if (self.owner != world)
				self.scale = (0.75000 + ((self.owner.burn_cnt / 10.00000) * 1.6)) * random();
			else
				self.scale = (0.75000 * random());
		}
		else
		{
			setorigin (self, self.owner.origin + randomv('-32 -32 0', '32 32 12'));
			self.scale = (0.75000 * random());
		}
		
		if ((self.owner != world) && (self.owner.burn_time <= time))
			self.splash_time = time;
		
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 140.00000, 16, random(4.00000, 10.00000));
		self.think = burn_flame_think;
		thinktime self : 0.16250;
	}
	else
	{
		if (self.owner != world)
			self.owner.cnt -= 1;
		self.think = ChunkShrink;
		thinktime self : HX_FRAME_TIME;
	}
};

void ()burn_flame = {
	newmis = spawn();
	newmis.owner = self;
	newmis.goalentity = self.goalentity;
	newmis.hull = HULL_POINT;
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_NOCLIP;
	setmodel (newmis, "models/flamec.mdl");
	newmis.classname = "flame";
	
	if (self.goalentity.health)
		setorigin (newmis, newmis.goalentity.origin);
	else
		setorigin (newmis, self.origin);
	
	newmis.angles_x = 270;
	newmis.drawflags (+) (MLS_ABSLIGHT | DRF_TRANSLUCENT);
	newmis.effects = EF_DIMLIGHT;
	newmis.abslight = 1.00000;
	newmis.lifetime = 3.00000;
	newmis.splash_time = (time + newmis.lifetime);
	thinktime newmis : 0.1;
	newmis.think = burn_flame_think;
};

void() bubble_spawner_think = {
	local entity bubble;
	local float pc;
	
	pc = pointcontents(self.origin);
	if ( (((pc == CONTENT_WATER) || (pc == CONTENT_SLIME)) || (pc == CONTENT_LAVA)) )
	{
		bubble = spawn_temp ( );
		setmodel ( bubble, "models/s_bubble.spr");
		setorigin ( bubble, self.origin);
		bubble.movetype = MOVETYPE_NOCLIP;
		bubble.solid = SOLID_NOT;
		bubble.velocity = '0.00000 0.00000 17.00000';
		thinktime bubble : 0.50000;
		bubble.think = bubble_bob;
		bubble.classname = "bubble";
		bubble.frame = 0.00000;
		bubble.cnt = 0.00000;
		bubble.abslight = 0.50000;
		bubble.drawflags (+) (DRF_TRANSLUCENT | MLS_ABSLIGHT);
		setsize ( bubble, '-8.00000 -8.00000 -8.00000', '8.00000 8.00000 8.00000');
	}
	self.think = bubble_spawner_think;
	thinktime self : HX_FRAME_TIME;
};

void() CrashFlash =
{
	local entity head;
	local float dist;

	if (self.classname == "flare") {
		dist = 700;
	} else {
		dist = 400;
	}
	//        selected = world;
	if (self.classname == "flare") {
		head = findradius(self.origin, dist);
	} else {
		head = findradius((self.origin - '0 0 400'), dist);
	}
	while(head)
	{
		if ((self.classname == "flare") && (head.health > 0))
		{
			if (head.flags2 & FL_ALIVE) 
			{
				if (head.classname == "player")
				{
					head.artifact_active (+) ARTFLAG_DIVINE_INTERVENTION;
					head.divine_time = (time + 1);
				}
				thinktime head : 4; 
				hold(head);
			}

			T_Damage ( head, self, self.owner, 1.00000);
		}
		if ((self.classname == "swelterment") && (head.health > 0) && (head != self.owner))
		{
			T_Damage ( head, self, self.owner, random(5, 10));
		}

		head = head.chain;
	}
};


// BAER. All new code.
void ()GasserThink = 
{
	if (self.classname == "flare") {
		sound (self, CHAN_AUTO, "weapons/r_exp3.wav", 1, ATTN_NORM);
	}

	self.count += 1;

	if (self.count >= self.cnt)
	{
		self.think = self.th_die;
		thinktime self : HX_FRAME_TIME;
		//if (self.classname == "flare") {
		//	flare_blast();
		//	flare_rings();
		//}
 		remove(self);
		return;
	}
	local vector random_vector;

	random_vector_x = random(-50,50);
	random_vector_y = random(-50,50);
	random_vector_z = random(-50,50);

	if (random() > 0.8)
		CreateExplosion29 (self.origin + random_vector);
	else
		CreateFireCircle (self.origin + random_vector);

	if (self.count == (self.cnt - 1)) {
		thinktime self : 2;
		self.think = GasserThink;
	} else {
		self.think = GasserThink;
		thinktime self : HX_FRAME_TIME;
	}
};
// BAER. End All new code.

void ()liquid_reset = {
	liquidcount = FALSE;
	remove(self);
};

void  ()make_liquid_reset =  {
	if (cleanup_timer == world)
	{
		cleanup_timer = spawn ( );
		cleanup_timer.think = liquid_reset;
	}
	cleanup_timer.nextthink = time + 1.50000;
};

void() liquid_drop_timer = {
	if ((pointcontents(self.origin) == CONTENT_WATER) || (pointcontents(self.origin) == CONTENT_SLIME)) {
		self.cnt = 0;
		self.counter = 0;
	}
	
	pitch_roll_for_slope('0.00000 0.00000 0.00000', self);
	if (self.cnt <= 0) {
		self.solid = SOLID_PHASE;
		if (self.counter > 0) {
			self.counter -= 1;
			self.dmg = ((self.spelldamage + random(self.spelldamage*(-0.12500), self.spelldamage*0.12500))*0.12500)*self.scale;
			if ((T_RadiusDamageFlat (self, self.owner, self.dmg, (24.00000*self.scale), self.owner, FALSE) != world) && (random() < 0.12500))
				sound ( self, CHAN_AUTO, "crusader/sunhit.wav", 1.00000, ATTN_NORM);

			//T_RadiusDamage (self, self.owner, (self.scale * 15), other);
			self.think = liquid_drop_timer;
			self.nextthink = (time + 0.2);
		} else {
			self.think = ChunkShrink;
			self.nextthink = (time + 0.2);

			return;
		}
	} else {
		self.cnt -= 1;
		self.frame += 1;
		self.think = liquid_drop_timer;
		thinktime self : 0.08;
	}
};

void() liquid_fall_timer = {
	if (self.lifetime <= 0) {
		self.think = ChunkRemove;
		thinktime self : 0.1;
		return;
	} else {
		self.lifetime -= 1;
		self.think = liquid_fall_timer;
		thinktime self : 0.1;
		if ((pointcontents(self.origin) == CONTENT_WATER) || (pointcontents(self.origin) == CONTENT_SLIME)) {
			CreateWhiteSmoke ( self.origin, '0.00000 0.00000 8.00000', (HX_FRAME_TIME * 3.00000));
		}
	}
};

void() liquid_drop = {
	local float pc, i;
	local vector spot;
	local entity drop;
	
	if (liquidcount < MAX_LIQUID_COUNT) {
		liquidcount += 1;

		drop = spawn_temp();
		drop.air_finished = self.air_finished;
		drop.spelldamage = self.spelldamage;
		drop.spellradiusmod = self.spellradiusmod;
		drop.ltime = time;
		drop.owner = self.owner;
		drop.frame = 0;
		drop.lifetime = 30;
		drop.cnt = (1 + random(3));
		drop.classname = "liquid_chunk";
		drop.movetype = MOVETYPE_TOSS;
		drop.solid = SOLID_PHASE;
		drop.velocity = (randomv('-1 -1 -1', '1 1 1') * self.lip);
		/*
		if (self.exploderadius == 1) {
			drop.velocity = random('-100 -100 0','100 100 150'); // notice the accent on the up velocity
		} else {
			drop.velocity = random('-500 -500 -50','500 500 250'); // notice the accent on the up velocity
		}
		*/
		// set drop speed
		drop.counter = random(20, 40);
		drop.touch = liquid_drop_timer;
		drop.drawflags = MLS_ABSLIGHT;
		drop.abslight = 1.50000;

		// set drop duration
		setmodel (drop, "models/bloodspot.mdl");
		
		if (self.air_finished == LIQUID_TYPE_BLOOD)
			drop.skin = 0;
		else if (self.air_finished == LIQUID_TYPE_LAVA)
			drop.skin = 1;
		else if ((self.air_finished == LIQUID_TYPE_SLIME) || (self.status_effects & STATUS_TOXIC))
			drop.skin = 2;


		drop.scale = (0.5 + random(2));
		setsize (drop, '0 0 0', '0 0 0');
		drop.angles = randomv('0.00000 -180.00000 0.00000','0.00000 180.00000 0.00000');
		
		i = 0;
		spot = self.origin + (randomv('-1 -1 -1', '1 1 1') * self.exploderadius);
		pc = pointcontents(spot);
		while ((i < 8) && (pc == CONTENT_SOLID))
		{
			spot = self.origin + (randomv('-1 -1 -1', '1 1 1') * self.exploderadius);
			pc = pointcontents(spot);
			i += 1;
		}
		
		if (pc == CONTENT_EMPTY)
		{
			setorigin(drop, spot);
			drop.think = liquid_fall_timer;
			thinktime drop : HX_FRAME_TIME;
		}
		else
		{
			thinktime self : HX_FRAME_TIME;
			self.think = SUB_Remove;
			thinktime drop : HX_FRAME_TIME;
			drop.think = SUB_Remove;
		}
	} else {
		thinktime self : HX_FRAME_TIME;
		self.think = SUB_Remove;
	}
};

void(vector pos) liquid_bubble = {
	local entity chunk, found;
	
	chunk = spawn_temp();
	chunk.spelldamage = self.spelldamage;
	chunk.spellradiusmod = self.spellradiusmod;
	chunk.ltime = time;
	chunk.owner = self.owner;
	chunk.lifetime = random(3.00000, 5.00000);
	chunk.splash_time = time + chunk.lifetime;
	chunk.classname = "liquid_chunk";
	chunk.movetype = MOVETYPE_NOCLIP;
	chunk.solid = SOLID_NOT;
	//chunk.cnt = (1 + random(3));
	chunk.think = liquid_drop_timer;
	thinktime chunk : HX_FRAME_TIME;

	setmodel (chunk, "models/bloodspot.mdl");
	chunk.skin = 2;
	chunk.scale = (0.25000 + random(1.62500));
	setsize (chunk, '0 0 0', '0 0 0');
	setorigin (chunk, pos);
	chunk.angles = randomv('0.00000 -180.00000 0.00000','0.00000 180.00000 0.00000');
	
	found = T_RadiusDamageFlat (chunk, chunk.owner, (chunk.spelldamage + random(chunk.spelldamage*(-0.12500), chunk.spelldamage*0.12500))*0.12500, 128.00000, chunk.owner, 2);
	while (found)
	{
		apply_status(found, STATUS_TOXIC, (self.spelldamage * 0.12500), random(7, 11));
		found = found.chain2;
	}
};

void() liquid_fly = {
	if (self.cnt>0) {
		self.cnt -= 1;
		liquid_drop();
		thinktime self : HX_FRAME_TIME;
		self.think = liquid_fly;
	} else {
		thinktime self : HX_FRAME_TIME;
		self.think = SUB_Remove;
	}
};

void(float type, float amount, float radius, float force) liquid_spray = {
	local entity missile;

	make_liquid_reset();
	missile = spawn();
	missile.spelldamage = self.spelldamage;
	missile.spellradiusmod = self.spellradiusmod;
	missile.ltime = time;
	missile.owner = self.owner;
	missile.cnt = amount;
	missile.exploderadius = radius;
	missile.air_finished = type;
	missile.lip = rint(force);
	missile.origin = self.origin;
	thinktime missile : HX_FRAME_TIME;
	missile.think = liquid_fly;
};

void() squelch = {
	self.colormap = 0;
	//setorigin(self, (self.jones.origin - '0 0 3900'));
	setorigin(self, '0 0 -3900');
	//if (heresy) {
	//	self.mage = 0;
	//}
	GibPlayer ( );
	self.health = 0;
	stuffcmd(self, "fov 90\n");
	self.halted = 0;
};

void() BlowUp3 =
{
	local entity head;
	local float dist;
	
	if (self.scale >= (1.35000*self.spellradiusmod) && !(self.drawflags & DRF_TRANSLUCENT))
	{
		
		self.drawflags (+) DRF_TRANSLUCENT;

		self.abslight -= 0.1;	
	}

	if (self.scale>(1.65000*self.spellradiusmod)) {
		self.think = SUB_Remove;
		self.nextthink = (time + 0.02);
		remove (self);
		return;
	} else {
		self.scale += 0.10000;
	}
	
	dist = (self.scale * 75);
	head = findradius(self.origin, (self.scale * 75));
	while(head)
	{
		if((head.health >= 1) && (head != self.owner))
		{
			if ( (vlen(head.origin - self.origin) < dist) )
			{
				dist = vlen(head.origin - self.origin);
				
				//if  ((head.freeze_time <= time) && (head.health<10)) {
				if ( ((((((head.health <= self.spelldamage) || (((head.classname == "player") && (head.frozen <= -5.00000)) && (head.health < 200.00000))) && (head.solid != SOLID_BSP)) && !(head.artifact_active & ART_INVINCIBILITY)) && (head.thingtype == THINGTYPE_FLESH)) && (head.health < 100.00000)) ) {
					SnowJob ( head, self.owner);
				} else {
					if (head.freeze_time <= time) {
						T_Damage ( head, self, self.owner, self.spelldamage);
					}
				}
			}
		}
		head = head.chain;
	}
	self.nextthink = 0.5;
	self.think = BlowUp3;
};

void ()coldsp_timer; //shan delet this

void  ()SprayIce =  
{
	local entity fireballblast;
	//   sound ( self, CHAN_AUTO, "exp3.wav", 1.00000, ATTN_NORM);
	sound ( self, CHAN_AUTO, "weapons/fbfire.wav", 1.00000, ATTN_NORM);
	fireballblast = spawn ( );
	fireballblast.spelldamage = self.spelldamage;
	fireballblast.spellradiusmod = self.spellradiusmod;
	fireballblast.enemy = self.enemy;
	fireballblast.movetype = MOVETYPE_NOCLIP;
	fireballblast.owner = self.owner;
	fireballblast.o_angle = self.o_angle;
	fireballblast.classname = "fireballblast";
	fireballblast.solid = SOLID_NOT;
	fireballblast.drawflags (+) ((MLS_ABSLIGHT | SCALE_TYPE_UNIFORM) | SCALE_ORIGIN_CENTER);
	fireballblast.abslight = 1;
	fireballblast.scale = 0.1;
	setmodel ( fireballblast, "models/iceboom.mdl");
	setsize ( fireballblast, '0.00000 0.00000 0.00000', '0.00000 0.00000 0.00000');
	setorigin ( fireballblast, self.origin);
	fireballblast.dmg = 0.1;
	fireballblast.avelocity = '50.00000 50.00000 50.00000';
	fireballblast.think = BlowUp3;
	thinktime fireballblast : 0.00000;
	remove ( self);
};

void() IceBlastWave = {
	if (time < self.splash_time)
	{
		self.scale = ((1.00000 - ((self.splash_time - time) / self.lifetime)) * 0.36250)*self.spellradiusmod;
		self.abslight = ((self.splash_time - time) / self.lifetime);
		self.think = IceBlastWave;
	} 
	else 
	{
		self.think = SUB_Remove;
	}
	thinktime self : HX_FRAME_TIME;
};

void (float howbig, float howmuch)IceBoom =
{
	local entity head;
	local float dist;
	local vector move_angle;
	dist = howbig;
	head = findradius(self.origin, howbig);
	while(head)
	{
		if((head.health >= 1) && (head != self.owner))
		{
			traceline(self.origin,head.origin,TRUE,self);
			if ( (vlen(head.origin - self.origin) < dist) )
			{
				dist = vlen(head.origin - self.origin);
				
				//if  ((head.freeze_time <= time) && (head.health<10)) {
				if ( ((((((head.health <= howmuch) || (((head.classname == "player") && (head.frozen <= -5.00000)) && (head.health < 200.00000))) && (head.solid != SOLID_BSP)) && !(head.artifact_active & ART_INVINCIBILITY)) && (head.thingtype == THINGTYPE_FLESH)) && (head.health < 100.00000)) ) {
					SnowJob ( head, self.owner);
				} else {
					if (head.freeze_time <= 0) {
						T_Damage ( head, self, self.owner, howmuch);
					}
				}
			}
		}
		head = head.chain;
	}
	
	newmis = spawn();
	newmis.spellradiusmod = self.spellradiusmod;
	setorigin (newmis, self.origin);
	newmis.scale = 0.01250;
	setmodel(newmis, "models/expring.mdl");
	newmis.drawflags = MLS_ABSLIGHT;
	newmis.abslight = 1;
	newmis.skin = 1;
	move_angle = vectoangles(self.velocity);
	move_angle_x *= -1;
	makevectors (move_angle);
	traceline ( (self.origin - (v_forward * 24.00000)), (self.origin + (v_forward * 48.00000)), 1, self);
	if ((trace_ent.classname == "worldspawn") && (trace_fraction < 1)) {
		//sprint(self.owner, "hit a wall!\n");
		newmis.angles = vectoangles(trace_plane_normal);
		newmis.angles_x = ((90.00000 - newmis.angles_x) * -1.00000);
	} else {
		//sprint(self.owner, "hit something else!\n");
		newmis.angles = vectoangles(v_forward);
	}
	newmis.lifetime = 0.36250;
	newmis.splash_time = time + newmis.lifetime;
	
	thinktime newmis : 0.02;
	newmis.think = IceBlastWave;
	
	
	self.nextthink = 0.5;
	self.think = coldsp_timer;

};

void  ()splashz = {
	if (self.frame>4) {
		self.think = SUB_Remove;
		self.nextthink = (time + 0);
		return;
	} else {
		self.frame = (self.frame + 1);
		self.think = splashz;
		self.nextthink = (time + 0.08);
	}
};
void  ()splashy = {
	local entity splash;

	splash = spawn();
	setorigin (splash, self.origin);
	splash.solid = SOLID_NOT;
	splash.drawflags = MLS_ABSLIGHT;
	splash.effects = EF_DIMLIGHT;
	setmodel (splash, "models/splashy.mdl");
	splash.abslight = 0.5;
	splash.owner = self.owner;
	splash.lip = self.lip;
	splash.skin = 0;
	splash.frame = 0;
	splash.angles = (self.angles);
	splash.think = splashz;
	splash.nextthink = (time + 0.02);
	if (self.oldweapon == 1) {
		self.skin = 5;
	}
	if (self.skin == 0) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 140.00000, 2, 80.00000);
		sound ( splash, CHAN_VOICE, "chit1.wav", 1.00000, ATTN_NORM);
	}

	if (self.skin == 1) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 174.00000, 2, 80.00000);
		sound ( splash, CHAN_VOICE, "chit1.wav", 1.00000, ATTN_NORM);
	}

	if (self.skin == 2) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 245.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 245.00000, 2, 80.00000);
		sound ( splash, CHAN_VOICE, "chit2.wav", 1.00000, ATTN_NORM);
	}

	if (self.skin == 3) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 248.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 250.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 249.00000, 2, 80.00000);
		sound ( splash, CHAN_VOICE, "chit2.wav", 1.00000, ATTN_NORM);
	}

	if (self.skin == 4) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 241.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 242.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 240.00000, 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', 241.00000, 1, 80.00000);
		sound ( splash, CHAN_VOICE, "chit2.wav", 1.00000, ATTN_NORM);
	}

	if (self.skin == 5) {
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(112, 127), 17, 80.00000);
		particle2 ( self.origin, '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(168, 175), 2, 80.00000);
		sound ( splash, CHAN_VOICE, "golem/stomp.wav", 1.00000, ATTN_NORM);
	}


	remove(self);
};

void  ()charge_touch =  {
	if ( (((other == world) || (other.solid == SOLID_BSP)) || (other.mass > 300.00000)) ) {
		splashy();
		//      DarkExplosion ( );
	} else {

		if ( (other != self.enemy) ) {

			if ( other.takedamage ) {

				self.enemy = other;
				makevectors ( self.velocity);
				T_Damage ( other, self, self.owner, self.dmg);
				if ( (self.dmg < 10.00000) ) {

					T_Damage ( other, self, self.owner, 10.00000);
					splashy();         
					//DarkExplosion ( );
				} else {

					SpawnPuff ( self.origin, self.velocity, 10.00000, other);
					SpawnPuff ( (self.origin + (v_forward * 36.00000)), self.velocity, 10.00000, other);
					if ( (other.thingtype == THINGTYPE_FLESH) ) {

						sound ( self, CHAN_VOICE, "assassin/core.wav", 1.00000, ATTN_NORM);
						MeatChunks ( (self.origin + (v_forward * 36.00000)), (((self.velocity * 0.20000) + (v_right * random(-30.00000,150.00000))) + (v_up * random(-30.00000,150.00000))), 5.00000, other);

					}
					if ( (other.classname == "player") ) {

						T_Damage ( other, self, self.owner, ((self.dmg + (self.frags * 10.00000)) / 3.00000));
					} else {

						T_Damage ( other, self, self.owner, (self.dmg + (self.frags * 10.00000)));

					}
					self.frags += 1.00000;
					self.dmg -= 10.00000;

				}

			}

		}

	}
};

void ()ShockShake =
{
	local entity head;
	local float dist, inertia;
	

	if (time < self.splash_time)
	{
		head = findradius ( self.origin, self.mass);
		while (head)
		{
			if (head.classname == "player")
			{
				dist = (vlen ( (self.origin - head.origin)) / self.mass);
				inertia = (head.mass / 10);
				//head.punchangle_x = (((random() * 10) - 5) * (dist / self.mass));
				//head.punchangle_y = (((random() * 8) - 4) * (dist / self.mass));
				//head.punchangle_z = (((random() * 8) - 4) * (dist / self.mass));
				head.punchangle_x = (((random() * 10) - 5));
				head.punchangle_y = (((random() * 8) - 4));
				head.punchangle_z = (((random() * 8) - 4));
			}
			
			head = head.chain;
		}
		self.think = ShockShake;
		thinktime self : 0.1;
	}
	else
	{
		self.think = SUB_Remove;
		thinktime self : HX_FRAME_TIME;
	}
};

void (float radius, float duration, entity source)ShockWave =
{
	newmis = spawn();
	newmis.owner = self;
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_NONE;
	newmis.classname = "quake";
	newmis.mass = fabs ( radius);
	newmis.lifetime = duration;
	newmis.splash_time = (time + newmis.lifetime);
	setorigin ( newmis, source.origin);
	
	newmis.think = ShockShake;
	thinktime newmis : HX_FRAME_TIME;
};

void (float richter, entity source) MonsterQuake2 =
{
	newmis=spawn();
	newmis.owner=self;
	newmis.solid=SOLID_NOT;
	newmis.movetype=MOVETYPE_NONE;
	newmis.classname="quake";
	newmis.think=ShakeRattleAndRoll;
	newmis.nextthink=time;
	newmis.mass=fabs(richter);
	newmis.lifetime=time + 3;
	setorigin(newmis,source.origin);

//FIXME:  Replace explosion with some other quake-start sound
	sound(newmis,CHAN_AUTO,"weapons/explode.wav",1,ATTN_NORM);
	sound(newmis,CHAN_AUTO,"fx/quake.wav",1,ATTN_NORM);
};

void() smoke3d_think = {
	if (self.frame > 4) {
		self.frame = 1;
	} else {
		self.frame = self.frame + 1;
	}
	do_lightning ( self, 3, STREAM_ATTACHED, 1.00000, self.origin, self.origin + '0 0 100', 3.00000, TE_STREAM_LIGHTNING);
	self.think = smoke3d_think;
	thinktime self : 0.125000;
};

void(vector start) smoke3d_spawn = {
	newmis = spawn();
	setorigin(newmis, self.origin);
	setmodel(newmis, "models/ghail.mdl");
	newmis.solid = SOLID_NOT;
	newmis.movetype = MOVETYPE_FLYMISSILE;
	newmis.drawflags (+) (DRF_TRANSLUCENT | MLS_ABSLIGHT);
	newmis.abslight = 1;
	newmis.think = smoke3d_think;
	thinktime newmis : 0.20000;
};
