module Wesabe::Stats::Util
  extend self
  
  def calculate_weeks_in_month_for_date ( initial=Time.now )
    weeks = []
    fday  = Chronic.parse('first day this month', :now => initial)
    lday  = Chronic.parse('first day next month', :now => initial) - 86400
    
    ## setup the entry for the first week
    weeks << [ fday, Chronic.parse('next saturday', :now => fday ) ]
    
    ## now deal with subsquent weeks
    (1..4).each do |idx|
      pair = [ 
        Chronic.parse('next sunday',   :now => weeks[idx-1][1]),
        Chronic.parse('next saturday', :now => weeks[idx-1][1]) 
      ]
      
      ## if the FIRST day of this pair is past the end of the month there's
      ## no need to continue. if the LAST day of this pair is past the end 
      ## of this month then set it to the LAST day of the month.
      break          if pair[0] > lday
      pair[1] = lday if pair[1] > lday
    
      weeks << pair
    end
    
    return weeks
  end
  
end
