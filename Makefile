all: prog

prog:
	raku -Ilib examples/why-linux/generate.raku # produces new why-linux.pdf
	@echo 'See ./why-linux.pdf'
