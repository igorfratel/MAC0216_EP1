#include "arena.h"
#include "programas.h"

int main() {
	int fim = 0;
	FILE *display = popen("./display_game.py", "w");
	Arena *minha_arena = malloc(sizeof(Arena));
	cria_arena(minha_arena, 15, 15);
	INSTR *p0 = devolve_programa(0);
	INSTR *p1 = devolve_programa(1);
	insere_exercito(minha_arena, 1, p0);
	insere_exercito(minha_arena, 1, p1);
	while(!fim){
		escalonador(minha_arena, NUM_INSTR);
		fim = Atualiza(minha_arena, 5);
		mostra_arena(minha_arena, display);
	}
	destroi_arena(minha_arena);
}
