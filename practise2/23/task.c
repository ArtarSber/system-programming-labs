#include <signal.h>
#include <unistd.h>

volatile sig_atomic_t running = 1;

void handler(int sig) {
    write(1, "Caught SIGINT\n", 14);
    running = 0;
}

int main() {
    signal(SIGINT, handler);

    while (running) {
        write(1, "Working...\n", 11);
        sleep(1);
    }
    return 0;
}
