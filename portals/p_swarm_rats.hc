vector (entity targ, entity forent)find_random_spot;

void() swarm_spawn = {
	//find_entrance(self.origin);
	local entity first, noisemaker;
	local float r;
	//r = rint ( random(3.00000,6.00000));
	r = rint(4.00000 * self.spellradiusmod);
	
	noisemaker = spawn_temp();
	noisemaker.thingtype = THINGTYPE_BROWNSTONE;
	setsize(noisemaker, '-12 -12 0', '12 12 12');
	noisemaker.think = chunk_death;
	setorigin(noisemaker, self.origin);
	thinktime noisemaker : HX_FRAME_TIME;

	while ( (r > 0.00000) ) {
		newmis = spawn ( );
		newmis.spelldamage = self.spelldamage;
		newmis.spellradiusmod = self.spellradiusmod;
		newmis.controller = self.owner;
		newmis.owner = self.owner;
		newmis.angles_y = (self.angles_y + (60.00000));
		newmis.scale = (random(1.25000, 1.80000) * (newmis.spelldamage / (spell_damage[31])));
		newmis.flags2 (+) FL_SUMMONED;
		setsize ( newmis, '-3.00000 -3.00000 0.00000', '3.00000 3.00000 7.00000');		
		
		if (first == world)
		{
			first = newmis;
			setorigin(newmis, self.origin + '0 0 24');
		}
		else
		{
			newmis.dest = find_random_spot(first, first);
			setorigin(newmis, newmis.dest + '0 0 24');
		}
		sound ( noisemaker, CHAN_AUTO, "misc/hith2o.wav", 1.00000, ATTN_NORM);

		//makevectors ( newmis.angles);
		//setorigin ( newmis, (self.origin + randomv('-200 -200 0', '200 200 20')));
		newmis.think = monster_rat;
		thinktime newmis : HX_FRAME_TIME;
		r -= 1.00000;
	}
	
};

void() launch_swarm = {
	swarm_spawn();
};
