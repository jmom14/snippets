'''
Problem: Flat Array
Input: [1, 2 , 3, [4, 5, 6], 7, 8]
Output: [1, 2 , 3, 4, 5, 6, 7, 8]
'''

def flat(arr):
    output = []
    for index in range(0, len(arr)):
        if isinstance(arr[index], list):
            output.extend(flat(arr[index]))
        else:
            output.append(arr[index])
    return output

print(flat([1, 2 , 3, [4, 5, 6], 7, 8]))
  

'''
Problem: Flat dictionary
Input: { 'a': 1, 'b': 'foo', 'c': { 'a': 2, 'b': { 'x' : 'zooo', 'z' : 'tooo' } } }
Output: {'a': 1, 'b': 'foo', 'c_a': 2, 'c_b_x': 'zooo', 'c_b_z': 'tooo'}
'''

def flat_concat(key, dictionary):
    dic = {}
    for dic_key in dictionary:
        
        if isinstance(dictionary[dic_key], dict):
            dic.update(flat_concat(key + "_" + dic_key, dictionary[dic_key]))
        else:
            k = key + "_" + dic_key
            dic[k] = dictionary[dic_key]
    
    return dic

def flat_dict(dictionary):
    output = {}
    for key in dictionary:
        
        if isinstance(dictionary[key], dict):
            output.update(flat_concat(key, dictionary[key]))
        else:
            output[key] = dictionary[key]
            
    return output

print(flat_dict({ 'a': 1, 'b': 'foo', 'c': { 'a': 2, 'b': { 'x' : 'zooo', 'z' : 'tooo' } } }))


'''
Problem: fibonacci
Example: 0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144
'''

def fib(n):
	
	if n == 1: return 0
	if n == 2 or n == 3: return 1
	return fib(n-1) + fib(n-2)
	

print(fib(10))


'''
Problem: Sliding window

'''

def get_diff(a,b):
    if a > b:
        return a - b
    else: 
        return b - a

def segment(x, space):
    maximum = 0
    a = 0
    current = 0
    
    for i in range(0, x - 1):
        maximum = maximum + get_diff(space[i], space[i+1])
    current = maximum
    
    for j in range(1, len(space) - x + 1):
        start_diff = get_diff(space[j], space[j-1])
        end_diff = get_diff(space[j + x - 1], space[j + x - 2])
        
        current = current - start_diff + end_diff
        maximum = max(current, maximum)

    
    return maximum

'''
Link: https://leetcode.com/problems/two-sum/
Problem: Two Sum
'''

def twoSum(self, nums, target):
    keys = {}
    output = []
    
    for index in range(len(nums)):
        t = target - nums[index]
        
        if t in keys:
            output[0] = index
            output[1] = keys[t]
            
        keys[nums[index]] = index 
    
            
    return output

def twoSum(self, nums, target: int):
    
    fm = {}

    for i in range(len(nums)):
        current = nums[i]
        lookup = target - current
        
        if lookup in fm:
            return [i, fm[lookup]]
        fm.update({current: i})    

'''
Link: https://leetcode.com/problems/contains-duplicate/
Problem: Contains Duplicate
Input: [1,2,3,1]
Output: true
'''

def containsDuplicate(self, nums) -> bool:
    copy = set()
    
    for num in nums:
        if num in copy:
            return True
        
        copy.add(num)
        
    return False

'''
Link: https://leetcode.com/problems/longest-substring-without-repeating-characters/
Problem: Longest Substring Without Repeating Characters
Input: "abcabcbb"
Output: 3
'''

def lengthOfLongestSubstring(self, s: str) -> int:
    a = 0
    b = 0
    current = set()
    output = 0
    
    while b < len(s):
        if not s[b] in current:
            current.add(s[b])  
            b+=1
            output = max(output, len(current))
        else:
            current.remove(s[a])
            a+=1
            
    return output


'''
Link: https://leetcode.com/problems/fizz-buzz/
Problem: Fizz Buzz
Input: 15
Output: ["1","2","Fizz","4","Buzz","Fizz","7","8","Fizz","Buzz","11","Fizz","13","14","FizzBuzz"]
'''

def fizzBuzz(self, n: int):
    output = []
    for i in range(1, n + 1):
        c = ""
        if i % 3 == 0: 
            c = "Fizz"
        if i % 5 == 0: 
            c = c + "Buzz"
        if i % 3 != 0 and i % 5 != 0:
            c = str(i)
        output.append(c)

    return output


'''
Link: https://leetcode.com/problems/reverse-string/
Problem: Reverse String
Input: ["h","e","l","l","o"]
Output: ["o","l","l","e","h"]
'''

def reverseString(self, s) -> None:
    a = 0
    b = len(s) - 1

    while b > a:
        s[a], s[b] = s[b], s[a]
        a = a + 1
        b = b - 1

    return s


'''
Problem: Binary search
'''

def binary_search(arr, a, b, search):
    while a <= b:

        mid = a + (b - a) // 2
        if arr[mid] == search:
            return mid
            
        elif arr[mid] > search:
            b = mid - 1
        else: 
            a = mid + 1
    
    return -1
    
nums = [1, 5, 9, 10, 14, 16, 78, 100, 121, 122, 123]
print(binary_search(nums, 0, len(nums) - 1, 123))
 