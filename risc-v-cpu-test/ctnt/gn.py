#!/bin/python3

import sys
import re

filename = sys.argv[1]

f = open(filename+".txt", "r")

break_pattern = re.compile(r".comment:")

continue_pattern1 = re.compile(r".text")
continue_pattern2 = re.compile(r".data")
continue_pattern3 = re.compile(r"riscv")

hex_list = "1234567890abcdef "

def contain_all(seq, aset):
    for c in seq:
        if c not in aset:
            return False
            pass
        pass
    return True


for line in f.readlines():

    break_point = re.findall(break_pattern, line)
    if break_point:
        print("\n" + "//Content of section .comment" + "\n\n" + "//....")
        break

    continue_point1 = re.findall(continue_pattern1, line)
    if continue_point1:
        print("\n" + "//Content of section .text" + "\n")
        continue

    continue_point2 = re.findall(continue_pattern2, line)
    if continue_point2:
        print("\n" + "//Content of section .data" + "\n")
        continue

    continue_point3 = re.findall(continue_pattern3, line)
    if continue_point3:
        continue


    if len(line) > 29:
        first_addr_str = line[2:5]
        # first_addr_str = line[1:5]
    
        if contain_all(first_addr_str, hex_list):
            first_addr = int(first_addr_str, 16)//4
            pass
        else:
            continue

        # print(first_addr_str)


        for i in range(4):

            addr = first_addr + i

            data_str = line[6+9*i:14+9*i]
            real_data_str = data_str[6:8]+data_str[4:6]+data_str[2:4]+data_str[0:2]
            if data_str[0] != " ":

                print("mem[" + str(addr) + "] = 32'h" + real_data_str + ";" + "\t// " + str(hex(addr * 4)))

                # print(data_str)
                pass
            pass
        pass
    pass


    
