# Usage: `nix repl -f ./fibonacci.nix'` then `fib <n>`
#
# Loops? We don't do that here
rec {
  fib' = i: n: m:
    if i == 0
    then n
    else fib' (i - 1) m (n + m);
  fib = n: fib' n 1 1;
}
