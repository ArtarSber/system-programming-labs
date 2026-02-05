#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}========================================${NC}"
echo -e "${YELLOW}  Демонстрация: Мьютексы в pthread${NC}"
echo -e "${YELLOW}========================================${NC}"
echo ""

# Проверяем существование файлов
echo "Проверка наличия файлов..."
if [ ! -f "without_mutex.c" ]; then
    echo -e "${RED}Ошибка: Файл without_mutex.c не найден${NC}"
    exit 1
fi

if [ ! -f "with_mutex.c" ]; then
    echo -e "${RED}Ошибка: Файл with_mutex.c не найден${NC}"
    exit 1
fi

if [ ! -f "compare.c" ]; then
    echo -e "${YELLOW}Предупреждение: Файл compare.c не найден, создаем упрощенную версию${NC}"
    cat > compare_simple.c << 'COMPARE'
#include <stdio.h>
#include <pthread.h>
#include <unistd.h>

int counter_without = 0;
int counter_with = 0;
pthread_mutex_t mutex;

void* increment_without(void* arg) {
    for (int i = 0; i < 1000; i++) {
        counter_without++;
    }
    return NULL;
}

void* increment_with(void* arg) {
    for (int i = 0; i < 1000; i++) {
        pthread_mutex_lock(&mutex);
        counter_with++;
        pthread_mutex_unlock(&mutex);
    }
    return NULL;
}

int main() {
    pthread_t threads[5];
    
    printf("Сравнение БЕЗ и С мьютексом:\n\n");
    
    // Тест БЕЗ мьютекса
    printf("1. БЕЗ мьютекса:\n");
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, increment_without, NULL);
    }
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
    printf("   Результат: %d (должно быть 5000)\n", counter_without);
    
    // Тест С мьютексом
    printf("\n2. С мьютексом:\n");
    pthread_mutex_init(&mutex, NULL);
    counter_with = 0;
    
    for (int i = 0; i < 5; i++) {
        pthread_create(&threads[i], NULL, increment_with, NULL);
    }
    for (int i = 0; i < 5; i++) {
        pthread_join(threads[i], NULL);
    }
    pthread_mutex_destroy(&mutex);
    
    printf("   Результат: %d (должно быть 5000)\n", counter_with);
    
    printf("\n3. Вывод:\n");
    if (counter_without != 5000) {
        printf("   ✓ Обнаружен race condition без мьютекса\n");
    }
    if (counter_with == 5000) {
        printf("   ✓ Мьютекс защитил данные корректно\n");
    }
    
    return 0;
}
COMPARE
    COMPARE_FILE="compare_simple.c"
else
    COMPARE_FILE="compare.c"
fi

echo -e "${GREEN}✓ Все файлы готовы${NC}"
echo ""

# Компиляция
echo "Компиляция программ..."
echo "----------------------"

echo "1. Компилируем without_mutex.c..."
gcc -pthread -o without_mutex without_mutex.c
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ Успешно${NC}"
else
    echo -e "${RED}   ✗ Ошибка компиляции${NC}"
    exit 1
fi

echo ""
echo "2. Компилируем with_mutex.c..."
gcc -pthread -o with_mutex with_mutex.c
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ Успешно${NC}"
else
    echo -e "${RED}   ✗ Ошибка компиляции${NC}"
    exit 1
fi

echo ""
echo "3. Компилируем ${COMPARE_FILE}..."
gcc -pthread -o compare ${COMPARE_FILE}
if [ $? -eq 0 ]; then
    echo -e "${GREEN}   ✓ Успешно${NC}"
else
    echo -e "${YELLOW}   ⚠ Предупреждения, но программа скомпилирована${NC}"
fi

echo ""
echo -e "${GREEN}✓ Все программы скомпилированы${NC}"
echo ""

# Запуск демонстрации
echo "Запуск демонстрации..."
echo "======================"

echo ""
echo "1. ТЕСТ БЕЗ МЬЮТЕКСА (race condition)"
echo "--------------------------------------"
for i in {1..3}; do
    echo -n "   Попытка $i: "
    ./without_mutex 2>/dev/null | grep "Итоговое значение" | sed 's/Итоговое значение counter: //'
done

echo ""
echo "2. ТЕСТ С МЬЮТЕКСОМ"
echo "-------------------"
for i in {1..3}; do
    echo -n "   Попытка $i: "
    ./with_mutex 2>/dev/null | grep "Итоговое значение" | sed 's/Итоговое значение counter: //'
done

echo ""
echo "3. СРАВНИТЕЛЬНЫЙ ТЕСТ"
echo "---------------------"
./compare

echo ""
echo "4. ОБЪЯСНЕНИЕ"
echo "--------------"
echo ""
echo "Что происходит:"
echo "1. БЕЗ мьютекса: операция counter++ не атомарна"
echo "   - Чтение значения"
echo "   - Увеличение на 1"
echo "   - Запись значения"
echo "   - При параллельном выполнении некоторые инкременты теряются"
echo ""
echo "2. С мьютексом:"
echo "   pthread_mutex_lock(&mutex)   - блокировка"
echo "   counter++                    - безопасное увеличение"
echo "   pthread_mutex_unlock(&mutex) - разблокировка"
echo "   Результат всегда корректен"
echo ""
echo "Использованные функции pthread:"
echo "   • pthread_mutex_init()    - инициализация мьютекса"
echo "   • pthread_mutex_lock()    - блокировка мьютекса"
echo "   • pthread_mutex_unlock()  - разблокировка мьютекса"
echo "   • pthread_mutex_destroy() - уничтожение мьютекса"
echo ""

# Очистка (опционально)
echo "Очистка..."
read -p "Удалить скомпилированные программы? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    rm -f without_mutex with_mutex compare
    echo "Скомпилированные программы удалены"
fi

echo ""
echo -e "${GREEN}Демонстрация завершена!${NC}"
