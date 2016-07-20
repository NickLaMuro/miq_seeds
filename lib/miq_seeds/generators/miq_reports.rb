# Public:  Generate a number of test Service records, uniquely named
#
module MiqSeeds
  class MiqReports
    def self.documentation
      <<-DOCS.gsub(/^ {8}/, '')
        MiqReports Generator:

        Generates a specified number of MiqReports, MiqReportResults, and
        MiqTasks to simulate a reports being run.  Doesn't generate any report
        data (yet).

        count      - The number of Reports to create.  Can be either an
                     integer, or an array.  If it is an integer, that
                     represents then number of reports to generate, and the
                     number of report results for each is random.  If an array,
                     the values are the number of report results to generate
                     per report (default: 100)
        group_name - The group desc the reports should fall under
                     (default: "EvmGroup-user_self_service")

        Relvant Routes:
          - /report/explorer

        Examples

          MiqSeeds.generate :miq_reports
          => # Generates 50 reports, with a random number of 1-100 report
             # results each

          MiqSeeds.generate :miq_reports, 5
          => # Generates 5 reports with a random number of 1-100 reports
             # results each
             #

          MiqSeeds.generate :miq_reports, [1000, 2000, 3000, 4000, 5000]
          => # Generates 5 reports, with the number of report results dictated
             # by the integer of each element of the array

      DOCS
    end

    def self.analyze
      [ seed_array ]
    end

    def initialize(count=nil, group_name="EvmGroup-user_self_service")
      @count = count || 50
      miq_group group_name
    end

    def generate
      if @count.is_a? Integer
        @count.times do |n|
          generate_report "Test %04d" % (n+1)
        end
      elsif @count.is_a? Array
        @count.size.times do |n|
          generate_report "Test %04d" % (n+1), @count[n]
        end
      end
    end

    private

    def generate_report name, number_of_results=nil
      report_result_count = number_of_results || rand(100)
      report = ::MiqReport.create! :name => name,
                                   :title => name,
                                   :db => 'test',
                                   :miq_group_id => miq_group.id,
                                   :rpt_group => 'test',
                                   :rpt_type => 'Custom'

      report_result_count.times do |n|
        task = ::MiqTask.create!

        # Doesn't seem like you can initialize these attributes on create
        task.update_attributes! :state  => miq_task_states.sample.first,
                                :status => miq_task_statuses.sample.first

        ::MiqReportResult.create! :name => name,
                                  :report => report,
                                  :last_run_on => (n+1).day.ago,
                                  :miq_task_id => task.id,
                                  :miq_report_id => report.id,
                                  :miq_group_id => miq_group.id
      end
    end

    def miq_group name=nil
      refresh_miq_group = @miq_group.nil? || name && @miq_group.name != name
      return @miq_group unless refresh_miq_group

      @miq_group = ::MiqGroup.where(:description => name).first
    end

    def miq_task_states
      ::MiqTask.validators.detect {|v| v.attributes.include? :state  }.options[:in]
    end

    def miq_task_statuses
      ::MiqTask.validators.detect {|v| v.attributes.include? :status }.options[:in]
    end

    def seed_array
      report_ids = MiqReport.having_report_results.pluck(:id)
      MiqReportResult.where(:miq_report_id => report_ids)
                     .group(:miq_report_id)
                     .pluck('COUNT(id) AS count')
                     .sort.reverse
    end
  end
end
