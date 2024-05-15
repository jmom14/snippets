

class Stack:

    def __init__(self):
        self.data = []
        self.maxs = []
        self.mins = []


    def push(self, value):
        self.data.append(value)

        mx = value if len(self.mins) == 0 else max(value, self.maxs[-1])
        self.maxs.append(mx)

        mn = value if len(self.mins) == 0 else min(value, self.mins[-1])
        self.mins.append(mn)

    def pop(self):
        self.maxs.pop(-1)
        self.mins.pop(-1)
        return self.data.pop(-1)

    def peek(self):
        return self.data[-1]

    def max_value(self):
        return self.maxs[-1]

    def min_value(self):
        return self.mins[-1]
    

stack = Stack()
stack.push(10)            # -       [10]
stack.push(20)            # -       [10, 20]
print(stack.pop())        # 20      [10]
print(stack.max_value())  # 10      [10]
stack.push(30)            # -       [10, 30]
stack.push(20)            # -       [10, 30, 20]
stack.push(30)            # -       [10, 30, 20, 30]
print(stack.max_value())  # 30      [10, 30, 20, 30]
print(stack.peek())       # 30      [10, 30, 20, 30]
stack.pop()               # -       [10, 30, 20]
print(stack.max_value())  # 30      [10, 30, 20]
stack.pop()               # -       [10, 30]
stack.pop()               # -       [10]
print(stack.max_value())  # 10      [10]
stack.push(25)            # -       [10, 25]
stack.push(25)            # -       [10, 25, 25]
print(stack.max_value())  # 25      [10, 25, 25]
stack.pop()               # -       [10, 25]
print(stack.max_value())  # 25      [10, 25]
stack.pop()               # -       [10]
print(stack.max_value())  # 10      [10]