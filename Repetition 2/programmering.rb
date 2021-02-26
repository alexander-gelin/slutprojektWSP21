def max_of_two(num1,num2)
    if num1 > num2
        return num1
    else
        return num2
    end
end

def delete_char(string,char)
    i = 0
    newstring = ""
    while i < string.length
        if string[i] != char
            newstring << string[i]
        end
        i += 1
    end
    return newstring
end