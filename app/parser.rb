module NestlerX
  class Parser
    attr_reader :recordedDates, :lowestWeight, :heighestWeight

    def initialize
      @recordedDates  = nil
      @miscData       = []
      @lowestWeight   = nil
      @heighestWeight = 0
      @averageHash    = {}
    end

    def extract_keys plist
      if plist.nil?
        NSLog "== Arguments cannot be nil. =="
      else
        @keys = plist.keys.map { |key| key.slice(/[a-zA-Z]+/) }.uniq.sort
      end
    end

    def create_empty_hash_with_list plist
      list = []
      duplicateChecker = []
      plist.each_key { |k|
        if k =~ /201\d{5}/
          date = k.slice(/\d{8}/).to_i
          unless duplicateChecker.include? date
            list << {
                    date: date,
                  weight: nil,
                 bodyFat: nil,
              activities: []
                    }
            duplicateChecker << date
          end
        end
      }
      @recordedDates = duplicateChecker.sort
      list
    end

    def parse_list plist
      list = create_empty_hash_with_list plist

      plist.each { |k, v|
        if k =~ /201\d{5}/
          date = k.slice(/\d{8}/).to_i
          record = list.find { |elm| elm[:date] == date }
          if k =~ /Weight/
            weight = v.round(1)
            @lowestWeight ||= weight #if @lowestWeight.nil?
            unless weight == 0
              dateString = date.to_s
              yearString = dateString.slice!(0..3)
              @averageHash[yearString] ||= {}

              monthString = dateString.slice!(0..1)
              @averageHash[yearString][monthString] ||= []

              @averageHash[yearString][monthString] << weight
              record[:weight] = weight

              @lowestWeight   = weight if @lowestWeight > weight
              @heighestWeight = weight if @heighestWeight < weight
            end
          elsif k =~ /BodyFat/
            record[:bodyFat] = v.round(1)
          elsif k =~ /IconId/ #&& k =~ /"#{date}"/
            record[:activities] << v
          elsif k =~/Comment/
            record[:comment] = v
          else
            p k, v
          end
        elsif k =~ /DateOfOldest/
          @miscData << { DateOfOldest: v }
        end
      }
      return list.sort_by { |elm| elm[:date] }
    end

    # { year1 => { month1 => [ 75, 76, 73 ], month2 => [] } , year2 => { month1 => [], month2 => [] } }
    def calcAverage
      return if @averageHash.empty?
      averages = {}
      @averageHash.map { |k, v|
        averages[k] ||= {}
        v.map { |month, datesArray|
          monthlySum = datesArray.inject(&:+)
          averages[k][month] = ( monthlySum / datesArray.length ).round(1)
        }
      }
      yearKeys = averages.keys
      yearKeys.each { |yearKey|
        months = averages[yearKey]
        averages[yearKey] = Hash[months.sort]
      }
      return Hash[averages.sort]
    end
  end
end
