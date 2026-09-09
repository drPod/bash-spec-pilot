/* Second wrapper translation unit (adequacy-resume-2). relay.c is included
   unchanged (its hash is the source identity); main hands relay's status to
   the environment through exit() instead of returning it. exit is declared
   here (not in include/) as an external function with no return in the
   specification: its VST precondition is the caller's obligation
   `outcome w0 status final pending`, so the concrete execution reaching the
   exit call carries the returned status. Not part of the source-fidelity claim;
   compiled from the relay directory so that #include "relay.c" resolves. */
#include "relay.c"

void exit(int status);

int main(void) {
    exit(relay());
    return 0;
}
