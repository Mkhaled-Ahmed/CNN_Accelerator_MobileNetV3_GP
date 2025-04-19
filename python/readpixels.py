def to_twos_complement_18bit(num):
    bits = 18
    if num < -(1 << (bits - 1)) or num >= (1 << (bits - 1)):
        raise ValueError(f"Number {num} is out of range for 18-bit 2's complement representation.")
    
    if num >= 0:
        binary = format(num, '018b')
    else:
        binary = format((1 << bits) + num, '018b')
    
    return binary


def read_and_flatten(filenamein,filenameout):
    with open(filenamein, 'r') as file:
        lines = file.readlines()
        # Split the line by spaces and convert each part to an integer
        #with open("textfiles\\conv2d_weights.txt", "w") as file:
        sum_line = 0
        size = 0
        mean = 0
        minnum = 0
        maxnum = 0
        x = 0
        for line in lines:
            # Remove any leading/trailing whitespace and split by spaces
            line = line.strip()
            sum_line =sum_line+sum(int(num) for num in line.split())
            size = size + len(line.split())
        mean = sum_line/size
        print("Mean:", mean)
        with open(filenameout, "w") as file:
            for num in range(226):  # Generate numbers from 1 to 100
                file.write(f"{to_twos_complement_18bit(0)}\n")  # Write each number on a new line
            for line in lines:
                # Remove any leading/trailing whitespace and split by spaces
                file.write(f"{to_twos_complement_18bit(0)}\n")  # Write each number on a new line
                line = line.strip()
                if line:
                    flat_list = [int(num) for num in line.split()]
                    for num in flat_list:
                        x=round((num-mean)*2**9)
                        # minnum = min(x, minnum)
                        # maxnum = max(x, maxnum)
                        file.write(f"{to_twos_complement_18bit(x)}\n")
                    file.write(f"{to_twos_complement_18bit(0)}\n")  # Write each number on a new line
            for num in range(225):  # Generate numbers from 1 to 100
                file.write(f"{to_twos_complement_18bit(0)}\n")  # Write each number on a new line
            file.write(f"{to_twos_complement_18bit(0)}")  # Write each number on a new line
        # print(minnum)
        # print(maxnum)
        # print(sum_line)
        # print(size)
            # break
            # if line:
            #     flat_list = [int(num) for num in line.split()]
            
# Example usage
if __name__ == "__main__":
    filename = 'textfiles\\pixel_values_R.txt'  # Change this to your file name
    flat_result = read_and_flatten('textfiles\\pixel_values_R.txt', 'textfiles\\inputR.txt')
    flat_result = read_and_flatten('textfiles\\pixel_values_G.txt', 'textfiles\\inputG.txt')
    flat_result = read_and_flatten('textfiles\\pixel_values_B.txt', 'textfiles\\inputB.txt')
    # print("Flattened list:", flat_result)
