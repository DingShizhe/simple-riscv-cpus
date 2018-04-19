prog="sum mov-c fib add if-else pascal quick-sort select-sort max min3 switch bubble-sort"


i=1
for p in $prog; do
  printf "%s. %s" $i $p;

  # compile
  riscv64-unknown-elf-gcc -c ./src/start.S -o ./obj/start.o  -march=rv32im -mabi=ilp32

  riscv64-unknown-elf-gcc -c ./src/$p.c -o ./obj/$p.o  -march=rv32im -mabi=ilp32

  printf "."

  # link "" program entry	
  riscv64-unknown-elf-ld -o ./app/$p -melf32lriscv  ./obj/start.o ./obj/$p.o  -Ttext=0

  printf "."

  # disassembly
  riscv64-unknown-elf-objdump -Mno-aliases,numeric -D ./app/$p > ./disassembly/$p.txt

  # disassembly
  riscv64-unknown-elf-objdump  -D ./app/$p > ./disas/$p.txt

  printf "."

  # disass.......
  riscv64-unknown-elf-objdump -s ./app/$p > ./ctnt/$p.txt

  cd ./ctnt
  python3 gn.py $p > $p.vh
  mv ./$p.vh ../sim2/
  cd ..

  printf ".\n"

  #
  i=$((i+1));
done
