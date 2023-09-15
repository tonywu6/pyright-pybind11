from contextlib import suppress
from calculator import add
from calculator.subtract import sub

if __name__ == "__main__":
    print(f"41 + 1 = {add(41, 1)}")
    print(f"43 - 1 = {sub(43, 1)}")

    with suppress(TypeError):
        print(f"43 - '1' = {sub(43, '1')}")
