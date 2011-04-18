class RouteFinder
  
  def initialize(data)
    @data = data
    @routes = []
    @route_number = 0
  end
  
  def find_cheapest_route(test_case)
    find_all_routes(test_case)
    final_routes = compress_routes
    string_this(final_routes.sort_by!{|route| route[:price]}.first)
  end
  
  def find_fastest_route(test_case)
    find_all_routes(test_case)
    final_routes = compress_routes
    quickest_route = final_routes.sort_by do |route|
      start = Float(route[:begin].split(":").join)
      finish = Float(route[:arrive].split(":").join)
      finish - start
    end
    string_this(quickest_route[0])
  end
  
  private
  
  def compress_routes
    final_routes = []
    @routes.each_with_index do |route, index|
      total_route_price = total(route.map {|point| point[:price]})
      this_route = {}
      this_route[:begin] = route.first[:departure_time]
      this_route[:arrive] = route.last[:arrival_time]
      this_route[:price] = total_route_price
      final_routes << this_route
    end
    final_routes
  end
  
  def find_all_routes(test_case)
    @data[test_case].each do |row|
      #get the starting positions
      if row[:start] == "A"
        build_a_route(test_case, row)
      end
    end
    @routes.delete_if {|row| row.empty? || row.last[:end] != "Z"}
  end
  
  def total(amounts)
      (amounts.inject(:+) * 100).to_i / 100.0
  end
  
  def string_this(route)
    "#{route[:begin]} #{route[:arrive]} #{route[:price]}"
  end
  
  #this is the top level (start positions)
  def build_a_route(test_case, start_row)
    @routes[@route_number] = []
    traverse_all_options(test_case, get_array_of_options(test_case, start_row), 0)
    @route_number += 1
  end
  
  #add one to the route number (within a block of start positions)
  def start_a_new_route
    previous_route = @routes[@route_number].collect {|route| route}
    previous_route.delete_at(-1)
    @route_number +=1
    @routes[@route_number] = []
    @routes[@route_number] = previous_route
  end
  
  #repeating construct to traverse all route_options
  def traverse_all_options(test_case, route_options, level)
    this_route = route_options.pop
    #I dont like this it should be refactored
    @routes[@route_number].delete_at(-1) if @routes[@route_number].size > level
    @routes[@route_number] << this_route
    start_a_new_route and return if this_route[:end] == "Z" || route_options.empty?
    level += 1
    route_options.each do |route|
      traverse_all_options(test_case, get_array_of_options(test_case, route), level)
    end
  end
  
  #find all routes for the current landing spot
  def get_array_of_options(test_case, start_row)
    array_of_options = @data[test_case].map {|option| option if option[:start] == start_row[:end] && option[:departure_time] > start_row[:arrival_time]}.compact!
    array_of_options << start_row
    array_of_options
  end
  
end