#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>
#include <unistd.h>
#include <errno.h>

#include "mujs.h"

#include <fuzzer/FuzzedDataProvider.h>

inline void jsB_gc(js_State *J)
{
	int report = js_toboolean(J, 1);
	js_gc(J, report);
	js_pushundefined(J);
}

js_State *init(){
	js_State *J = js_newstate(NULL, NULL, 0);
	js_newcfunction(J, jsB_gc, "gc", 0);
	js_setglobal(J, "gc");
	return J;
}

// This takes input from stdin
extern "C" int LLVMFuzzerTestOneInput(const uint8_t *Data, size_t Size) {
	static js_State *J = init();

	FuzzedDataProvider DataProvider(Data, Size);
	std::string input = DataProvider.ConsumeRemainingBytesAsString();
	int status = js_dostring(J, input.c_str());
	return status;
}
