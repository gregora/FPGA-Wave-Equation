#include <cstring>
#include <errno.h>
#include <fcntl.h>
#include <iostream>
#include <termios.h>
#include <unistd.h>
using namespace std;

int openSerialPort(const char* portname)
{
    int fd = open(portname, O_RDWR | O_NOCTTY | O_SYNC);
    if (fd < 0) {
        cerr << "Error opening " << portname << ": "
             << strerror(errno) << endl;
        return -1;
    }
    return fd;
}

// Function to configure the serial port
bool configureSerialPort(int fd, int speed)
{
    struct termios tty;
    if (tcgetattr(fd, &tty) != 0) {
        cerr << "Error from tcgetattr: " << strerror(errno)
             << endl;
        return false;
    }

    cfsetospeed(&tty, speed);
    cfsetispeed(&tty, speed);

    tty.c_cflag
        = (tty.c_cflag & ~CSIZE) | CS8; // 8-bit characters
    tty.c_iflag &= ~IGNBRK; // disable break processing
    tty.c_lflag = 0; // no signaling chars, no echo, no
                     // canonical processing
    tty.c_oflag = 0; // no remapping, no delays
    tty.c_cc[VMIN] = 0; // read doesn't block
    tty.c_cc[VTIME] = 5; // 0.5 seconds read timeout

    tty.c_iflag &= ~(IXON | IXOFF
                     | IXANY); // shut off xon/xoff ctrl

    tty.c_cflag
        |= (CLOCAL | CREAD); // ignore modem controls,
                             // enable reading
    tty.c_cflag &= ~(PARENB | PARODD); // shut off parity
    tty.c_cflag &= ~CSTOPB; // one stop bit
    tty.c_cflag &= ~CRTSCTS; // no hardware flowcontrol

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        cerr << "Error from tcsetattr: " << strerror(errno)
             << endl;
        return false;
    }
    return true;
}

// Function to read data from the serial port
int readFromSerialPort(int fd, char* buffer, size_t size)
{
    return read(fd, buffer, size);
}

void closeSerialPort(int fd) { close(fd); }

int main(){
    
    int N = 100;

    int u[N];

    configureSerialPort(0, B115200);

    int fd = openSerialPort("/dev/ttyUSB1");

    if (fd < 0) {
        cout << "Error opening serial port" << std::endl;
        return 1;
    }

    // read data from serial port

    char buffer[100*32];

    int n = readFromSerialPort(fd, buffer, sizeof(buffer));

    if (n < 0) {
        cerr << "Error reading: " << strerror(errno) << endl;
        return 1;
    }


    closeSerialPort(fd);


    for(int i = 0; i < N*4; i++) {
        //cout << (int)buffer[i] << endl;
    }

    for(int i = 0; i < N; i++) {
        // convert four bytes to an integer
        u[i] = (buffer[4*i] << 24) | (buffer[4*i+1] << 16) | (buffer[4*i+2] << 8) | buffer[4*i+3];
        cout << u[i] << endl;
    }
    return 0;

    
}