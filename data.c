#include <stdio.h>

int main() {
    int n;
    scanf("%d", &n);

    int A[n], B[n];
    for (int i = 0; i < n; ++i) {
        scanf("%d", &A[i]);
    }

    for (int i = 1; i < n; i += 2) {
        B[i] = A[i - 1];
        B[i - 1] = A[i];
    }
    if (n % 2 == 1) {
        B[n - 1] = A[n - 1];
    }
    printf("B: ");
    for (int i = 0; i < n; ++i) {
        printf("%d ", B[i]);
    }
    return 0;
}
