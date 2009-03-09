module Wesabe::Stats
  
  class Tag::GroupByWeek < Wesabe::Stats::Tag
    include Enumerable
    
    def each (&block)
      @container.weeks.each do |week|
        tag_wk_total = 0.0
        tag_wk_count = 0
        @txactions.each do |txaction|
          if txaction.date > week[0] && txaction.date < week[1]
            tag_wk_total += txaction.amount
            tag_wk_count += 1
          end
        end
        
        block.call(week,tag_wk_total,tag_wk_count)
      end
    end
    alias :each_week :each
  end
  
  class Tags::InMonthGroupByWeek < Wesabe::Stats::Tags
    attr_reader :weeks
    
    def initialize (sdate)
      super()
      @tag_klass = Wesabe::Stats::Tag::GroupByWeek
      @weeks     = Wesabe::Stats::Util.calculate_weeks_in_month_for_date(sdate)
    end
    
    def add (txaction)
      tag_name = txaction.tags[0]
        
      case @tags.has_key?(tag_name)
        when true: tag = @tags[tag_name]
        else       tag = @tags[tag_name] = @tag_klass.new(tag_name,self)
      end
        
      tag.txactions << txaction
    end
    
    def each_week (&block)
      @weeks.each do |week|
        @tags.each_value do |tag|
          tag_wk_total = 0.0
          tag_wk_count = 0
          tag.txactions.each do |txaction|
            if txaction.date > week[0] && txaction.date < week[1]
              tag_wk_total += txaction.amount
              tag_wk_count += 1
            end
          end
          
          block.call(week,tag,tag_wk_total,tag_wk_count)
        end
      end
    end
  end
end


