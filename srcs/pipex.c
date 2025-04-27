#include "pipex.h"

void	finish(t_fd *fd, pid_t pid1, pid_t pid2)
{
	close(fd->pipe[0]);
	close(fd->pipe[1]);
	close(fd->in);
	close(fd->out);
	waitpid(pid1, NULL, 0);
	waitpid(pid2, NULL, 0);
}

void	execute_cmd(char *cmd, char **envp, t_fd *fd)
{
	char	**args;
	char	*cmd_path;

	args = ft_split(cmd, ' ');
	if (!args)
		error_close_exit(fd, "execute_cmd -> args", 0, NULL);
	cmd_path = find_cmd_path(args[0], envp);
	if (!cmd_path)
		error_close_exit(fd, "cmd_path", 1, args);
	if (execve(cmd_path, args, envp) == -1)
	{
		free(cmd_path);
		error_close_exit(fd, "execve failed", 1, args);
	}
}

void	forking(t_fd *fd, char **av, char **envp)
{
	pid_t	pid1;
	pid_t	pid2;

	pid1 = fork();// fils 1 : cmd1
	if (pid1 == 0)
	{
		dup2(fd->in, 0);
		dup2(fd->pipe[1], 1);
		close(fd->pipe[0]);
		close(fd->in);
		close(fd->out);
		execute_cmd(av[2], envp, fd);
	}
	pid2 = fork();// fils 2 : cmd2
	if (pid2 == 0)
	{
		dup2(fd->pipe[0], 0);
		dup2(fd->out, 1);
		close(fd->pipe[1]);
		close(fd->in);
		close(fd->out);
		execute_cmd(av[3], envp, fd);
	}
	finish(fd, pid1, pid2);
}

void	open_files(char **av, t_fd *fd)
{
	fd->in = open(av[1], O_RDONLY);
	if (fd->in < 0)
		error_close_exit(fd, "open_files fd.in", 0, NULL);
	fd->out = open(av[4], O_WRONLY | O_CREAT | O_TRUNC, 0644);// a voir detail
	if (fd->out < 0)
		error_close_exit(fd, "open files fd.out", 0, NULL);
}
