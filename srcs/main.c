#include "pipex.h"

int	main(int ac, char **av, char **envp)
{
	t_fd	fd;

	if (ac != 5)
	{
		ft_printf("Error\n2 files and 2 cmd needed\n");
		return (1);
	}
	open_files(av, &fd);// open files av[1] av[4] (fichiers)
	if (pipe(fd.pipe) == -1)
		error_close_exit(&fd, "pipe", 0, NULL);
	forking(&fd, av, envp);// fait les process child
	return (0);
}
