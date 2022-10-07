#include <stdio.h>

int main() {
    int n;
    scanf("%d", &n);

    if (n < 1 || (n & 1) == 1 || n > 100) {
        printf("Incorrect length = %d\n", n);
        return 0;
    }

    int A[n], B[n];
    for (int i = 0; i < n; ++i) {
        scanf("%d", &A[i]); // считываем исходный массив
    }

    for (int i = 0; i < n; i++) {
        // Делаем заданное преобразование
        if (i % 2 == 0) {
            B[i + 1] = A[i];
        } else {
            B[i - 1] = A[i];
        }
    }
    printf("A: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", A[i]); // выводим исходный массив
    }
    printf("\nB: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", B[i]); // выводим полученный массив
    }
    printf("\n");
    return 0;
}
