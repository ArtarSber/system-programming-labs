#include <stdio.h>
#include <pthread.h>
#include <unistd.h>
#include <time.h>

// Глобальная переменная для теста БЕЗ мьютекса
int counter_without_mutex = 0;

// Глобальная переменная для теста С мьютексом
int counter_with_mutex = 0;

// Мьютекс для второго теста
pthread_mutex_t mutex;

// Функция для теста БЕЗ мьютекса
void* increment_without_mutex(void* arg) {
    for (int i = 0; i < 1000; i++) {
        counter_without_mutex++;  // НЕ синхронизировано
    }
    return NULL;
}

// Функция для теста С мьютексом
void* increment_with_mutex(void* arg) {
    for (int i = 0; i < 1000; i++) {
        pthread_mutex_lock(&mutex);
        counter_with_mutex++;  // Синхронизировано
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

// Функция для измерения времени выполнения
double run_test(void* (*func)(void*), const char* test_name) {
    pthread_t threads[5];
    clock_t start, end;
    
    printf("\nЗапуск теста: %s\n", test_name);
    
    start = clock();
    
    // Создаем 5 потоков
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, func, NULL);
    }
    
    // Ждем завершения всех потоков
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
    
    end = clock();
    
    return ((double)(end - start)) / CLOCKS_PER_SEC;
}

int main() {
    printf("===========================================\n");
    printf("   СРАВНЕНИЕ: БЕЗ мьютекса vs С мьютексом\n");
    printf("===========================================\n");
    
    // Тест 1: БЕЗ мьютекса
    printf("\n1. ТЕСТ БЕЗ МЬЮТЕКСА:\n");
    printf("   ------------------\n");
    
    // Сбрасываем счетчик
    counter_without_mutex = 0;
    
    double time_without_mutex = run_test(increment_without_mutex, "Без мьютекса");
    
    printf("   Результат: counter = %d\n", counter_without_mutex);
    printf("   Время выполнения: %.4f секунд\n", time_without_mutex);
    
    if (counter_without_mutex != 5000) {
        printf("   ✗ Race condition обнаружен!\n");
        printf("     Потеряно %d инкрементов\n", 5000 - counter_without_mutex);
    }
    
    // Тест 2: С мьютексом
    printf("\n2. ТЕСТ С МЬЮТЕКСОМ:\n");
    printf("   -----------------\n");
    
    // Инициализируем мьютекс
    pthread_mutex_init(&mutex, NULL);
    
    // Сбрасываем счетчик
    counter_with_mutex = 0;
    
    double time_with_mutex = run_test(increment_with_mutex, "С мьютексом");
    
    printf("   Результат: counter = %d\n", counter_with_mutex);
    printf("   Время выполнения: %.4f секунд\n", time_with_mutex);
    
    if (counter_with_mutex == 5000) {
        printf("   ✓ Мьютекс успешно защитил общую переменную\n");
    }
    
    // Уничтожаем мьютекс
    pthread_mutex_destroy(&mutex);
    
    // Сравнение
    printf("\n3. ИТОГИ СРАВНЕНИЯ:\n");
    printf("   ---------------\n");
    printf("   Без мьютекса: %d (должно быть 5000)\n", counter_without_mutex);
    printf("   С мьютексом:  %d (должно быть 5000)\n", counter_with_mutex);
    printf("   Разница во времени: %.4f секунд\n", time_with_mutex - time_without_mutex);
    
    return 0;
}
