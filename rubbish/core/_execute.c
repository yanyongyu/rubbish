#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

int execute(char **parameters, int input, int output) {
  int status;
  pid_t pid = fork();
  if (pid == -1) {
    dprintf(output, "create fork failed\n");
  } else if (pid == 0) {
    dup2(input, 0);
    dup2(output, 1);
    int result = execvp(parameters[0], parameters);
    if (result < 0) {
      dprintf(output, "%s: command not found!\n", parameters[0]);
    }
    exit(errno);
  } else {
    wait(&status);
  }
  return status;
}
