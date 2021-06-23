#include <unistd.h>
#include <wait.h>

int execute(char **parameters) {
  int result = 0;
  pid_t pid = fork();
  if (pid == -1) {
    printf("create fork failed\n");
  } else if (pid == 0) {
    result = execvp(parameters[0], parameters);
    if (result < 0) {
      printf("%s :command not found!\n", parameters[0]);
    }
  } else {
    wait(NULL);
  }
  free(parameters);
  return result;
}
