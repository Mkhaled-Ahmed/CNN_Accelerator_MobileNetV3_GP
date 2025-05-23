def fixed_point_7bit_twos_complement(binary_str):
    try:
        # Ensure the input is a valid binary number
        if not all(c in '01' for c in binary_str):
            return "Invalid binary number"

        # Ensure the length is at least 8 bits (1 sign bit + 7 fraction bits)
        # if len(binary_str) < 8:
        #     return "Binary number should be at least 8 bits long"

        # Convert binary to integer using two's complement
        num_bits = len(binary_str)
        integer_value = int(binary_str, 2)
        
        # Handle negative numbers using two’s complement
        if binary_str[0] == '1':  # Negative case
            integer_value -= (1 << num_bits)

        # Convert to fixed-point decimal with 7 fractional bits
        decimal_value = integer_value / (2 **9)


        return decimal_value

    except Exception as e:
        return f"Error: {str(e)}"


    except Exception as e:
        return f"Error: {str(e)}"


try:
    with open("textfiles\\output_flat.txt", "r") as file:
        binary_inputs = file.readlines()
    
    # Process each binary number in the file
    with open("textfiles\\output_flat_decimal.txt", "w") as file:
        for binary_input in binary_inputs:
            binary_input = binary_input.strip()  # Remove any leading/trailing whitespace
            decimal_output = fixed_point_7bit_twos_complement(binary_input)
            file.write(f"{decimal_output}\n")  # Write each number on a new line
except FileNotFoundError:
    print("Error: output.txt not found.")
# print(fixed_point_7bit_twos_complement("00000100011010"))
