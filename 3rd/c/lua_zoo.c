#include <lua.h>
#include <lauxlib.h>
#include <lualib.h>

#include <stdio.h>
#include <stdlib.h>


static int lua_add(lua_State *L){
	int a = lua_tointeger(L,1);
	int b = lua_tointeger(L,2);
	lua_pushinterger(L,(a+b));
	return 1;
}

static luaL_Reg reg[] = {
	{ "add", lua_add},
	{ NULL, NULL }
};

int luaopen_zoo(lua_State *L){
	luaL_newlib(L,reg);
	return 1;
}


