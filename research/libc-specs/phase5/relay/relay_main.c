/* Wrapper translation unit for a whole-program VST theorem. relay.c is
   included unchanged (its hash is the source identity); main only forwards
   relay's status. This file is not part of the source-fidelity claim. */
#include "relay.c"

int main(void) {
    return relay();
}
