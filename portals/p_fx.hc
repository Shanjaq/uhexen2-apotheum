
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
		drop.spelldamage = self.spelldamage;
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
		drop.skin = 1;

		// set drop duration
		setmodel (drop, "models/bloodspot.mdl");
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

void() liquid_fly = {
	if (self.cnt>0) {
		self.cnt -= 1;
		liquid_drop();
		thinktime self : 0.02;
		self.think = liquid_fly;
	} else {
		thinktime self : 0.02;
		self.think = SUB_Remove;
	}
};

void(float amount, float radius, float force) liquid_spray = {
	local entity missile;

	make_liquid_reset();
	missile = spawn();
	missile.spelldamage = self.spelldamage;
	missile.spellradiusmod = self.spellradiusmod;
	missile.ltime = time;
	missile.owner = self.owner;
	missile.cnt = amount;
	missile.exploderadius = radius;
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
	
	if (self.scale >= (1.35000*self.spellradiusmod) && !self.drawflags & DRF_TRANSLUCENT)
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
