// Usage: 
//   if(rec->caller_version != REAPER_PLUGIN_VERSION || !loadAPI(rec->GetFunc))
//     return 0;
// See also (bare-bone REAPER extension):
//   https://gist.github.com/cfillion/f32b04e75e84e03cc463abb1eda41400

#define REQUIRED_API(name) {(void **)&name, #name, true}
#define OPTIONAL_API(name) {(void **)&name, #name, false}

static bool loadAPI(void *(*getFunc)(const char *))
{
  if(!getFunc)
    return false;

  struct ApiFunc { void **ptr; const char *name; bool required; };

  const ApiFunc funcs[] {
    REQUIRED_API(ShowConsoleMsg),
  };

  for(const ApiFunc &func : funcs) {
    *func.ptr = getFunc(func.name);

    if(func.required && !*func.ptr) {
      fprintf(stderr, "[reaper_barebone] Unable to import the following API function: %s\n", func.name);
      return false;
    }
  }

  return true;
}