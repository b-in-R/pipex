/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   pipex.h                                            :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: binr <binr@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/04/28 16:35:19 by binr              #+#    #+#             */
/*   Updated: 2025/04/28 16:39:20 by binr             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef PIPEX_H
# define PIPEX_H

# include "../libft/libft.h"

# include <unistd.h>
# include <stdlib.h>
# include <fcntl.h>
# include <sys/wait.h>
# include <string.h>
# include <errno.h>
# include <stdio.h>

typedef struct s_fd
{
	int	in;
	int	out;
	int	pipe[2];
}		t_fd;

// pipex.c
void	open_files(char **av, t_fd *fd);
void	forking(t_fd *fd, char **av, char **envp);

// path.c
char	*find_cmd_path(char *cmd, char **envp);

// utils.c
void	error_close_exit(t_fd *fd, char *str, int s_free, char **strs);
void	free_strs(char **strs);

#endif