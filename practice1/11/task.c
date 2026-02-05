#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>

int main() {
    int fd = open("numbers.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open numbers.txt");
        return 1;
    }

    char buf[16];
    int sum = 0;

    for (int i = 1; i <= 100; i++) {
        int len = snprintf(buf, sizeof(buf), "%d\n", i);
        write(fd, buf, len);
        sum += i;
    }
    close(fd);

    fd = open("sum.txt", O_CREAT | O_WRONLY | O_TRUNC, 0644);
    if (fd < 0) {
        perror("open sum.txt");
        return 1;
    }

    int len = snprintf(buf, sizeof(buf), "%d\n", sum);
    write(fd, buf, len);
    close(fd);

    return 0;
}