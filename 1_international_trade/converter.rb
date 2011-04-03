require 'csv'

#get rates and transaction files
trans_array = CSV.read('TRANS.csv')
rates_array = File.read("RATES.xml").split(/<rate>/).delete_if{|row| !row.include?("from")}

# trans_array = CSV.read('TRANS.csv')
# rates_array = File.read("RATES.xml").split(/<rate>/).delete_if{|row| !row.include?("from")}

#convert rates to an array of hashes
rates = []
rates_array.each do |row|
rates << {  :from => row.scan(/<from>(...)<\/from>/).flatten.first,
            :to => row.scan(/<to>(...)<\/to>/).flatten.first,
            :conversion => Float(row.scan(/<conversion>(\d*.\d*)<\/conversion>/).flatten.first)
          }
end

#convert transactions to an array of hashes
trans = []
trans_array.each do |row|
  trans << {:store => row[0], :sku => row[1], :amount => row[2]}
end


class AccountBook
  
  def initialize(item_number, currency, rates, transactions)
    @item_number = item_number
    @currency = currency
    @rates = given_exchange_rates(rates)
    @transactions = select_item(transactions)
    @amounts = []
  end
  
  
  def calculate_exchange_rates
    #Fill in the missing currencies by converting the filled ones
    @rates.each do |row|
      row[:conversion] = build_conversion(row[:from], row[:to]) if row[:conversion] == ""
    end
    @rates.map {|row| row[:conversion] = (row[:conversion] *100000).to_i / 100000.0}
    @rates
  end
  
  
  def calculate_transactions
    #get all the transactions and send the value to calculate the conversion for each
    amounts = []
    @transactions.each do |row|
      amount = row[:amount].split(" ")
      amounts << get_conversion(Float(amount[0]),amount[1])
    end
    @amounts = amounts
  end
  
  def total
    (@amounts.inject(:+) * 100).to_i / 100.0
  end
  
  def rates
    @rates
  end
  
  def transactions
    @transactions
  end
  
  private
  
  def select_item(transactions)
    #remove all transations that we are not interested in
    transactions.delete_if{|row| row[:sku] != @item_number}
  end
  
  def given_exchange_rates(rates)
    #First get all the know currencies
    all_currencies = ((rates.map{|rate| rate[:to]}) + (rates.map{|rate| rate[:from]})).uniq.flatten
    #Then create a new complete array of all currency exchanges from and to
    full_currency_array = []
    all_currencies.each do |from|
      all_currencies.each do |to|
        full_currency_array << {:from => from, :to => to, :conversion => ""}
      end
    end
    #Now merge the complete array with the known rates or make it 1 if its the same currency
    full_currency_array.each do |row|
      rates.each do |rates_row|
        if row[:from] == rates_row[:from] && row[:to] == rates_row[:to]
          row[:conversion] = rates_row[:conversion]
        elsif row[:from] == row[:to]
          row[:conversion] = 1
        end
      end
    end
    full_currency_array
  end
  
  def build_conversion(from,to)
    new_conversion = 0
    #first see if we have the opposite conversion and return that
    @rates.each do |row|
      if row[:to] == from && row[:from] == to && row[:conversion] != ""
        new_conversion = get_reverse_exchange_rate(row[:conversion])
        return new_conversion
      end
    end
    #this is where it get nasty and you head is likley to go into spasm
    #now fill in the gaps, first get a list of all the known conversions for the from currency and to currency we are inspecting
    froms = @rates.collect {|row| row if row[:from] == to && row[:conversion] != "" && row[:conversion] != 1}.compact
    tos = @rates.map {|row| row if row[:to] == from && row[:conversion] != "" && row[:conversion] != 1}.compact
    #now check that a (to) from the froms = a (from) from the tos and send the conversions in to a multiplyer
    #eg CAD to EUR (EUR find a conversion (finds AUD) and see if CAD has AUD too)
    froms.each do |from_row|
      tos.each do |to_row|
        new_conversion = convert_this(from_row[:conversion],to_row[:conversion]) if from_row[:to] == to_row[:from] 
      end
    end
    new_conversion
  end
  
  def convert_this(from_currency, to_currency)
    #now I have (EUR to AUS) and (AUS to CAD) and I want to return (CAD to EUR), just a simple calc after all
    1 / (from_currency * to_currency)
  end
  
  def get_conversion(value,currency)
    #getting the value and currency from the transactions and calculating its value in the base currency
    exchange_rate = 0
    @rates.each do |row| 
      exchange_rate = row[:conversion] if row[:from] == currency && row[:to] == @currency
    end
    new_value = ((exchange_rate * value) * 100).to_i / 100.0
    new_value
  end
  
  def get_reverse_exchange_rate(value)
    #returns the reverse exchange rate
    1 / value unless value == 0
  end
    
end
  
book = AccountBook.new("DM1182", "USD", rates, trans)
puts book.calculate_exchange_rates
puts " "
puts book.calculate_transactions
puts "---------"
puts book.total

File.open("solution.txt", 'w') {|f| f.write(book.total) }
