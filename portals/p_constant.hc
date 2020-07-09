float STATUS_BURNING = 1;
float STATUS_POISON = 2;
float STATUS_WET = 4;
float STATUS_TOXIC = 8;
float STATUS_PARALYZE = 16;

float TE_LIGHT_PULSE   =  33.00000;

float MAX_LIQUID_COUNT = 64.00000;
float LIQUID_TYPE_BLOOD = 0;
float LIQUID_TYPE_LAVA = 1;
float LIQUID_TYPE_SLIME = 2;

float item_value[21] = { 0,
	10, 15, 60,
	50, 40, 55,
	60, 35, 25,
	25, 10, 40,
	80, 50, 99,
	1500, 1500, 1500,
	1500, 1500
};

float cast_time[37] = { 0,
	1.5, 2, 3, 4, 5, 7,
	1.2, 2, 2.5, 5, 5, 7,
	2, 2, 2.5, 1.5, 5, 7,
	2, 2, 2.5, 3, 5, 7,
	2, 2, 2.5, 4, 5, 7,
	5, 2.5, 4, 5, 5, 7
};
float spell_support[37] = { 31,
	27, 4, 1, 31, 31, 29,
	23, 23, 31, 29, 31, 31,
	31, 31, 23, 31, 31, 29,
	5, 31, 29, 1, 12, 29,
	5, 31, 19, 31, 29, 21,
	29, 23, 29, 31, 31, 25
};
float spell_cost[37] = { 0,
	7, 5, 10, 20, 30, 40,
	4, 5, 10, 15, 25, 40,
	4, 8, 10, 6, 16, 35,
	2, 10, 15, 20, 30, 35,
	1, 5, 7, 15, 25, 35,
	10, 15, 20, 25, 30, 40
};
float spell_damage[37] = { 0,
	0, 0, 0, 60, 22, 16,
	1.8, 26, 28, 28, 30, 38,
	12, 14, 12, 21, 32, 40,
	4, 10, 128, 3, 2.5, 35,
	2, 8, 7, 26, 32, 8,
	7, 2, 20, 8, 30, 40
};
float spell_price[36] = {
	200, 250, 350, 400, 500, 725,
	150, 300, 350, 450, 550, 700,
	250, 300, 350, 375, 400, 650,
	300, 350, 400, 425, 550, 650,
	200, 250, 320, 450, 500, 600,
	300, 350, 400, 450, 580, 725
};
float spell_type[37] = { 0,
	4, 0, 0, 1, 2, 2,
	0, 0, 3, 2, 2, 2,
	0, 3, 3, 0, 2, 2,
	0, 4, 1, 0, 0, 2,
	0, 3, 1, 2, 2, 2,
	4, 1, 2, 2, 2, 2
};
float magic_affinity[30] = {
	1.35, 0.65, 1.00, 1.00, 1.35, 0.65,
	1.00, 0.65, 1.35, 1.35, 1.00, 0.65,
	0.65, 1.35, 1.00, 1.00, 0.65, 1.35,
	0.65, 1.00, 1.35, 0.65, 1.35, 1.00,
	1.00, 1.00, 1.00, 1.00, 1.00, 1.00
};
float SPELL_TYPE_NULL = 0;
float SPELL_TYPE_PROJ = 1;
float SPELL_TYPE_PROJ_SLOW = 2;
float SPELL_TYPE_PROJ_CUSTOM = 3;
float SPELL_TYPE_TRACE = 4;

float SUPPORT_CASTSPEED = 1.00000;
float SUPPORT_MULTI = 2.00000;
float SUPPORT_DAMAGE = 4.00000;
float SUPPORT_RADIUS = 8.00000;
float SUPPORT_TRAP = 16.00000;

float ARTIFACT_SPELL_ACCELERATOR   =  16.00000;
float ARTIFACT_SPELL_PRISM   =  17.00000;
float ARTIFACT_SPELL_AMPLIFIER   =  18.00000;
float ARTIFACT_SPELL_MAGNIFIER   =  19.00000;
float ARTIFACT_SPELL_TRAP   =  20.00000;


float PARTICLETYPE_BLOB			= 7;
float PARTICLETYPE_BLOB2		= 8;
float PARTICLETYPE_EXPLODE            = 5;
float PARTICLETYPE_C_EXPLODE2   =  11.00000;
float PARTICLETYPE_ICE   =  14.00000;

float HX_FPS   =  20.00000;

float ONWALL_ALIAS   =  32.00000;

float XF_TORCH_GLOW = 1.00000;
float XF_GLOW = 2.00000;
float XF_MISSILE_GLOW = 4.00000;
float XF_COLOR_LIGHT = 8.00000;
