#include <fcntl.h>
#include <unistd.h>

int main() {
    int fd = open("nofile.txt", O_RDONLY);
    return 0;
}
