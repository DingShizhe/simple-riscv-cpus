# Pipelined RISC-V CPU
一个简单支持 RISC-V 指令集 流水线CPU 的RTL实现

## 我要做什么

- 准备工作和[多周期riscv_cpu](https://github.com/DingShizhe/multicycle-risc-v-cpus)相同
- 流水线cpu的设计和RTL实现
- 调试和上板(Zynq)

## 具体点

## 准备工作（需要支持的测试用例实现的指令）

和[多周期riscv_cpu](https://github.com/DingShizhe/multicycle-risc-v-cpu)相同：

### 支持的测试用例：
分别是：   
  **sum**, **mov-c**, **fib**, **add**, **if-else**, **pascal**, **quick-sort**, **select-sort**, **max**, **min3**, **switch**, **bubble-sort**.    

测试.vh和测试执行文件在[这里](https://github.com/DingShizhe/risc-v-cpu-test)。

### 需要实现的指令：

全部属于**RV32I Base Instruction Set**

| 指令类型 | I - type | S - type | R - type | B - type | J - type | U - type |
| ------- |----------|----------|-----------|-----------|---------|---------|
| **指令** | **addi** |  **sw**  | **add**  | **beq**   | **jal**  | **lui** |
|          | **lw**   |	        | **sub**   |  **bne**  |	       |	       |     
|          | **slli** |    		|    		|  **blt(u)**	|		|	         |
|          | **jalr** |			|	    	|  **bge(u)**	|		|	         | |

### 宏指令及其对应的原指令

|指令|**addi**|**jalr**|**blt(u)**|**bge(u)**|**jal**|
|-----|-----|-----|------|-------|-------|
|**宏指令**|**li**|**ret**|**bgt(u)**|**ble(u)**|**j**|
|		|**nop**|**jr**|		|		|		|
|		|**mv**|		|		|		|		| |

## 设计流水线CPU（仿照教材COD）

加寄存器。

## Data-Hazard


### 对寄存器 (reg_file) 有读和写操作的指令列表

|指令|I - type|lw|jalr| sw |R - type|B - type|jal|lui|
|----|---|---|---|---|---|---|----|-----|
|读地址|rs1|×|rs1|rs2|rs1 rs2|rs1 rs2 | × | × |

|指令|I - type|lw|jalr| sw |R - type|B - type|jal|lui|
|----|---|---|----|---|---|---|----|-----|
|写地址|rd|rd|rd|rd|×|×|rd |rd |


一个指令有读寄存器操作，读地址是rs1或rs2。假设它前面三条指令中有一条有写寄存器的操作，写地址是rd，如果rd==rs1或rd==rs2，那么就会产生数据冲突。

解决冲突的思想是，如果出现上面说的条件，那么就将流水线**后面**的将写寄存器数据拉回到前面。流水线可以看成一个队列，流水线后面的写寄存器数据由先进入流水线的指令支配。

需要注意的是，**LW** 指令得到“要写寄存器的数据”是在访存阶段，其他指令在执行阶段就能得到。对于**LW**后紧接的指令就要读**LW**要写的数据的情形，我们把**LW**后的那个指令延迟一拍进行。


### JAL、 B - type 和 JALR
这三类指令牵扯到PC的分支跳转，当遇到这些指令时，需要流水线阻塞一拍或者两拍，等待PC更新到要跳转的值，流水线再行启动。


为了避免出现新的Hazard:不采取这样的做法   
~~把 Branch 结构放在译码阶段完成，和 **J** 型指令相同，后面的指令等一拍（**stall**）（**flush**）。~~

**Branch** 和**JALR**在执行阶段才能得到是否要跳转或跳转地址，这两个指令后等待两拍。

**JAL** 在译码阶段就能得到跳转地址，等一拍即可。


## 仿真

12个测试用例全部通过。
