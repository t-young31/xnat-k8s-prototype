import sys

SUBSTRING = "    server:"

if __name__ == "__main__":
    filepath = sys.argv[1]
    public_ip = sys.argv[2]
    lines = open(filepath, "r").readlines()

    with open(filepath, "w") as file:
        for line in lines:
            if SUBSTRING in line:
                line = f"{SUBSTRING} https://{public_ip}:6443\n"
            print(line, end="", file=file)
