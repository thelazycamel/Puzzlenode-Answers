require "./lib/schedule_parser"
require "./lib/route_finder"

txt_file = File.open("input.txt", 'r')
hashedFile = ScheduleParser.new(txt_file).to_array
txt_file.close
cheapest_route = []
fastest_route = []
File.open("solution.txt", 'w') {|f|
  hashedFile.each_with_index do |test_case, index|
    cheapest_route << RouteFinder.new(hashedFile).find_cheapest_route(index)
    fastest_route << RouteFinder.new(hashedFile).find_fastest_route(index)
    f.write("#{cheapest_route[index]}\n")
    f.write("#{fastest_route[index]}\n\n")
  end
}
