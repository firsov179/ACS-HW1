#include <stdio.h>


void scan(int *A, int n) {
    for (int i = 0; i < n; ++i) {
        scanf("%d", &A[i]); // считываем исходный массив
    }
}

void refactor(int *A, int* B, int n) {
    for (int i = 0; i < n; i++) {
        // Делаем заданное преобразование
        if (i % 2 == 0) {
            B[i + 1] = A[i];
        } else {
            B[i - 1] = A[i];
        }
    }
}

void print(int* A, int n) {
    for (int i = 0; i < n; ++i) { // вывод массива
        printf("%d ", A[i]);
    }
    printf("\n");
}

int main() {
    int n; // длина массива
    scanf("%d", &n);

    if (n < 1 || (n & 1) == 1 || n > 1000) { // проверка корректности длины
        printf("Incorrect length = %d\n", n);
        return 0;
    }

    int A[n], B[n];
    scan((int *) &A, n);
    refactor((int *) &A, (int *) &B, n);
    printf("A: ");
    print((int *) &A, n);
    printf("B: ");
    print((int *) &B, n);
    return 0;
}

