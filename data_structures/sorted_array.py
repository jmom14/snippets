class SortedArray:
    
    def __init__(self):
        self.arr = []

     
    def insert(self, data):
        inserted = False
        if len(self.arr) == 0:
            self.arr.append(data)
            return
        
        for i, num in enumerate(self.arr):
            if num > data:
                self.arr.insert(i, data)
                inserted = True
                return
            
        if not inserted:
            self.arr.append(data)
    

    def get_arr(self):
        return self.arr
        
sorted_array = SortedArray()


arr = [1,50,45,60,23,1,1,1]
for num in arr:
    sorted_array.insert(num)
    
print(sorted_array.get_arr())
    