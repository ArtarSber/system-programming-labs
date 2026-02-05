#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

// Глобальная переменная, которую будем увеличивать
int counter = 0;

// Функция, которую выполняет каждый поток
void* increment_counter(void* arg) {
    int thread_id = *(int*)arg;
    
    for (int i = 0; i < 1000; i++) {
        counter++;  // НЕ синхронизированное увеличение
    }
    
    printf("Поток %d завершил работу\n", thread_id);
    return NULL;
}

int main() {
    printf("=== Программа БЕЗ мьютекса ===\n");
    printf("Создаем 5 потоков, каждый увеличивает counter 1000 раз\n");
    printf("Ожидаемое значение: 5000\n");
    printf("\n");
    
    pthread_t threads[5];
    int thread_ids[5] = {1, 2, 3, 4, 5};
    
    // Создаем 5 потоков
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, increment_counter, &thread_ids[i]);
    }
    
    // Ждем завершения всех потоков
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
    
    printf("\nИтоговое значение counter: %d\n", counter);
    
    if (counter == 5000) {
        printf("✓ Успех: counter = 5000 (редкая удача без синхронизации!)\n");
    } else {
        printf("✗ Race condition! counter = %d (должно быть 5000)\n", counter);
        printf("  Потеряно %d инкрементов\n", 5000 - counter);
    }
    
    return 0;
}
