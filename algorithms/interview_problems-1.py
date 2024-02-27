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

'''
Link: https://leetcode.com/problems/contains-duplicate/
Problem: Contains Duplicate
'''