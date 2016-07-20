# Public:  Generate a number of test Service records, uniquely named
#
module MiqSeeds
  class Services
    def self.documentation
      <<-DOCS.gsub(/^ {8}/, '')
        Services Generator:

        Creates a speicified number of Service records that are uniquely named.

        count - The number of Service records to create (default: 9001)

        Relvant Routes:
          - /service/explorer
      DOCS
    end

    def self.analyze
      [ Service.where.not(:ancestry => nil).count ]
    end

    def initialize(count=nil)
      @count = count || 9001
    end

    def generate
      @count.times do |n|
        ::Service.create :name => "Test %04d" % (n+1)
      end
    end
  end
end
