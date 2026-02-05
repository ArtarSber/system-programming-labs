#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

// Глобальная переменная, которую будем увеличивать
int counter = 0;

// Мьютекс для синхронизации
pthread_mutex_t mutex;

// Функция, которую выполняет каждый поток
void* increment_counter(void* arg) {
    int thread_id = *(int*)arg;
    
    for (int i = 0; i < 1000; i++) {
        // Блокируем мьютекс перед доступом к общей переменной
        pthread_mutex_lock(&mutex);
        
        counter++;  // Теперь это атомарная операция
        
        // Разблокируем мьютекс
        pthread_mutex_unlock(&mutex);
    }
    
    printf("Поток %d завершил работу\n", thread_id);
    return NULL;
}

int main() {
    printf("=== Программа С мьютексом ===\n");
    printf("Создаем 5 потоков, каждый увеличивает counter 1000 раз\n");
    printf("Ожидаемое значение: 5000\n");
    printf("\n");
    
    // Инициализируем мьютекс
    pthread_mutex_init(&mutex, NULL);
    
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
    
    // Уничтожаем мьютекс
    pthread_mutex_destroy(&mutex);
    
    printf("\nИтоговое значение counter: %d\n", counter);
    
    if (counter == 5000) {
        printf("✓ Успех: counter = 5000\n");
        printf("  Мьютекс корректно защитил общую переменную\n");
    } else {
        printf("✗ Ошибка: counter = %d\n", counter);
    }
    
    return 0;
}
