#include "pipex.h"

void	close_fd(t_fd *fd)
{
	if (fd->in >= 0)
		close(fd->in);
	if (fd->out >= 0)
		close(fd->out);
	if (fd->pipe[0] >= 0)
		close(fd->pipe[0]);
	if (fd->pipe[1] >= 0)
		close(fd->pipe[1]);
}

void	free_strs(char **strs)
{
	int	i;

	i = 0;
	while (strs[i])
		free(strs[i++]);
	free(strs);
}

void	error_close_exit(t_fd *fd, char *str, int s_free, char **strs)
{
	ft_printf("Error - %s\n", str);
	if (s_free == 1)
	{
		free_strs(strs);
	}
	close_fd(fd);
	exit(1);
}
