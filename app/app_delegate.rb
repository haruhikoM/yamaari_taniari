class AppDelegate
  Properties       = [ 'Year', 'Date', 'Weight', 'Body Fat', 'Activities' ]
  SecondPropertirs = [ '', '目標体重', '開始時体重', '身長' ]
  ThirdPropertirs  = [ '', '最低体重', '最高体重' ]

  def main(argc, argv)
    if argc < 2
      NSLog error_msg = <<ERROR_MESSAGE

=====================================================================
Please put a Path of your bakcup file after the command names as an
argument.
=====================================================================

Usage:
  yamaari_taniari path/to/your/backupData.json

ERROR_MESSAGE

      return
    end
    unless argv.any? { |arg| arg.end_with? 'json' }
      NSLog error_msg = <<ERROR_MESSAGE

=====================================================================
You need to specify a file and it ought to be a JSON format!
=====================================================================

ERROR_MESSAGE
      return
    end
    open_numbers_with argv.last
  end

  def open_numbers_with arg
    file_path = arg

    unless numbers_app = SBApplication.applicationWithBundleIdentifier("com.apple.iwork.numbers")
      NSLog error_msg = <<ERROR_MESSAGE

==========================================
This app requires Numbers.app. Sorry.
=========================================

ERROR_MESSAGE
      return
    end

    if numdoc = numbers_app.classForScriptingClass('document').alloc.init #NumbersDocument
      numbers_app.documents << numdoc
    end

    numbers_app.documents.first.sheets.first.name = 'All Records'
    # get the table
    table = numbers_app.documents.first.sheets.first.tables.first
    # table configuration [name, rowcount, columncount]
    table.name = "Your Weight History"

    @parser = NestlerX::Parser.new

    # # Get File
    p file_path
    url = NSURL.URLWithString file_path
    jsonData = NSData.dataWithContentsOfFile url
    error  = Pointer.new '@'
    backup_data = NSJSONSerialization.JSONObjectWithData( jsonData,
                                                 options: 0,
                                                   error: error )
    unless backup_data
      NSLog "Cannot find proper backup data. Sorry."
      return
    end

    @parsed_array = @parser.parse_list backup_data
    monthlyAverages = @parser.calcAverage

    # # NSLog "response.length => #{response.length.kind_of? NSInteger}"
    table.rowCount = @parser.recordedDates.length.intValue + AppDelegate::Properties.length.intValue + 5
    table.columnCount = 5

    titles = AppDelegate::Properties.map(&:upcase)
    # set title
    table.rows[0].cells.each_with_index do |cell, idx|
      #cell.value = response[0][idx]
      cell.value = titles[idx]
      cell.backgroundColor = CellColor.yellow
    end

    date_formatter = NSDateFormatter.new
    date_formatter.dateFormat = "MMMM dd"
    month_symbols = date_formatter.monthSymbols

    # [ {20140430 => {weight: 75, bodyFat: 16, activies: [4, 10]}, {...}, {...} ]
    # [{ 2011 => [ {0101 => {weight: 75.0, bodyFat: 17,...}, {0102 => {...}}, {} ], { 2012 => {} }]

    i = 0
    year_flag = nil
    #background_color_array = [ :redColor, :blueColor, :yellowColor, :greenColor, :redColor ] #:lightGrayColor, :grayColor]
    background_color_array = [ :yellow, :purple, :blue, :green, :orange ] #:lightGrayColor, :grayColor]
    background_color = nil

    table.rows[1..-1].zip(@parsed_array) do |row, content|
      #row.cells[0].value = date_formatter.stringFromDate NSDate.dateWithNaturalLanguageString(content[0])
      #p row, content
      if content
        year = content[:date].to_s[0..3]
        if row
          if year != year_flag
            row.cells[0].value = year
            background_color = background_color_array[year[3].to_i]
            year_flag = year
          end
          # # Year # #
          #row.cells[0].backgroundColor = NSColor.__send__(background_color).colorWithAlphaComponent 0.2
          row.cells[0].backgroundColor = CellColor.__send__(background_color)

          # # Date # #
          date_string = content[:date].to_s.insert(4, '-').insert(-3, '-')
          row.cells[1].value = date_formatter.stringFromDate NSDate.dateWithNaturalLanguageString date_string

          # # Weight # #
          row.cells[2].value = content[:weight]
          cell_color = :green
          if @prev_weight && content[:weight]
            cell_color = content[:weight] > @prev_weight ? :red : :blue if content[:weight] != @prev_weight
          end
          row.cells[2].backgroundColor = CellColor.__send__ cell_color
          @prev_weight = content[:weight] if content[:weight]

          # # BodyFat # #
          row.cells[3].value = content[:bodyFat]
          row.cells[4].value = content[:activities].to_s
          i += 1
        end
      end
      #row.cells[0].value = date_formatter.stringFromDate NSDate.dateWith
    end
    # fill the cells
    #table.rows[1..-1].zip(response[1..-1]) do |row, content|
    #row.cells[0].value = date_formatter.stringFromDate NSDate.dateWithNaturalLanguageString(content[0])
    #row.cells[1].value = content[1].gsub('.', ',')
    #row.cells[2].value = content[2].gsub('.', ',')
    #rowocells[3].value = content[3].gsub('.', ',')
    #end


    # select cells
    table.setSelectionRange table.cellRange

    table = numbers_app.documents.first.sheets.first.tables.first

    # NumbersSheet.new
    new_sheet = numbers_app.classForScriptingClass('sheet').alloc.initWithProperties( { name: 'Summary' } )
    #new_sheet.name = "Summary"
    numbers_app.documents.first.sheets << new_sheet

    second_table = new_sheet.tables.first
    second_table.name = 'Your Basic Data'
    second_table.rowCount = 2
    second_table.columnCount = AppDelegate::SecondPropertirs.length

    second_table.rows[0].cells.each_with_index do |cell, idx|
      cell.value = AppDelegate::SecondPropertirs[idx]
      cell.backgroundColor = CellColor.yellow
    end

    stats_table = numbers_app.classForScriptingClass('table').alloc.initWithProperties( { name: 'Stats Summary' } )
    new_sheet.tables << stats_table

    stats_table.rowCount = 2
    stats_table.columnCount = AppDelegate::ThirdPropertirs.length

    stats_table.rows[0].cells.each_with_index do |cell, idx|
      cell.value = AppDelegate::ThirdPropertirs[idx]
      cell.backgroundColor = CellColor.yellow
    end

    stats_table.rows[1].cells.each_with_index do |cell, idx|
      case idx
      when 1
        cell.value = @parser.lowestWeight
      when 2
        cell.value = @parser.heighestWeight
      end
    end

    new_table = numbers_app.classForScriptingClass('table').alloc.initWithProperties( { name: 'Monthly Data' } )
    new_sheet.tables << new_table

    new_table.columnCount = 2
    # NumbersNMCTDateAndTime = 'fdtm'

    new_table.rows[0].cells.each_with_index do |cell, idx|
      case idx
        # when 0
        # cell.value = 'Year'
      when 0
        cell.value = 'Month-Year'
      when 1
        cell.value = 'Average Weight'
      end
      cell.backgroundColor = CellColor.yellow
    end

    years = monthlyAverages.keys
    monthlyArray = monthlyAverages.values.map { |mnt| mnt.to_a }

    new_table.rowCount = monthlyArray.flatten.length / 2 + 1

    # new_table.rows[1..-1].cells.each_with_index do |cell, idx|
    # new_table.rows[1..-1].zip(monthlyArray) do |row, content|
    @currentYear = nil
    @tempMonthArray = []

    date_formatter.dateFormat = "MMMM-yyyy"

    new_table.rows[1..-1].each_with_index do |row, idx|
      if @currentYear.nil?
        @currentYear = years.shift
        # row.cells[0].value = @currentYear
      end

      if @tempMonthArray.empty?
        @tempMonthArray = monthlyArray.shift
        break if @tempMonthArray.nil?
      end
      currentData = @tempMonthArray.shift
      date_string = @currentYear.to_s + '-' + currentData[0] + '-01' + ' 00:00:00 -0900'
      row.cells[0].value = date_formatter.stringFromDate NSDate.dateWithString date_string
      row.cells[1].value = currentData[1]
      if @tempMonthArray.empty?
        @currentYear = nil
      end
    end

    new_table.setSelectionRange new_table.cellRange
    # new_table.columns[0].format = NumbersNMCTDateAndTime
    # create charts
    #numbers_process.menuBars.first.menuBarItems[4].menus[0].menuItems[3].menus[0].menuItems[1].clickAt(1)
  end
end

class NoJSONFileError < StandardError; end

module Numbers
end
