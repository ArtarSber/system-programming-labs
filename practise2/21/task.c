#include <pthread.h>
#include <stdio.h>
#include <unistd.h>

void* work(void* arg) {
    int id = *(int*)arg;
    for (int i = 1; i <= 5; i++) {
        printf("Thread %d: %d\n", id, i);
        sleep(1);
    }
    return NULL;
}

int main() {
    pthread_t threads[4];
    int ids[4] = {1,2,3,4};

    for (int i = 0; i < 4; i++)
        pthread_create(&threads[i], NULL, work, &ids[i]);

    for (int i = 0; i < 4; i++)
        pthread_join(threads[i], NULL);

    printf("Все потоки завершены\n");
    return 0;
}
