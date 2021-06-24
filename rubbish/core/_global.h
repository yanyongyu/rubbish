#ifndef _RUBBISH_CORE_GLOBAL
#define _RUBBISH_CORE_GLOBAL

extern int interactive;
extern int command_end;

int interactive = 0;
int command_end = 1;
void set_interactive(int i) { interactive = i; }

#endif
