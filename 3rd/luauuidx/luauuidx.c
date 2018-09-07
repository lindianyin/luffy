#include <lua.h>
#include <lauxlib.h>

#include <uuid/uuid.h>

int lua_uuid_generate_random(lua_State *L){
	uuid_t uuid;
	char out[256];
	uuid_generate_random(uuid);
	uuid_unparse(uuid,out);
	lua_pushstring(L,out);
	return 1;
}

int lua_uuid_generate_time(lua_State *L){
	uuid_t uuid;
	char out[256];
	uuid_generate_time(uuid);
	uuid_unparse(uuid,out);
	lua_pushstring(L,out);
	return 1;
}

static const luaL_Reg lib[] = {
    { "uuid_generate_random", lua_uuid_generate_random},
    { "uuid_generate_time", lua_uuid_generate_time},
    { NULL, NULL }
};


LUALIB_API int
luaopen_luauuidx(lua_State *L)
{
    luaL_register(L, "luauuidx", lib);
    return 1;
}
   
