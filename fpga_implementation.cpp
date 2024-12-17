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

int32_t convertUnsignedCharsToSignedInt(const unsigned char* buffer) {
    // Assuming little-endian format
    int32_t result = (static_cast<int32_t>(buffer[0])      ) |
                     (static_cast<int32_t>(buffer[1]) << 8 ) |
                     (static_cast<int32_t>(buffer[2]) << 16) |
                     (static_cast<int32_t>(buffer[3]) << 24);
    
    return result;
}


void find_start(char* buffer){

    int start = 0;

    for(int i = 0; i < 20*4; i++){
        if(buffer[i] == 1 && buffer[i + 1] == 1 && buffer[i + 2] == 1 && buffer[i + 3] == 1){
            start = i;
            break;
        }
    }

    char buffer2[20*4 + 4];

    memcpy(buffer2, buffer + start, 20*4 + 4 - start);
    memcpy(buffer2 + 20*4 + 4 - start, buffer, start);
    memcpy(buffer, buffer2, 20*4 + 4);

}

int main(){
    
    int N = 20;

    int u[N];

    configureSerialPort(0, B115200);

    int fd = openSerialPort("/dev/ttyUSB1");

    if (fd < 0) {
        cout << "Error opening serial port" << std::endl;
        return 1;
    }

    // read data from serial port

    char buffer[20*4 + 4];


    int n = readFromSerialPort(fd, buffer, sizeof(buffer));

    if (n < 0) {
        cerr << "Error reading: " << strerror(errno) << endl;
        return 1;
    }


    closeSerialPort(fd);

    find_start(buffer);

    for(int i = 0; i < sizeof(buffer); i++){
        //printf("%d\n", (unsigned char) buffer[i]);
    }

    for(int i = 1; i < N + 1; i++) {

        unsigned char byte1 = buffer[i*4];
        unsigned char byte2 = buffer[i*4 + 1];
        unsigned char byte3 = buffer[i*4 + 2];
        unsigned char byte4 = buffer[i*4 + 3];

        // convert four bytes to a single integer
        u[i] = (byte1 << 0) | (byte2 << 8) | (byte3 << 16) | (byte4 << 24);

        cout << u[i] << endl;
    }
    return 0;

    
}