void ()item_spawner2_think = {
	local entity found, oldself;
	
	if (self.goalentity.origin == world.origin)
	{
		self.lip = 0.00000;
		found = find ( world, classname, "player");
		while (found)
		{
			if ((found.classname == "player") && ((vlen(found.origin - self.origin) < 96.00000)))
				self.lip = 1.00000;
			
			found = find ( found, classname, "player");
		}
		
		if (self.lip == 0.00000)
		{
			newmis = spawn();
			setorigin(newmis, self.origin);
			self.goalentity = newmis;
			
			oldself = self;
			self = newmis;
			GenerateArtifactModel(oldself.model, oldself.netname, NO_RESPAWN);
			self = oldself;
			
			newmis.skin = self.skin;
			newmis.spawnflags = self.spawnflags;
		}
	}
	self.think = item_spawner2_think;
	thinktime self : 3.00000;
};


void(entity item) item_spawnify =
{
	local entity spawner;
	
	spawner = spawn();
	spawner.goalentity = item;
	setmodel(spawner, item.model);
	spawner.skin = item.skin;
	spawner.spawnflags = item.spawnflags;
	setorigin(spawner, item.origin);
	spawner.netname = item.netname;
	spawner.solid = SOLID_NOT;
	spawner.movetype = MOVETYPE_NONE;
	spawner.effects = EF_NODRAW;
	spawner.think = item_spawner2_think;
	thinktime spawner : 3.00000;
};

void() AlarmCheck =
{
	local float customers;
	local entity found;

	if ((self.target != "") && (self.goalentity == world))
	{
		found = find ( world, targetname, self.target);
		while (found)
		{
			if (self.goalentity == world)
			{
				self.goalentity = found;
			}
			
			found = find ( found, targetname, self.target);
		}
	}
	
	if (self.lip == 0.00000)
	{
		found = nextent(world);
		while (found)
		{
			if (found.touch == artifact_touch)
			{
				//dprint(found.classname);
				//dprint("\n");
				item_spawnify(found);
			}
			found = nextent(found);
		}
		
		self.lip = 1.00000;
	}
	
	customers = 0;
	found = find ( world, classname, "player");
	while (found)
	{
		if ((vlen(found.origin - self.origin) < self.delay) )
		{
			found.predebt = 1;
			if ((found.debt > 0) && (self.goalentity != world))
			{
				customers += 1;
			}
		}
		else
		{
			found.predebt = 0;
		}
		
		found = find ( found, classname, "player");
	}
	
	if (customers > 0)
	{
		if (self.goalentity.inactive != 0)
			self.goalentity.inactive = 0;
	}
	else if ((self.goalentity != world) && (self.goalentity.inactive != 1))
		self.goalentity.inactive = 1;
	
	thinktime self : 0.50000;
	self.think = AlarmCheck;

};

void() DropAlarm =
{
	self.think = AlarmCheck;
	thinktime self : 3.00000;
};
