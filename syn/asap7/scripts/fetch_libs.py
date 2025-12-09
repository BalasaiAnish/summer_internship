import os
import subprocess
import sys

if __name__ == "__main__":


    for corner in ["SS","TT","FF"]:
        search_dir = f"/home/bala/asap7sc6t_26/LIB/CCS/{corner}"
        lib_files = os.listdir(search_dir)
        lib_files_list = f"./{corner}_lib_files.txt"
        with open(lib_files_list,"w") as file:
            for lib_file in lib_files:
                write_str = f"{lib_file}\n"
                file.write(write_str)
