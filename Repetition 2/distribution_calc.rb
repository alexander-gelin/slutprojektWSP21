file = File.open("foods.txt", "r")
file_content = file.readlines
total = 0
fruits = 0
beverages = 0
vegetables = 0
i = 0
while i < file_content.size
    file_content.each do |line|
        if "#Fruit".in? file_content
            fruits += 1
            total += 1
        elsif "#Beverage".in? file_content
            beverages += 1
            total += 1
        elsif "#Vegetable".in? file_content
            vegetables += 1
            total += 1
        end
    end
    i += 1 
end
puts "Total: #{total}"
puts "Fruits: #{fruits}"
puts "Beverages: #{beverages}"
puts "Vegetables: #{vegetables}"


# Fastnade på den här...
