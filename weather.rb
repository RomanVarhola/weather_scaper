#ruby -r './weather.rb' -e 'date'
require 'mechanize'
require 'pry'
require 'date'
require 'csv'
require 'watir'

def get_page
  mechanize = Mechanize.new
  @page = mechanize.get('http://meteo.ua/ua/archive/44/lvov')
  
  @browser = Watir::Browser.new 
  @browser.goto('http://meteo.ua/ua/archive/44/lvov')
end

def date
  get_page

  @browser.div(id: 'datepicker').click
  @browser.select(class: 'ui-datepicker-year').options[0].click #year
  @browser.select(class: 'ui-datepicker-year').options[0].click #year
  @browser.div(id: 'datepicker').click
        
    
  CSV.open("weather_2003.csv",'wb', col_sep: ";", encoding: "UTF-8") do |csv|
    csv << ['Час і дата','Характеристики погоди','Температура повітря','Вітер м/с','Атм.тиск','Вологість повітря %', 'Напрям вітру']
      12.times do |t|
        #t += 11
        n = 1
        m_day = days(t + 1) 
        
        @browser.div(id: 'datepicker').click
        @browser.select(class: 'ui-datepicker-month').options[t].click #month
        @browser.div(id: 'datepicker').click
        
        while n <= m_day do
          @browser.div(id: 'datepicker').click
          if n < 15
            @browser.links(text: n.to_s).first.click
          else
            @browser.links(text: n.to_s).last.click
          end
          @page = Mechanize::Page.new(nil, {'content-type'=>'text/html'}, @browser.html, nil, Mechanize.new)
          get_weather(csv,n)
          n += 1
        end
      end
  end
end

def get_weather(csv, n)
  current_date_s = @page.at('span.txt_districts').text.strip[2..13]
  current_date_s = Date.parse(current_date_s).to_s
  
  table = @page.at('table.archive_table') #get table
  columns = []
  table.css('tr').each_with_index do |tr,i| #get rows
    next if i == 0
    columns << tr.css('td').text.tr('\n','').split(' ') #get columns
    columns[i-1][0] = current_date_s + ' ' + columns[i-1][0]
    
    if columns[i-1].size == 4
      col = columns[i-1][1] + ' ' + columns[i-1][2]
      columns[i-1][1] = col
      columns[i-1][2] = columns[i-1][3]
      columns[i-1][3] = ' '
    elsif columns[i-1].size == 5
      col = columns[i-1][1] + ' ' + columns[i-1][2] + ' ' + columns[i-1][3]
      columns[i-1][1] = col
      columns[i-1][2] = columns[i-1][4]
      columns[i-1][3] = ' '
      columns[i-1][4] = ' '
    elsif columns[i-1].size == 6
      col = columns[i-1][1] + ' ' + columns[i-1][2] + ' ' + columns[i-1][3] + ' ' + columns[i-1][4]
      columns[i-1][1] = col
      columns[i-1][2] = columns[i-1][5]
      columns[i-1][3] = ' '
      columns[i-1][4] = ' '
      columns[i-1][5] = ' '
    elsif columns[i-1].size == 7
      col = columns[i-1][1] + ' ' + columns[i-1][2] + ' ' + columns[i-1][3] + ' ' + columns[i-1][4] + ' ' + columns[i-1][5]
      columns[i-1][1] = col
      columns[i-1][2] = columns[i-1][6]
      columns[i-1][3] = ' '
      columns[i-1][4] = ' '
      columns[i-1][5] = ' '
      columns[i-1][6] = ' '
    end 
      
    col = columns[i-1][2]
    if columns[i-1][2].index('C') == 4 || columns[i-1][2].index('C') == 5   
      columns[i-1][2] = col[0..4].to_i
      columns[i-1][3] = col[5..7].to_i
      columns[i-1][4] = col[8..10]
      columns[i-1][5] = col[11..14]
    elsif columns[i-1][2].index('C') == 3 || columns[i-1][2].index('C') == 2
      columns[i-1][2] = col[0..3].to_i
      columns[i-1][3] = col[4..6].to_i
      columns[i-1][4] = col[7..9]
      columns[i-1][5] = col[10..13]
    end 
    columns[i-1][6] = tr.at('td.at_winter img').values[2]
  end 
  
  columns.each_with_index do |column,i|
    csv << columns[i]
  end
  puts current_date_s
end

def days(month)
  if month == 2
    days = 28
  elsif month.odd?
    days = 31
  elsif month.even? 
    days = 30
  end

  days
end