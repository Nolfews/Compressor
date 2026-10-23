##
## EPITECH PROJECT, 2025
## image_compressor
## File description:
## Makefile
##

.PHONY: all clean fclean cs re

NAME	=	imageCompressor

BIN_PATH	=	$(shell stack path --local-install-root)/bin

all:	$(NAME)

$(NAME):
	stack build
	cp $(BIN_PATH)/$(NAME) ./

clean:
	stack clean

fclean:	clean
	rm -rf .stack-work
	rm -f $(NAME)

cs: fclean
	coding-style . .
	cat coding-style-reports.log
	coding-style ./src .
	cat coding-style-reports.log
	coding-style ./app .
	cat coding-style-reports.log
	rm -rf coding-style-reports.log

re:	fclean all
