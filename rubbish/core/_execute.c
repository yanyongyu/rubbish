#include <errno.h>
#include <string.h>
#include <unistd.h>
#include <wait.h>

int execute(char **parameters) {
  int status;
  pid_t pid = fork();
  if (pid == -1) {
    printf("create fork failed\n");
  } else if (pid == 0) {
    int result = execvp(parameters[0], parameters);
    if (result < 0) {
      printf("%s: command not found!\n", parameters[0]);
    }
    exit(errno);
  } else {
    wait(&status);
  }
  return status;
}
