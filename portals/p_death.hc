vector differencia;
vector difyaw;
.vector difpos;

.float deathset;

void() blackdeath_miss = {
	self.think = SUB_Remove;
	thinktime self : HX_FRAME_TIME;
	if (self.oldenemy != world)
	{
		self.oldenemy.think = SUB_Remove;
		thinktime self.oldenemy : HX_FRAME_TIME;
	}
	
	if ((self.catapulter != world) && (self.catapulter.teledrop_dest != world))
	{
		self.catapulter.teledrop_dest = world;
		self.catapulter.enemy = world;
		self = self.catapulter;
		if (self.catapulter.th_stand)
			self.catapulter.th_stand();
	}
	
};

void() blackdeath_fear_think =
{
	local vector dir;
	local entity oldself;
	
	if ((self.enemy != world) && (self.enemy.modelindex == self.lip))
	{
		dir = normalize(self.enemy.origin - self.owner.origin);
		setorigin(self, (((self.enemy.absmin + self.enemy.absmax) * 0.50000) + ((dir * 128) + randomv('-128 -128 -1', '128 128 1'))));
		particle2 ( (((self.enemy.absmin + self.enemy.absmax) * 0.50000) + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);
		
		if (random() < 0.1)
		{
			if (self.enemy.halted == 0)
			{
				if (self.enemy.classname == "player")
				{
					stuffcmd ( self.enemy, "df\n");
				}
				else
				{
					self.enemy.pain_finished = (time - 12.00000);
					self.enemy.attack_finished = time + 5.00000;
					self.enemy.last_attack = (time + 5);
					//self.enemy.attack_state == AS_MELEE;
					
					oldself = self;
					self = self.enemy;
					self.goalentity = oldself;
					self.enemy = oldself;
					if (random() < 0.75)
					{
						ai_turn();
						//self.th_walk();
						//ai_face ( );
						if (self.th_run)
							self.th_run();
						else
							self.th_walk;
					}
					else
					{
						//ai_turn();
						self.th_walk();
						self.th_pain (oldself, 9001);
						//self.th_walk();
						//ai_face ( );
						//self.th_run();
					}
					self = oldself;
				}
			}
		}
	}
	self.think = blackdeath_fear_think;
	thinktime self : 0.12500;
};


void() blackdeath_sink = {
	local entity oldself;
	if (self.deathset == 0) {
		self.deathset = 1;
		if ((self.catapulter != world) && (self.catapulter.modelindex == self.lip))
		{
			self.catapulter.drawflags (+) SCALE_TYPE_XYONLY;
			self.catapulter.solid = SOLID_NOT;
			self.effects = EF_DARKLIGHT;
			self.catapulter.movetype = MOVETYPE_NOCLIP;

			self.state = random(0, 3);
			if (self.state < 1)
				sound ( self.catapulter, CHAN_VOICE, "ambience/moan1.wav", 1.00000, ATTN_NORM);
			else if (self.state < 2)
				sound ( self.catapulter, CHAN_VOICE, "ambience/moan2.wav", 1.00000, ATTN_NORM);
			else if (self.state < 3)
				sound ( self.catapulter, CHAN_VOICE, "ambience/moan3.wav", 1.00000, ATTN_NORM);
		}
	}
	if (self.cnt < 36) {
		
		//if (self.cnt == 0)
		//{
		//	self.flags (+) FL_MONSTER;
		//	MonsterDropStuff();
		//}

		self.cnt += 1;
		if ((self.catapulter != world) && (self.catapulter.modelindex == self.lip))
		{
			self.catapulter.scale -= 0.02;
			setorigin(self, (self.catapulter.origin + '0 0 90'));
			setorigin(self.catapulter, (self.catapulter.origin - '0 0 3'));
			self.catapulter.velocity = '0 0 0';
		}
		else
			self.velocity_z -= 4;
		
		particle2 ( (self.origin + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);
		thinktime self : 0.05;
		self.think = blackdeath_sink;
	} else {
		setmodel(self, "models/null.spr");
		setsize(self, '0 0 0', '0 0 0');
		setorigin(self, self.origin + '0 0 84');
		self.flags (+) FL_MONSTER;
		oldself = self;
		newmis = spawn();
		newmis.flags (+) FL_MONSTER;
		newmis.monsterclass = self.monsterclass;
		setorigin(newmis, self.origin);
		newmis.solid = SOLID_TRIGGER;
		newmis.movetype = MOVETYPE_TOSS;
		self = newmis;
		MonsterDropStuff();
		self = oldself;
		
		if ((self.catapulter != world) && (self.catapulter.modelindex == self.lip))
		{
			if (self.catapulter.classname != "player") {
				remove(self.catapulter);
			//} else {
				//self.catapulter.health = 0;
				//self.catapulter.deadflag = TRUE;
			}
		}
		self.think = blackdeath_miss;
		thinktime self : HX_FRAME_TIME;
	}
};

void() blackdeath_lookdown = {
	local vector difpitch;
	if (self.deathset == 1) {
		self.deathset = 0;
		self.drawflags (-) DRF_TRANSLUCENT;
		self.catapulter.drawflags = (MLS_ABSLIGHT);
		self.catapulter.abslight = 1;
		spawn_tfog(self.origin);
	}
	
	if ((time < self.splash_time) && (self.catapulter != world) && (self.catapulter.modelindex == self.lip))
	{
		difpitch = (self.angles - (self.catapulter.angles - '90 0 0'));
		difpitch_x /= 24;
		difpitch_y /= 24;
		difpitch_z /= 24;

		differencia = (self.origin - (self.catapulter.origin + '0 0 90'));
		differencia_x /= 24;
		differencia_y /= 24;
		differencia_z /= 24;  
		
		//self.angles_x = (self.angles_x - 3);
		self.angles = (self.angles - difpitch);
		//self.catapulter.abslight = (self.catapulter.abslight - 0.04);
		//self.abslight = (self.self.abslight - 0.04);
		self.abslight = (1.00000 - ((self.splash_time - time) / self.lifetime));
		self.catapulter.abslight = ((self.splash_time - time) / self.lifetime);
		//setorigin(self.catapulter, self.catapulter.difpos);
		setorigin(self, (self.origin - differencia));
		/*
		if (random() < 0.5)
		{
			//shan lightning effect
			WriteByte ( MSG_BROADCAST, SVC_TEMPENTITY);
			WriteByte ( MSG_BROADCAST, TE_STREAM_FAMINE);
			WriteEntity ( MSG_BROADCAST, self.catapulter);
			//WriteByte ( MSG_BROADCAST, (6 + (STREAM_ATTACHED | STREAM_TRANSLUCENT)));
			WriteByte ( MSG_BROADCAST, (6 + (STREAM_ATTACHED | STREAM_TRANSLUCENT)));
			WriteByte ( MSG_BROADCAST, 0.50000);
			WriteCoord ( MSG_BROADCAST, (random(self.catapulter.absmin_x, self.catapulter.absmax_x)));
			WriteCoord ( MSG_BROADCAST, (random(self.catapulter.absmin_y, self.catapulter.absmax_y)));
			WriteCoord ( MSG_BROADCAST, (random(self.catapulter.absmin_z, self.catapulter.absmax_z)));
			WriteCoord ( MSG_BROADCAST, self.origin_x);
			WriteCoord ( MSG_BROADCAST, self.origin_y);
			WriteCoord ( MSG_BROADCAST, self.origin_z);
			//shan lightning effect end
		}
		*/
		//particle2 ( (self.origin + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);
		if (((self.splash_time - time) / self.lifetime) < 0.5)
			particle2 ( self.origin, '-10.00000 -10.00000 -10.00000', '10.00000 10.00000 -100.00000', random(64, 71), 0, 80.00000);
		
		thinktime self : 0.1;
		self.think = blackdeath_lookdown;
	} else {
		// thinktime self.catapulter : 0.1; 
		thinktime self : 0.1;
		self.think = blackdeath_sink;
	}
};

void() blackdeath_set = {
	local vector pos;

	if (self.deathset == 0) {
		
		newmis = spawn();
		newmis.flags2 (+) FL_ALIVE;
		newmis.owner = self.owner;
		newmis.solid = SOLID_NOT;
		newmis.movetype = MOVETYPE_NOCLIP;
		setorigin(newmis, ((self.catapulter.absmin + self.catapulter.absmax) * 0.50000));
		setmodel(newmis, "models/null.spr");
		//setmodel(newmis, "models/dwarf.mdl");
		newmis.lifetime = 12;
		newmis.splash_time = (time + newmis.lifetime);
		newmis.enemy = self.catapulter;
		newmis.lip = self.catapulter.modelindex;
		self.oldenemy = newmis;
		
		newmis.think = blackdeath_fear_think;
		thinktime newmis : HX_FRAME_TIME;
		

		//thinktime self.catapulter : 20; 
		self.velocity = '0 0 0';
		self.avelocity = '0 0 0';
		self.deathset = 1;
	}
	
	if (time < self.splash_time)
	{
		if ((self.catapulter != world) && (self.catapulter.modelindex == self.lip))
		{
			differencia = (self.origin - (self.catapulter.origin + '0 0 90'));
			difyaw = (self.angles - self.catapulter.angles);
			self.catapulter.difpos = self.catapulter.origin;
			
			difyaw_x /= 24;
			difyaw_y /= 24;
			difyaw_z /= 24;

			differencia_x /= 24;
			differencia_y /= 24;
			differencia_z /= 24;  
			
			setorigin(self, (self.origin - differencia));
			self.angles = (self.angles - difyaw);
			//setorigin(self.catapulter, self.catapulter.difpos);
			//particle2 ( (self.origin + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);

			if (random() < 0.3625)
			{
				pos = randomv(self.catapulter.absmin, self.catapulter.absmax);
				//shan lightning effect
				WriteByte ( MSG_BROADCAST, SVC_TEMPENTITY);
				WriteByte ( MSG_BROADCAST, TE_STREAM_FAMINE);
				WriteEntity ( MSG_BROADCAST, self.catapulter);
				//WriteByte ( MSG_BROADCAST, (6 + (STREAM_ATTACHED | STREAM_TRANSLUCENT)));
				WriteByte ( MSG_BROADCAST, (6 + (STREAM_ATTACHED | STREAM_TRANSLUCENT)));
				WriteByte ( MSG_BROADCAST, 0.50000);
				WriteCoord ( MSG_BROADCAST, pos_x);
				WriteCoord ( MSG_BROADCAST, pos_y);
				WriteCoord ( MSG_BROADCAST, pos_z);
				WriteCoord ( MSG_BROADCAST, self.origin_x);
				WriteCoord ( MSG_BROADCAST, self.origin_y);
				WriteCoord ( MSG_BROADCAST, self.origin_z);
				//shan lightning effect 
				T_Damage ( self.catapulter, self, self.owner, (self.spelldamage + random(self.spelldamage*(-0.12500), self.spelldamage*0.12500)));
				SpawnPuff ( pos, '360.00000 360.00000 360.00000', 3.00000, self.catapulter);
			}
			
			if (!(self.catapulter.flags2 & FL_ALIVE) && (self.catapulter.halted == 0))
			{
				self.catapulter.halted = 1;
				
				if (self.oldenemy != world)
				{
					self.oldenemy.think = SUB_Remove;
					thinktime self.oldenemy : HX_FRAME_TIME;
				}
				self.lifetime = 2.5;
				self.splash_time = (time + self.lifetime);
				
				self.think = blackdeath_lookdown;
				thinktime self : HX_FRAME_TIME;
			}
			else
			{
				thinktime self : 0.05;
				self.think = blackdeath_set;
			}
		}
		else
		{
			self.think = blackdeath_miss;
			thinktime self : HX_FRAME_TIME;
		}
	}
	else
	{
		thinktime self : 0.02;
		self.think = blackdeath_miss;
	}
};


void() blackdeath_swoop_think = {
	self.angles = vectoangles(self.velocity);


	local vector pull;
	local float  pull_speed;
	
	if ((self.catapulter != world) && (self.catapulter.modelindex == self.lip))
	{
		pull = self.origin - self.catapulter.origin;
		
		//TODO: change 400 to whatever maximum
		//speed you want. Actual speed is inversely proportional
		//to distance. At distace=radius, speed will be 0
		//			pull_speed = (1-vlen(pull)/grap);
		if ((vlen(self.catapulter.origin - self.origin) < 800) ) {
			pull_speed = 0.2;
		}
		if ((vlen(self.catapulter.origin - self.origin) < 500) ) {
			pull_speed = 0.5;
		}
		if ((vlen(self.catapulter.origin - self.origin) < 300) ) {
			pull_speed = 1;
		}

		normalize(pull);
		pull *= pull_speed;

		self.velocity -= pull;
		
		
		if ((vlen(self.catapulter.origin - self.origin) < 100) ) {
			thinktime self : 0.02;
			self.think = blackdeath_set;
		} else {
			self.catapulter.velocity = '0 0 0';
			//particle2 ( (self.origin + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);
			if (self.level_frags < 80) {
				self.level_frags += 1;
				thinktime self : 0.06;
				self.think = blackdeath_swoop_think;
			} else {
				thinktime self : 0.02;
				self.think = blackdeath_miss;
			}
		}
	}
	else
	{
		thinktime self : 0.02;
		self.think = blackdeath_miss;
	}

};

void() blackdeath_swoop = {
	local entity head;
	other = findNearestHurtable(self.origin, 128.00000, 0, FL_ALIVE, FALSE);
	if (other == world)
	{
		remove(self);
		return;
	}
	
	if ((other.model == "models/golem_s.mdl") || (other.model == "models/golem_i.mdl") || (other.model == "models/golem_b.mdl")) {
		centerprint(self.owner, "Death cannot claim inanimate objects!");
		remove(self);
		return;
	}
	if (other.model == "models/mummy.mdl") {
		centerprint(self.owner, "Death cannot claim the undead!");
		remove(self);
		return;
	}
	
	
	if (other.teledrop_dest == world)
	{
		head = spawn();
		head.spelldamage = self.spelldamage;
		head.solid = SOLID_NOT;
		head.movetype = MOVETYPE_NOCLIP;
		setmodel(head, "models/skull.mdl");
		head.drawflags (+) (DRF_TRANSLUCENT | MLS_ABSLIGHT);
		head.abslight = 0.5;
		head.scale = 2.5;
		setorigin(head, other.origin + randomv('-300 -300 -40', '300 300 0'));
		head.catapulter = other;
		head.monsterclass = head.catapulter.monsterclass;
		head.lip = other.modelindex;
		head.velocity = randomv('-20 -20 0', '20 20 300');
		head.lifetime = 12;
		head.splash_time = (time + head.lifetime);
		other.teledrop_dest = head;
		thinktime head : 0.5;
		head.think = blackdeath_swoop_think;
	}
	
};


//  particle2 ( (self.origin + randomv('-30 -30 -30', '30 30 30')), '-30.00000 -30.00000 50.00000', '30.00000 30.00000 100.00000', random(1, 6), 2, 80.00000);
