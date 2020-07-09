/*
 * $Header: /cvsroot/uhexen2/gamecode/hc/portals/rat.hc,v 1.2 2007-02-07 16:59:35 sezero Exp $
 */

// Scuttle
//$frame swalk1 swalk2 swalk3 swalk4 swalk5
//$frame swalk6 swalk7 swalk8 swalk9 swalk10
//$frame swalk11 swalk12 swalk13 swalk14 swalk15
//$frame swalk16

void() rat_wait;
void(float vol) rat_noise;
void rat_die_wait()
{
	if(self.health<-80)
	{
		chunk_death();
		return;
	}
	if(!self.velocity)
	{
		if(random()<0.5)
			self.angles_x=0;
		else
			self.angles_x=180;
		self.avelocity='0 0 0';
		MakeSolidCorpse();
		return;
	}
	else
	{
		self.think=rat_die_wait;
		thinktime self : 0.5;
	}
}

void rat_death (void)
{
	if(self.health<-80)
	{
		chunk_death();
		return;
	}

vector	bounce_vel;
	bounce_vel=normalize(self.origin-damage_attacker.origin);
	bounce_vel*=random(self.health*-30);
	self.velocity=bounce_vel;
	self.velocity_z=random(150,450);
	self.flags(-)FL_ONGROUND;
	self.movetype=MOVETYPE_BOUNCE;
	self.avelocity_x=random(self.health*10) - self.health;	
	self.avelocity_y=random(self.health*10) - self.health;	
	self.avelocity_z=random(self.health*10) - self.health;	
	self.think=rat_die_wait;
	thinktime self : 0;
}

void ratrun(void)
{
entity player;
float player_see_me;
	self.frame += 1;

	thinktime self : HX_FRAME_TIME;
	self.think = ratrun;

	AdvanceFrame(0,17);
	self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
//	dprint(ftos(self.ideal_yaw));
//	dprint("\n");
	ChangeYaw();

	if(pointcontents(self.origin+'0 0 7')!=CONTENT_EMPTY)
	{
		if(pointcontents(self.origin)==CONTENT_LAVA)
		{
//			dprint("lava death\n");
			chunk_death();
		}
		else
		{
			self.velocity_z=1;
			self.flags(+)FL_SWIM;
		}
	}
	else
		self.velocity_z=-1;

	if((random()<0.1||self.origin==self.oldorigin)&&self.pain_finished<time&&!self.flags&FL_SWIM)
	{
	vector ahead_org;
	float drop_content;
		makevectors(self.angles);
		ahead_org=self.origin+'0 0 7'+v_forward*10;
		traceline(ahead_org,ahead_org-'0 0 1000',FALSE,self);
		drop_content=pointcontents(trace_endpos);
		if(drop_content!=CONTENT_EMPTY&&drop_content!=CONTENT_SOLID)
		{
			self.pain_finished=time+3;
			thinktime self : 0.5;
			self.velocity=v_forward*200+'0 0 150';
			self.flags(-)FL_ONGROUND;
		}
	}

	if(random()<0.1&&random()<0.1)
		rat_noise ( random(0.20000,0.80000));

	if(self.goalentity.classname=="player")
	{
		if(vlen(self.goalentity.origin-self.origin)<36)
			self.think=rat_wait;
	}
	else
	{
		player=find(world,classname,"player");
		while(player)
		{
			if(random()<0.1&&random()<0.1&&random()<0.1&&random()<0.1&&random()<0.1&&!self.target)
			{
				self.goalentity=player;
				player_see_me=TRUE;
			}
			else if(visible2ent(self,player))
				player_see_me=TRUE;
			player=find(player,classname,"player");
		}
		if(!player_see_me&&time>self.lifetime)
		{
			if(self.goalentity.classname=="tempgoal")
				remove(self.goalentity);
			remove(self);
		}
		if(self.frags>=10)
		{
			self.frags=0;
			makevectors(self.angles);
			newmis=spawn();
			setorigin(newmis,v_forward*-1000+v_right*(random()*100 - 50));
			remove(self.goalentity);
			self.goalentity=newmis;
		}
	}
	if(!walkmove(self.angles_y,random(3,7),FALSE))
	{
//TEMP
		remove(self);
//		self.frags+=1;
	}
}

void rat_noise (float vol)
{
	sound(self,CHAN_VOICE,"misc/squeak.wav",vol,ATTN_NORM);
	self.pain_finished = (time + random(1.00000,12.00000));
}

void rat_touch (void)
{

}

//==========================================================================
//
// monster_ratnest
//
//==========================================================================

/*QUAKED monster_rat (1 0.3 0) (-3 -3 0) (3 3 7)
If the rat is targeted to a path, the rats will follow that path
------- key / value ----------------------------------
------- spawnflags -----------------------------------
AMBUSH
*/
void rat_make_goal (void)
{
vector goaldir;
	goaldir=self.angles;
	goaldir_y=self.ideal_yaw;
	makevectors(goaldir);
	newmis=spawn();
	newmis.effects=EF_NODRAW;
	setmodel(newmis,"models/null.spr");
	setorigin(newmis,self.origin+v_forward*1000);
	self.goalentity=newmis;
	newmis.classname="tempgoal";
	thinktime newmis : 30;
	newmis.think=SUB_Remove;
}

void rat_stupor (void)
{
	self.angles_y+=random(-2,2);
	self.frame=random(17);
	self.think=rat_wait;
	thinktime self : random(0.3,1.3);
}

void  (float dist)rat_move =  {
  if (self.frame >= 16)
	  self.frame = 0;
  else
	  self.frame += 2;
  
  movetogoal ( self.speed);
};

void  ()rat_think =  {
	local entity nearest;
	MonsterCheckContents ( );
	if (time > self.lifetime) {
		remove(self);
		return;
	}
	
	if ( self.goalentity != world ) {
		if (self.goalentity == self.controller)
		{
			self.dest = (self.goalentity.origin - self.origin);
			if (vlen(self.dest) <= 100.00000)
			{
				self.think = rat_wait;
				self.th_stand = rat_wait;
				self.th_walk = rat_wait; //shan
			}
			else
			{
				self.th_stand = rat_stupor;
				self.th_walk = rat_move;
				self.th_walk();
			}
			
			droptofloor ( );
			nearest = findNearestHurtable(self.origin, 500.00000, 0, FL_ALIVE, FALSE);
			if (nearest != world)
			{
				self.goalentity = nearest;
				self.enemy = nearest;
			}
		}
		else 
		{
			if (!(self.goalentity.flags2 & FL_ALIVE))
			{
				droptofloor ( );
				nearest = findNearestHurtable(self.origin, 500.00000, 0, FL_ALIVE, FALSE);
				if (nearest != world)
				{
					self.goalentity = nearest;
					self.enemy = nearest;
				}
				else
				{
					self.goalentity = self.controller;
					self.enemy = self.controller;
				}
			}
			
			self.dest = (self.goalentity.origin - self.origin);
			if (vlen(self.dest) <= 32.00000)
			{
				if (time > self.attack_finished)
				{
					if (random() < 0.5)
					{
						self.frame = random(17.00000);
						self.last_attack = time;
						self.attack_state = AS_MELEE;
						self.th_melee();
					}
					else
					{
						if ( !walkmove ( self.angles_y, 3.00000, FALSE) )
						{
							sheep_turn ( ); //shan borrowing this
						}
					}
				}
			}
			else
			{
				self.th_walk();//movetogoal (self.speed);
			}
		}
	} else {
		if (self.controller)
		{
			nearest = findNearestHurtable(self.origin, 512.00000, 0, FL_ALIVE, FALSE);
			if (nearest != world)
			{
				self.goalentity = nearest;
				self.enemy = nearest;
			}
			else
			{
				self.goalentity = self.controller;
				self.enemy = self.controller;
			}
			droptofloor ( );
		} else {
			self.th_walk();
		}
	}
	if ((self.controller.classname != "player") && (self.controller.enemy != world))
	{
		self.goalentity = self.controller.enemy;
		self.enemy = self.controller.enemy;
	}
	if ( (((random() < 0.10000) && (random() < 0.20000)) && (self.pain_finished < time)) ) {
		rat_noise ( random(0.20000,0.80000));
	}
	
	self.think = rat_think;
	thinktime self : HX_FRAME_TIME;
};

void rat_wait ()
{
	if (self.goalentity) {
		if ( (vlen ( (self.goalentity.origin - self.origin)) > 64.00000) ) {
			self.think = rat_think;
			self.th_stand = rat_stupor;
			self.th_walk = rat_move;
		}
	} else {
		self.think = rat_think;
		self.th_stand = rat_stupor;
		self.th_walk = rat_move;

	}
	
	thinktime self : 0.25000;
}

void rat_go (void)
{
	self.th_walk = rat_move;
	self.th_run = rat_move;
	self.think = rat_think;
	thinktime self : 0;
}

void monster_rat (void)
{
//FIXME: DAMN RAT JUMPS UP IN AIR AND GET STUCK IN EACH OTHER!!!!!!!!!!!
	if(!self.flags2&FL_SUMMONED)
	{
		precache_model("models/rat.mdl");
		precache_sound("misc/squeak.wav");
		self.th_stand = rat_stupor;
		self.th_walk = rat_stupor;
		self.lifetime = (time + random(5.00000,12.00000));
		self.use=rat_go;
	}
	else
	{
		self.th_stand = rat_stupor;
		self.th_walk = rat_move;
		self.lifetime = (time + random(14.00000, 18.00000));
		self.goalentity = self.controller;
		self.use = rat_go;
	}

	setmodel(self, "models/rat.mdl");

	self.movetype = MOVETYPE_STEP;
	self.solid = SOLID_SLIDEBOX;
	if(pointcontents(self.origin)!=CONTENT_EMPTY)
	{
		self.flags(+)FL_SWIM;
		self.angles_x=10;
	}

	self.touch=obj_push;
	self.flags(+)FL_PUSH;
	self.flags2(+)FL_ALIVE;
	self.classname="monster_rat";

	setsize(self, '-3 -3 0', '3 3 7');
	self.hull = HULL_POINT;
	self.health = 25;

	self.thingtype=THINGTYPE_FLESH;
	self.th_run = rat_move;
	self.th_melee = monster_sheep_bite;
	//self.th_missile = ratrun;
	self.th_pain = rat_noise;
	self.th_die = rat_death;
	self.think = rat_think;	

	self.flags(+)FL_MONSTER;
	self.yaw_speed = 10;
	self.speed = 6.00000;
	self.mass = 1.00000;
	self.mintel = 5.00000;

	/*
	if(!self.target)
	{
		self.ideal_yaw=random(360);
//		self.movetype=MOVETYPE_NOCLIP;
//		self.solid=SOLID_NOT;
		rat_make_goal();
	}
	*/
	thinktime self : 0.25000;
	walkmonster_start();
}

/*QUAKED monster_ratnest (1 0.3 0) (-20 -20 0) (20 20 10)
A group of 3 to 6 rats that flee when triggered
If the nest is targeted to a path, the rats will follow that path
------- key / value ----------------------------------
------- spawnflags -----------------------------------
AMBUSH
*/
void monster_ratnest(void)
{
	precache_model("models/rat.mdl");
	precache_sound("misc/squeak.wav");
	self.use=barrel_die;
}

