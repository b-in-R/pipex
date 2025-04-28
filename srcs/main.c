/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: binr <binr@student.42.fr>                  +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2025/04/28 16:35:03 by binr              #+#    #+#             */
/*   Updated: 2025/04/28 16:37:04 by binr             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "pipex.h"

int	main(int ac, char **av, char **envp)
{
	t_fd	fd;

	if (ac != 5)
	{
		ft_printf("Error\n2 files and 2 cmd needed\n");
		return (1);
	}
	open_files(av, &fd);
	if (pipe(fd.pipe) == -1)
		error_close_exit(&fd, "pipe", 0, NULL);
	forking(&fd, av, envp);
	return (0);
}
