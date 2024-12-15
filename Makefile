all: cpp_implementation.cpp fpga_implementation.cpp
	g++ cpp_implementation.cpp -o cpp_implementation.out -lsfml-graphics -lsfml-window -lsfml-system
	g++ fpga_implementation.cpp -o fpga_implementation.out -lsfml-graphics -lsfml-window -lsfml-system
upload:
	openFPGALoader -b tangnano9k -m fpga_project/impl/pnr/fpga_project.fs