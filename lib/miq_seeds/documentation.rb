require 'rdoc'

module MiqSeeds
  class Documentation
    def self.view filename
      toplevel = RDoc::TopLevel.new 'Service'
    end
  end
end
