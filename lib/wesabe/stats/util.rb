module Wesabe::Stats::Util
  extend self
  
  def ordinal_suffix (number)
    return case number
      when 0: ''
      when 1: 'st'
      when 2: 'nd'
      when 3: 'rd'
      else    'th'
    end
  end
  
  def calculate_weeks_in_month_for_date ( initial=Time.now )
    weeks = []
    fday  = Chronic.parse('first day this month', :now => initial)
    fday  = Time.local(fday.year, fday.month, fday.day, 0,0,0)
    
    lday  = Chronic.parse('first day next month', :now => initial)
    lday  = Time.local(lday.year, lday.month, lday.day, 0,0,0) - 1
    
    ## setup the entry for the first week
    weeks << [ fday, Chronic.parse('next saturday', :now => fday)]
    
    ## now deal with subsquent weeks
    (1..4).each do |idx|
      a = Chronic.parse('next sunday',   :now => weeks[idx-1][1])
      a = Time.local(a.year, a.month, a.day, 0, 0, 0)
      
      b = Chronic.parse('next saturday', :now => weeks[idx-1][1]) 
      b = Time.local(b.year, b.month, b.day, 0, 0, 0)
      
      pair = [a, b]
      
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
