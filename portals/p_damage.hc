float DFL_VIS = 1;
float DFL_NODEATH = 2;
float DFL_SKIP_WOOD = 4;
float DFL_SKIP_STONE = 8;
float DFL_SKIP_METAL = 16;

void() SUB_NullDeath =
{
	
	if (self.flags & FL_MONSTER)
	{
		MonsterDropStuff();
		self.th_missile = SUB_Null;
		self.th_melee = SUB_Null;
		self.oldthink = SUB_Null;
		self.th_pain = SUB_Null;
		self.th_run = SUB_Null;
		self.th_walk = SUB_Null;
		self.th_stand = SUB_Null;
	}
	else
		DropBackpack();
	
	SUB_UseTargets ( );
	
	if (self.th_die)
	{
		if (self.th_die != chunk_death)
			self.th_die();
	}
	
	self.think = SUB_Remove;
	thinktime self : HX_FRAME_TIME;
};

entity (entity inflictor, entity attacker, float damage, float radius, entity ignore, float dmgflags)T_RadiusDamageFlat = {
	local entity found, first, last;
	local float skip;
	local vector inflictor_org;
	
	inflictor_org = ((inflictor.absmin + inflictor.absmax) * 0.50000);
	
	found = findradius (inflictor_org, radius);
	first = world;
	last = world;

	while (found)
	{
		skip = 0;
		
		if ((found.takedamage == DAMAGE_YES) && (found != ignore) && (found != attacker))
		{
			if ((dmgflags & DFL_VIS) && ((!visible2ent(found, self) || found.solid == SOLID_BSP)))
				skip = 1;
			
			if ((dmgflags & DFL_SKIP_WOOD) && ((found.thingtype == THINGTYPE_WOOD_LEAF) || (found.thingtype == THINGTYPE_WOOD) || (found.thingtype == THINGTYPE_LEAVES) || (found.thingtype == THINGTYPE_HAY)))
				skip = 1;
			
			if ((dmgflags & DFL_SKIP_STONE) && ((found.thingtype == THINGTYPE_GREYSTONE) || (found.thingtype == THINGTYPE_BROWNSTONE) || (found.thingtype == THINGTYPE_CLAY)))
				skip = 1;
			
			if ((dmgflags & DFL_SKIP_METAL) && ((found.thingtype == THINGTYPE_METAL) || (found.thingtype == THINGTYPE_METAL_STONE)))
				skip = 1;
		}
		else
			skip = 1;
		
		if (skip == 0)
		{
			if ((!(dmgflags & DFL_NODEATH)) || (found.health > damage))
			{
				T_Damage ( found, inflictor, attacker, damage);
			}
			
			if (found.origin != VEC_ORIGIN)
			{
				if (first == world)
				{
					first = found;
				}
				else
				{
					if (last == world)
					{
						last = found;
						first.chain2 = last;
					}
					else
					{
						last.chain2 = found;
						last = found;
					}
				}
			}
		}
			
		found = found.chain;
	}
	
	if (last != world)
	{
		last.chain2 = world;
	}
	else
	{
		if (first != world)
		{
			first.chain2 = world;
		}
	}
	
	return first;
};


entity(vector pos, float radius, float notThingType, float withFlags2, float chooseRandom) findNearestHurtable =
{
	local entity found;
	local entity firstFound;
	local entity nearest;
	local float skip;
	local float entCount;
	
	local float dist1;
	local float dist2;
	
	firstFound = findradius (pos, radius);
	found = firstFound;
	while (found)
	{
		if (notThingType == 0)
		{
			skip = 0;
		} 
		else if (notThingType == 1)
		{
			if ((found.thingtype == THINGTYPE_GREYSTONE) || (found.thingtype == THINGTYPE_BROWNSTONE) || (found.thingtype == THINGTYPE_CLAY))
				skip = 1;
			else
				skip = 0;
		}
		else if (notThingType == 2)
		{
			if ((found.thingtype == THINGTYPE_WOOD_LEAF) || (found.thingtype == THINGTYPE_WOOD) || (found.thingtype == THINGTYPE_LEAVES) || (found.thingtype == THINGTYPE_HAY))
				skip = 1;
			else
				skip = 0;
		}
		
		if ((coop != 0) && (found.classname == "player"))
			skip = 1;
		
		if ((skip == 0) && (found.takedamage == DAMAGE_YES) && (found != self) && (found != self.owner) && (found.owner != self.owner) && (found != self.oldenemy) && (found != self.goalentity) && ((withFlags2 == 0) || (found.flags2 & withFlags2)))
		{
			if (!nearest)
			{
				nearest = found;
			}
			else
			{
				dist1 = vlen(found.origin - self.origin);
				dist2 = vlen(nearest.origin - self.origin);
				
				if (dist1 < dist2)
				{
					nearest = found;
				}
			}
			
			entCount += 1;
		}
		found = found.chain;
	}
	
	if (chooseRandom == TRUE)
	{
		entCount = rint(random(0, entCount));
		found = firstFound;
		while (found)
		{
			if (notThingType == 0)
			{
				skip = 0;
			} 
			else if (notThingType == 1)
			{
				if ((found.thingtype == THINGTYPE_GREYSTONE) || (found.thingtype == THINGTYPE_BROWNSTONE) || (found.thingtype == THINGTYPE_CLAY))
					skip = 1;
				else
					skip = 0;
			}
			
			if ((coop != 0) && (found.classname == "player"))
				skip = 1;
		
			if ((skip == 0) && (found.takedamage == DAMAGE_YES) && (found != self.owner) && (found != self.oldenemy) && (found != self.goalentity) && ((withFlags2 == 0) || (found.flags2 & withFlags2)))
			{
				if (!nearest)
				{
					nearest = found;
				}
				else
				{
					if (entCount == 0)
					{
						nearest = found;
					}
				}
				
				entCount -= 1;
			}
			found = found.chain;
		}
	}
	
	return nearest;
};
