

NAME = pipex

CC = gcc
RM = rm -f
CFLAGS = -Wall -Wextra -Werror

LIBFT_DIR = libft
SRCS_DIR = srcs

SRCS = $(wildcard $(SRCS_DIR)/*.c)

OBJS = $(SRCS:.c=.o)

LIBFT_A = $(LIBFT_DIR)/libft.a

INCLUDES = -I$(LIBFT_DIR) -I$(SRCS_DIR) -I/usr/include

**SANITIZE_FLAGS = -fsanitize=address -g**

all: $(NAME)

$(NAME): $(OBJS) $(LIBFT_A)
	$(CC) $(CFLAGS) $(INCLUDES) $(OBJS) $(LIBFT_A) -o $(NAME)

$(SRCS_DIR)/%.o: $(SRCS_DIR)/%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c $< -o $@

$(LIBFT_A):
	make -C $(LIBFT_DIR)

clean:
	$(RM) $(OBJS)
	make -C $(LIBFT_DIR) clean

fclean: clean
	$(RM) $(NAME)
	make -C $(LIBFT_DIR) fclean

re:	fclean all

**fsan: CFLAGS += $(SANITIZE_FLAGS)
fsan: fclean $(NAME)

.PHONY: all clean fclean re **fsan**