import os
import subprocess
import sys


def export_to_v(top_mod: str, file_list_path: str, dest_folder_path: str):
    file_list = []
    with open(file_list_path,"r") as file:
        file_list = file.readlines()

    cmd_str = f"sv2v --top={top_mod} --write=top_tmp.v "
    for i in file_list:
        cmd_str = cmd_str+i.strip()+" "

    sv2v_out = subprocess.run(cmd_str,shell=True,capture_output=True)
    dest_file_path = dest_folder_path+"/"+top_mod
    subprocess.run(["mv","./top_tmp.v",dest_file_path])

if __name__ == "__main__":
    # Read top module name
    top_mod = sys.argv[1]

    # Make temp directory
    os.makedirs("./tmp_synth",exist_ok=True)

    export_to_v(top_mod,"./syn/scripts/file_list.txt","./tmp_synth")
