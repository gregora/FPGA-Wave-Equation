all: cpp_implementation.cpp
	g++ cpp_implementation.cpp -o cpp_implementation.out -lsfml-graphics -lsfml-window -lsfml-system