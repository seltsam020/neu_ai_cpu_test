# Sample CPU
## 东北大学AI 1902  计算机系统实验  test_git
成员（github账号） 李卓伦（seltsam020） 冯科洋（seven-1234） 明月（Ethereal913）
##  总体设计
流水线是数字系统中一种提高系统稳定性和工作速度的方法，广泛应用于高档CPU的架构中。  
根据MIPS处理器的特点，将整体的处理过程分为取指令（IF）、指令译码（ID）、执行（EX）、存储器访问（MEM）和寄存器写回（WB）五级，对应多周期的五个处理阶段。  
其中，一个指令的执行需要 5 个时钟周期。  
## 流水线CPU总体结构图
流水线CPU总体结构设计如下图所示
![](https://github.com/seltsam020/neu_ai_cpu_test/blob/main/%E6%B5%81%E6%B0%B4%E7%BA%BFCPU%E6%80%BB%E4%BD%93%E7%BB%93%E6%9E%84%E5%9B%BE.png)
## 指令完成度
处理器实现的指令包括除4条非对齐指令外的所有 MIPS I 指令以及MIPS32 中的 ERET 指令。  
共计实现了53条指令，包括：14条算术运算指令、8条逻辑运算指令，6条移位指令、8条分支跳转指令、4条数据移动指令、12条访存指令以及最终添加的LSA指令。  
成功通过第64个点，并制作了一个32时钟周期的乘法器。
## 程序运行环境及使用工具
操作系统：Windows 10 64位( DirectX 12 )   
开发平台：Vivado 2019.2  
编程语言：Verilog HDL硬件描述语言
