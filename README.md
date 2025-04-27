# pipex

21.04		

va_list: (voir printf)

//appel: ft_machin("texte", arg1, arg2);

void	ft_machin(const char *format, ...)
{
	va_list	ap;

	va_start(ap, format);

	...

	va_end(ap);
	return ;
}

25.04

	va_list NOPE

	appel: 		./pipex infile "cmd1" "cmd2" outfile

	exemple:	./pipex infile "grep a1" "wc -w" outfile
								=
				< infile grep a1 | wc -w > outfile 
				(met dans OUT le nbr de mots de toutes les lignes ou 'a1' est present dans IN)

26.04

	pipex tester: voir problemes (bash run.sh) et lister

27.04

	ajoute pipex tester au git: modif droits "infile without permission"
	