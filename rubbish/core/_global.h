#ifndef _RUBBISH_CORE_GLOBAL
#define _RUBBISH_CORE_GLOBAL

#include <stdio.h>

extern int is_interactive;
extern int command_end;

int get_interactive(void) {
  printf("Interactive %d\n", is_interactive);
  return is_interactive;
}
int get_command_end(void) {
  printf("Command end %d\n", command_end);
  return command_end;
}
void set_interactive(int i) {
  is_interactive = i;
  printf("Interactive %d\n", is_interactive);
}
void set_command_end(int i) {
  command_end = i;
  printf("Command end %d\n", command_end);
}

#endif
