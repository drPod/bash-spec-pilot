/* C test subject corresponding to WcFromC.wcProg; translation is not proved.
 * Unlike the model, size_t is bounded and getchar can signal IO errors as EOF.
 */
#include <stdio.h>

int main(void) {
  size_t nl = 0; int c;
  c = getchar();
  while (c != EOF) {
    if (c == '\n') nl = nl + 1;
    c = getchar();
  }
  printf("%zu\n", nl);
  return 0;
}
