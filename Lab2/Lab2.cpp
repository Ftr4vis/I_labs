#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <locale.h>
int main()
{
	setlocale(LC_ALL, "Russian");
	srand(time(0));
	int N = rand();
	printf("Двоичный код: ");
	for (int i = 0; i < 32; i++)               // Вывод битов
	{
		printf("%d", (N >> (31 - i)) & 1);
	}
	printf("\n");
	printf("Шестнадцатиричный код: %08X\n", N);
	for (int i = 0; i < 3; i++)
	{
		int b = (N >> (24 - 8 * i)) & 0xFF;           // Получение i-го байта
		int raz = abs((b & 0xF) - ((b >> 4) & 0xF));  // Разность тетрад i-го байта
		for (int j = (i + 1); j < 4; j++)
		{
			int b2 = (N >> (24 - 8 * j)) & 0xFF;     // Получение j-го байта
			int raz2 = abs((b2 & 0xF) - ((b2 >> 4) & 0xF));  // Разность тетрад j-го байта
			if (raz2 > raz)                          // Сравнение разностей
			{
				N &= (0xFFFFFF00 << (24 - 8 * i) | 0xFFFFFF00 >> (8 + 8 * i));    // Обнуление i-го байта
				N &= (0xFFFFFF00 << (24 - 8 * j) | 0xFFFFFF00 >> (8 + 8 * j));	// Обнуление j-го байта
				N |= (b2 << (24 - 8 * i));   // Заносим j-й байт га место i-го 
				N |= (b << (24 - 8 * j));    // Заносим i-й байт га место j-го 
				b = b2;
				raz = raz2;
			}
		}
	}
	printf("Результат: %08X\n", N);
	printf("Двоичный код: ");
	for (int i = 0; i < 32; i++)                 // Вывод битов
	{
		printf("%d", (N >> (31 - i)) & 1);
	}
	return 0;
}
