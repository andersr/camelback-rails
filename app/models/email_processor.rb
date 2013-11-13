class EmailProcessor < ActiveRecord::Base
   def self.process(email)
      
      subject_parse = email.subject
      string_parse = email.body

      if subject_parse.match(/(The Plan)/)
         plan = Plan.new
         plan.content = string_parse.match(/^(Day(\S|\s)+)^#/)
         plan.save
      end

      if subject_parse.match(/(HW|hw|Hw|Homework|lab|Lab)/)
         assignment = Assignment.new
         string_parse.match(/(https*:\/\/github.com\/(flatiron-school\/([\w-]+)))/)
         url, full_name, name = string_parse.match(/(https*:\/\/github.com\/(flatiron-school\/([\w-]+)))/).captures
         assignment.name = name #bare repo name
         assignment.url = url #url for flatiron fork
         assignment.full_name = full_name #repo name with org
         assignment.instructor = string_parse.match(/Avi Flombaum|Scott C. Reynolds|Jonathan Grover|Spencer Rogers/)
         assignment.save
      end
   end
end


