prog="sum mov-c fib add if-else pascal quick-sort select-sort max min3 switch bubble-sort"

i=1
for p in $prog; do
  printf "%s " $i;
  ./riscv-loader app/$p;
  i=$((i+1));
done
