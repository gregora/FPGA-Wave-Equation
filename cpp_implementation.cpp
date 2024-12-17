#include <iostream>
#include "SFML/Graphics.hpp"
#include <math.h>
#include <chrono>


void cell(int u, int du, int uL, int uR, int &u_new, int &du_new) {
    long int tmp; // 64 bit integer
    
    tmp = 4 * (uL + uR - 2*u) >> 8;
    if(tmp == -1){
        tmp = 0;
    }
    du_new = du + tmp;

    if(du_new == -1){
        //du_new = 0;
    }

    tmp = u + (du >> 8);
    tmp = (tmp * 2047) >> 11;
    u_new = tmp;


}


void update_cells(int* u, int* du, int N){

    // border cells
    u[0] = u[1];
    u[N-1] = u[N-2];

    for(int i = 1; i < N-1; i++) {
        cell(u[i], du[i], u[i-1], u[i+1], u[i], du[i]);
    }

}


void draw_cells(int* u, int N, sf::RenderWindow &window) {
    for(int i = 0; i < N; i++) {
        float height = u[i]/1000000;
        sf::RectangleShape rectangle(sf::Vector2f(50, 100 + height));
        rectangle.setPosition(50 + i*50, 400 - height);
        rectangle.setFillColor(sf::Color(255, 255, 255));
        window.draw(rectangle);
    }
}


void time_iters(int* u, int* du, int N, int iters) {
    for(int i = 0; i < iters; i++) {
        update_cells(u, du, N);
    }
}




int main() {

    int N = 20;
    int u[N];
    int du[N];


    for (int i = 0; i < N; i++) {
        if(i > 22 && i < 27) {
            u[i] = 200000000;
        } else {
            u[i] = 0;
        }
        du[i] = 0;
    }

    int iters = 1000000;
    auto start = std::chrono::high_resolution_clock::now();

    time_iters(u, du, N, iters);

    auto end = std::chrono::high_resolution_clock::now();

    std::chrono::duration<double> elapsed = end - start;

    printf("Time taken for %d iterations: %f\n", iters, elapsed.count());



    for (int i = 0; i < N; i++) {
        if(i > 10 && i < 15) {
            u[i] = 200000000;
        } else {
            u[i] = 0;
        }
        du[i] = 0;
    }

    // open sfml window

    sf::RenderWindow window(sf::VideoMode(1100, 600), "SFML window");

    int frame = 0;

    while (window.isOpen()) {
        window.clear();
        draw_cells(u, N, window);
        if(frame < 100){
            update_cells(u, du, N);
            
            if(frame == 99){
                for(int i = 0; i < 20; i++){
                    printf("%d\n", u[i]);
                }
            }
        }
        
        window.display();

       
        sf::sleep(sf::milliseconds(10));
        //printf("frame: %d, time: %f\n", frame, ((float) frame) / 255);
    
        sf::Event event;
        while (window.pollEvent(event)) {
            if (event.type == sf::Event::Closed) {
                window.close();
            }
        }
        frame = frame + 1;
    }




}