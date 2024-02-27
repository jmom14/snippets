'''
Problem: Grouping transactions
Input: ['orange', 'apple', 'banana', 'grapes', 'orange']
Output: ['orange 2', 'apple 1', 'banana 1', 'grapes 1']
'''

def group_transactions(transactions):
    frequency_map = {}
    frequency_map_agg = {}
    output = []

    for t in transactions:
        if t in frequency_map:
            frequency_map[t] = frequency_map[t] + 1
        else:
            frequency_map[t] = 1

    for key in frequency_map:
        freq = frequency_map[key]
        if freq in frequency_map_agg:
            new_array = frequency_map_agg[freq]
            new_array.append(key)
        else:
            array = []
            array.append(key)
            frequency_map_agg[freq] = array
            
    sorted_object = dict(sorted(frequency_map_agg.items(), reverse=True))
    
    for freq in sorted_object:
        if len(sorted_object[freq]) > 1:
            sorted_words = sorted(sorted_object[freq])
            for word in sorted_words:
                output.append("{} {}".format(word, freq))
        else:
            output.append("{} {}".format(sorted_object[freq][0], freq))

    return output

print(group_transactions(['orange', 'apple', 'banana', 'grapes', 'orange']))