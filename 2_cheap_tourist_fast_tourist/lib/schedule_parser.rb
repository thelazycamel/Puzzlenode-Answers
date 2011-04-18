class ScheduleParser
  
  def initialize(txt_file)
    @txt_file = txt_file.to_a
  end
  
  def to_array
    #find the number of test cases we are dealing with and put build them into arrays of hashes
    number_of_test_cases = @txt_file.shift.to_i
    test_case_number = -1
    test_case = []
    number_of_test_cases.times do |no|
      test_case[no] = []
    end
    @txt_file.each do |row|
      #start a new array if the line is blank and move on to the next item
      if row == "\n"
        test_case_number += 1 
        next
      end
      row.strip!
      row_array = row.split(" ")
      #don't create a new hash if there is only one element (the number)
      next if row_array.length == 1
      row_hash = {}
      row_hash[:start] = row_array[0]
      row_hash[:end] = row_array[1]
      row_hash[:departure_time] = row_array[2]
      row_hash[:arrival_time] = row_array[3]
      row_hash[:price] = Float(row_array[4])
      test_case[test_case_number] << row_hash
    end
    test_case
  end
end