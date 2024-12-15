# FPGA Wave Equation

This is a project, where I try to implement wave equation numerical solution on an FPGA.

## The problem

Wave equation is a simple partial differential equation that governs how waves move through a medium.

One dimensional equation reads:

$$
\frac{\partial^2 u}{\partial t^2} = c^2 \left( \frac{\partial^2 u}{\partial x^2} \right)
$$

Here, $u$ denotes the amplitude of the medium at certain height, for example a height of a wave.

The equation can be (approximately) solved numerically as follows:

$$
du(k+1) = du(k) + dt \cdot \frac{uL(k) + uR(k) - 2 u(k)}{dx^2}
$$

$$
u(k+1) = \alpha \left( u(k) + dt \cdot du(k) \right)
$$

Here $\alpha$ represents a coefficient < 1, that represents energy losses and thus increases stability.

## Computation

As computation is relatively simple, I decided to implement the algorithm both in C++ and on FPGA.

The medium is sliced into 100 finite pieces, governed by the equations above.

I was interested into how the FPGA performed against a CPU, especially since my FPGA was pretty small, only having 9 thousand logic units.

The goal of the project was both to validate the results computed on the FPGA and compare the computation speed to the C++ implementation.

## C++ implementation
### Compilation
The project can be compiled using `make`. Simply run `make` in the root directory.

## FPGA implementation
### Upload
To upload the necessary files onto the Tang Nano 9k FPGA, simply run `make upload` or `openFPGALoader -b tangnano9k -m fpga_project/impl/pnr/fpga_project.fs`.