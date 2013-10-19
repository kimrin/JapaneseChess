#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "Shogi.h"

extern "C" int setunbuffering(void)
{
  setvbuf(stdout, NULL, _IONBF, 0);
  setvbuf(stdin, NULL, _IONBF, 0);

  return 0;
}

extern "C" struct _IO_FILE *get_stdout(void)
{
  return stdout;
}

extern "C" struct _IO_FILE *get_stdin(void)
{
  return stdin;
}

int main(int ac, char *av[])
{
  return system("../Julia/Main.jl");
}
