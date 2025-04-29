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

28.04

42_pipex_tester:

	TESTNAME
    OUT     EXIT    TIME    LEAKS   

BASIC CHECKS
# 7: "infiles/basic.txt" "cat -e" "grep nonexistingword" "outfiles/nonexistingfile"  
   OK     [KO]     OK      OK

ERROR CHECKING
#11: "nonexistingfile" "cat -e" "ls" "outfiles/outfile"
    [KO]    [KO]     OK     [KO]    
#12: "nonexistingfile" "cat" "sleep 3" "outfiles/outfile" 
    [KO]    [KO]    [KO]    [KO]    
#13: "infiles/infile_without_permissions" "cat -e" "cat -e" "outfiles/outfile"
    [KO]    [KO]     OK     [KO]    
#14: "infiles/basic.txt" "cat -e" "cat -e" "outfiles/outfile_without_permissions" 
     OK      OK      OK     [KO]    
#15: "infiles/basic.txt" "sleep 3" "cat -e" "outfiles/outfile_without_permissions"
     OK      OK     [KO]    [KO]    
#16: "nonexistingfile" "cat -e" "cat -e" "outfiles/outfile_without_permissions"
     OK      OK      OK     [KO]    
#17: "infiles/basic.txt" "nonexistingcommand" "cat -e" "outfiles/outfile"
    [KO]     OK      OK      OK     
#18: "infiles/basic.txt" "cat -e" "nonexistingcommand" "outfiles/outfile"
    [KO]    [KO]     OK      OK    
#19: "infiles/basic.txt" "cat -e" "cat -nonexistingflag" "outfiles/outfile"
     OK     [KO]     OK      OK    
#23: "" "cat -e" "cat -e" "outfiles/outfile"
                            [KO]    




29.04	CORR:

	commandes a traiter:

		./pipex in cat "grep 'ca va'" out --> simples guillemets ' '
		
		./pipex in cat "awk '{print \$2}'" out --> ? simples guilemets?
			< in cat | awk '{print $2}' >  out
				(met dans out 2eme col de chaque ligne)

		
		unset PATH	--> si PATH pas trouve, erreur (cmd not found)

	voir details: 

		dup2(2, STDOUT_FILENO); (utils.c)