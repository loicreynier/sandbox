from math import pi

number = 150

# Print variable name and its value
print(f"{number = }")

# Set number of decimals
print(f"{number = :.2f}")

# Set number of characters
print(f"{number = :09.2f}")

# Scientific notation
print(f"{number = :e}")

# Hex conversion
print(f"hex : {number:#0x}")

# Octal conversion
print(f"octal : {number:o}")

print("\n")
ratio = 1 / 2
print(f"{ratio = }")

# Percentage
print(f"{ratio = :.2%}")

print("\n")
large_number = pi**20
print(f"{large_number = }")

# Put comma in large numbers
print(f"{large_number = :,}")


print("\n")

# Use variable in formatting
for n in range(1, 10):
    print(f"π to {n} places is {pi:.{n}f}")


print("\n")


# Value conversion
class Human:
    def __init__(self, name: str):
        self.name: str = name

    def __str__(self):
        return self.name

    def __repr__(self):
        return f'Human("{self.name}")'


me = Human("Loïc")
print(f"{me}")
print(f"{me!s}")
print(f"{me!r}")
