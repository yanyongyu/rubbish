#include <limits.h>
#include <string.h>
#include <unistd.h>

char username[LOGIN_NAME_MAX] = "unknown";
char hostname[HOST_NAME_MAX] = "unknown";
char cwd[100] = "unknown";

const char* get_username(void) {
  if (getlogin_r(username, LOGIN_NAME_MAX) == -1) {
    strcpy(username, "unknown");
  }
  return username;
}
const char* get_hostname(void) {
  if (gethostname(hostname, HOST_NAME_MAX) == -1) {
    strcpy(hostname, "unknown");
  }
  return hostname;
}
const char* get_cwd(void) {
  if (!getcwd(cwd, sizeof(cwd))) {
    strcpy(cwd, "unknown");
  }
  return cwd;
}
const char* get_promptchar(void) {
  if (getuid() == 0) return "# ";
  return "$ ";
}
