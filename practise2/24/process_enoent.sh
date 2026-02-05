#!/bin/bash

echo "=== Задание: Анализ ошибки ENOENT с strace ==="
echo ""

# 1. Создаем исходный код программы
echo "1. Создаем программу, которая пытается открыть несуществующий файл..."
cat > task.c << 'CODE'
#include <fcntl.h>
#include <unistd.h>

int main() {
    int fd = open("nofile.txt", O_RDONLY);
    return 0;
}
CODE
echo "   Файл task.c создан"

# 2. Компилируем программу
echo "2. Компилируем программу..."
gcc -o task task.c
echo "   Программа скомпилирована (task)"

# 3. Удаляем файл, если он существует
echo "3. Убеждаемся, что файл nofile.txt не существует..."
rm -f nofile.txt

# 4. Запускаем strace и сохраняем результат
echo "4. Запускаем strace для анализа системных вызовов..."
strace ./task 2>&1 | grep -E "open.*nofile|ENOENT" > analysis.txt

# 5. Показываем результат
echo ""
echo "5. Результат анализа (analysis.txt):"
echo "====================================="
cat analysis.txt
echo "====================================="

# 6. Анализируем результат
echo ""
echo "6. Анализ ошибки:"
if grep -q "ENOENT" analysis.txt; then
    echo "   ✓ Найдена ошибка ENOENT (No such file or directory)"
    echo "   ✓ Файл 'nofile.txt' действительно не существует"
else
    echo "   ✗ Ошибка ENOENT не найдена"
fi

# 7. Создаем исправленную версию программы
echo ""
echo "7. Создаем исправленную версию программы..."
cat > task_fixed.c << 'CODE'
#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <errno.h>
#include <string.h>

int main() {
    printf("Попытка открыть файл 'nofile.txt'...\n");
    
    int fd = open("nofile.txt", O_RDONLY);
    
    if (fd == -1) {
        printf("Ошибка: %s (код: %d)\n", strerror(errno), errno);
        
        if (errno == ENOENT) {
            printf("Обнаружена ENOENT: файл не существует\n");
            printf("Создаем файл...\n");
            
            // Создаем файл
            fd = open("nofile.txt", O_CREAT | O_WRONLY, 0644);
            if (fd != -1) {
                write(fd, "Файл создан \n", 26);
                close(fd);
                printf("✓ Файл успешно создан\n");
            }
        }
    } else {
        printf("✓ Файл успешно открыт\n");
        close(fd);
    }
    
    return 0;
}
CODE

# 8. Компилируем исправленную версию
echo "8. Компилируем исправленную программу..."
gcc -o task_fixed task_fixed.c

# 9. Запускаем исправленную программу
echo ""
echo "9. Запускаем исправленную программу:"
echo "-------------------------------------"
./task_fixed
echo "-------------------------------------"

# 10. Проверяем, что файл создался
echo ""
echo "10. Проверяем создание файла:"
if [ -f "nofile.txt" ]; then
    echo "   ✓ Файл 'nofile.txt' создан"
    echo "   Содержимое файла:"
    cat nofile.txt
else
    echo "   ✗ Файл не создан"
fi

echo ""
echo "=== Задание выполнено! ==="
echo "Созданные файлы:"
echo "  - task.c          (исходная программа с ошибкой)"
echo "  - task            (скомпилированная программа)"
echo "  - analysis.txt    (вывод strace с ENOENT)"
echo "  - task_fixed.c    (исправленная программа)"
echo "  - task_fixed      (скомпилированная исправленная программа)"
echo "  - nofile.txt      (созданный файл)"
