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
                write(fd, "Файл создан автоматически\n", 26);
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
