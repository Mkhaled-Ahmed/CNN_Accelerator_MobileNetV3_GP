# def read_and_flatten(filename):
#     with open(filename, 'r') as file:
#         lines = file.readlines()
#         # Split the line by spaces and convert each part to an integer
#         with open("textfiles\\conv2d_weights.txt", "w") as file:
#             for line in lines:
#                 # Remove any leading/trailing whitespace and split by spaces
#                 line = line.strip()
#                 if line:
#                     flat_list = [int(num) for num in line.split()]
                
# # Example usage
# if __name__ == "__main__":
#     filename = 'textfiles\\pixel_values_R.txt'  # Change this to your file name
#     flat_result = read_and_flatten(filename)
#     # print("Flattened list:", flat_result)
def read_and_flatten(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
        temp=0
        flat_list_size=0
        # Split the line by spaces and convert each part to an integer
        with open("textfiles\\conv2d_weights.txt", "w") as file:
            for line in lines:
                # Remove any leading/trailing whitespace and split by spaces
                line = line.strip()
                if line:
                    flat_list = [int(num) for num in line.split()]
                    flat_list_size = flat_list_size+len(flat_list)
                    #print("Flattened list:", flat_list)
                    temp=temp+1
                    file.write(f"{flat_list[0]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[3]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[6]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[1]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[4]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[7]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[2]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[5]}\n")  # Write each number on a new line
                    file.write(f"{flat_list[8]}\n")  # Write each number on a new line
            print("temp:", temp)
            print("flat_list_size:", flat_list_size)

# Example usage
if __name__ == "__main__":
    filename = 'textfiles\\02_conv_1.txt'  # Change this to your file name
    flat_result = read_and_flatten(filename)
    # print("Flattened list:", flat_result)
