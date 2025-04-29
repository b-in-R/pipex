/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   utils.c                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: rabiner <rabiner@student.42.fr>            +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/04/28 16:35:25 by binr              #+#    #+#             */
/*   Updated: 2025/04/29 15:48:13 by rabiner          ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

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
	dup2(2, STDOUT_FILENO);
	ft_printf("Error - %s\n", str);
	if (s_free == 1)
	{
		free_strs(strs);
	}
	close_fd(fd);
	exit(1);
}
