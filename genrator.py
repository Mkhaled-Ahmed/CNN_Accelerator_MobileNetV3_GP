# Generate numbers and write to a file
with open("output.txt", "w") as file:
    for num in range(673,673+224):  # Generate numbers from 1 to 100
        file.write(f"{num}\n")  # Write each number on a new line
