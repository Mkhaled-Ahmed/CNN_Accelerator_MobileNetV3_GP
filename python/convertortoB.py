def to_twos_complement_18bit(num):
    bits = 18
    if num < -(1 << (bits - 1)) or num >= (1 << (bits - 1)):
        raise ValueError(f"Number {num} is out of range for 18-bit 2's complement representation.")
    
    if num >= 0:
        binary = format(num, '018b')
    else:
        binary = format((1 << bits) + num, '018b')
    
    return binary

# Example usage:
if __name__ == "__main__":
    filenamein = 'textfiles\\conv2d_weights.txt'  # Change this to your file name
    filenameout = 'textfiles\\weights_B.txt'  # Change this to your file name
    with open(filenamein, 'r') as file:
        lines = file.readlines()
    with open(filenameout, "w") as file:
        for num in lines:
            
            num = int(num.strip())
            try:
                result = to_twos_complement_18bit(num)
                print(result)
                file.write(f"{result}")  # Write each number on a new line
            except ValueError as e:
                print(e)
