import unittest

class MinStack():
  
    def __init__(self):
        self.data = []
        self.mins = []

    def push(self, val: int) -> None:
        self.data.append(val)
        m = val if len(self.mins) == 0 else min(val, self.mins[-1])
        self.mins.append(m)

    def pop(self) -> None:
        self.mins.pop(-1)
        return self.data.pop(-1)

    def top(self) -> int:
        return self.data[-1]

    def get_min(self) -> int:
        return self.mins[-1]



class TestStack(unittest.TestCase):

    def test_push_and_pop(self):
        stack = MinStack()
        stack.push(1)
        stack.push(2)
        stack.push(3)
        stack.push(4)
        stack.push(5)
        self.assertEqual(stack.pop(), 5)
        self.assertEqual(stack.pop(), 4)
        self.assertEqual(stack.pop(), 3)
        stack.pop()
        self.assertEqual(stack.pop(), 1)


    def test_peek(self):
        stack = MinStack()
        stack.push(1)
        stack.push(2)
        self.assertEqual(stack.top(), 2)
        stack.pop()
        self.assertEqual(stack.top(), 1)

    
    def test_min_value(self):
        stack = MinStack()
        stack.push(6)
        stack.push(5)
        stack.push(7)
        stack.push(2)
        stack.push(1)
        stack.push(50)
        stack.push(4)
        stack.pop()
        self.assertEqual(stack.get_min(), 1)
        stack.pop()
        stack.pop()
        self.assertEqual(stack.get_min(), 2)
        stack.pop()
        self.assertEqual(stack.get_min(), 5)
        stack.pop()
        stack.pop()
        self.assertEqual(stack.get_min(), 6)

unittest.main()
