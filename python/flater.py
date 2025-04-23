# binary_string = (
#     "101011111110101100000000000000001101101011111111100001000000000001001110000000000010000101000000000010110000000000000000011010100111111111111001000000000011000101000011111110100000000000000011000011110011111110110000000000000010111101000000000010010101001011111111111100000111111110101010"
# )
with open("textfiles\\output.txt", "r") as file:
# Split the binary string into 18-bit chunks
    lines = file.readlines()
chunk_size = 18
with open("textfiles\\output_flat.txt", "w") as file:
    for binary_string in lines:
        binary_string = binary_string.strip()
        subarrays = [binary_string[i:i+chunk_size] for i in range(0, len(binary_string), chunk_size)]
        for i, chunk in enumerate(subarrays):
            file.write(f"{chunk}\n")  # Write each number on a new line