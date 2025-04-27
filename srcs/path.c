#include "pipex.h"

char	*join_path(char *dir, char *cmd)
{
	size_t	len_dir;
	size_t	len_cmd;
	char	*full;

	len_dir = ft_strlen(dir);
	len_cmd = ft_strlen(cmd);
	full = ft_calloc(len_dir + len_cmd + 2, sizeof(char));
	if (!full)
		return (NULL);
	ft_strlcpy(full, dir, len_dir + 1);
	full[len_dir] = '/';
	ft_strlcpy(full + len_dir + 1, cmd, len_cmd + 1);
	return (full);
}

char	*path_finded(char **paths, char *cmd)
{
	char	*full_path;
	int		i;

	i = 0;
	while (paths[i])
	{
		full_path = join_path(paths[i], cmd);
		if (!full_path)
			return (NULL);
		if (access(full_path, X_OK) == 0)
		{
			return (full_path);
		}
		free(full_path);
		i++;
	}
	return (NULL);
}

char	**searching_path(char **envp)
{
	char	**paths;
	int		i;

	i = 0;
	while (envp[i])
	{
		if (ft_strncmp(envp[i], "PATH=", 5) == 0)
		{
			paths = ft_split(envp[i] + 5, ':');
			break;
		}
		i++;
	}
	return (paths);
}

char	*find_cmd_path(char *cmd, char **envp)
{
	char	**paths;
	char	*good_path;

	if (!cmd)
		return (NULL);
	if (ft_strchr(cmd, '/'))
	{
		if (access(cmd, X_OK) == 0)
			return (ft_strdup(cmd));
		else
			return (NULL);
	}
	paths = searching_path(envp);
	if (!paths)
		return (NULL);
	good_path = path_finded(paths, cmd);
	free_strs(paths);
	return (good_path);
}
