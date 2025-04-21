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