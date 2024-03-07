

class Stack:

    def __init__(self):
        self.__data = []
        self.__max_history = []
        self.__min_history = []


    def push(self, value):
        self.__data.append(value)

        last_max_history = self.__max_history[-1] if len(self.__max_history) > 0 else 0
        max_value = max(value, last_max_history)
        self.__max_history.append(max_value)

        last_min_histroy = self.__min_history[-1] if len(self.__min_history) > 0 else 10000000000
        min_value = min(value, last_min_histroy)
        self.__min_history.append(min_value)

    def pop(self):

        self.__max_history.pop(-1)
        self.__min_history.pop(-1)
        return self.__data.pop(-1)

    def peek(self):
        return self.__data[-1]

    def max_value(self):
        return self.__max_history[-1]

    def min_value(self):
        return self.__min_history[-1]
    

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