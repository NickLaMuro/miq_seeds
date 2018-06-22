module MiqSeeds
  class VmInfraExplorer
    SUBTREE_DATA = {
      :datacenters => ->(base){ base.children(
      :folders     =>
      :vms         =>
    }
    def self.documentation
      <<-DOCS.gsub(/^ {8}/, '')
        VmInfraExplorer Generator:

        Generates ExtManagementSystems, Datacenters, EmsFolders, and Vms to
        provide data for the `/vm_infra/explorer` route.

        ems_count - The number of ExtManagementSystems to generate (default: 5)
        tree_data - Array of Hashes that represents the structure, in order,
                    of what data should fall under each ExtManagementSystem
                    (Datacenters, Folders, Vms), and defaults to the random
                    ones after that.  This hash structure can be nested:
                    :datacenters - Number of hash.  Hash can be nested with
                                   more of these keys.
                    :folders     - Number of hash.  Hash can be nested with
                                   more of these keys.
                    :vms         - Number of hash.  Hash can be nested with
                                   more of these keys.

        Relvant Routes:
          - /vm_infra/explorer

        Examples

          MiqSeeds.generate :miq_reports
          => # Generates 5 ExtManagementSystems, with a random number of 1-3
             # Datacenters, and 1-50 Vms a piece

          MiqSeeds.generate :miq_reports, 3
          => # Generates 3 ExtManagementSystems, with a random number of 1-3
             # Datacenters, and 1-50 Vms a piece

          MiqSeeds.generate :miq_reports, 3, [{:datacenters => [{:vms => 4}]}]
          => # Generates 3 ExtManagementSystems.
             # The first EMS will have a single datacenter with 4 Vms
             # The other EMS's will have 1-50 Vms a piece
      DOCS
    end

    def self.analyze
      [
        ExtManagementSystem.count,
        analyze_subtree(ExtManagementSystem.all)
      ]
    end

    def initialize(count=5, tree_data=nil)
      @count     = count
      @tree_data = tree_data || basic_tree_data
    end

    def generate
      @count.times do |index|
        ems = create_vm_infra index

        generate_ems_structure ems, (tree_data[index] || basic_tree_data.first)
      end
    end

    private

    def create_vm_infra index
      num       = index+1
      klass     = infra_klass
      base_name = "#{klass.split('::')[-3..-1].join('::')}"

      klass.create! :name     => "base_name: %d" % num,
                    :hostname => "#{num}.#{base_name.gsub('::', '.').downcase}"
    end

    def generate_ems_structure base, tree_data
      tree_data ||= basic_tree_data.first

      tree_data.keys.each do |key|
        case tree_data[key]
        when Array
          tree_data[key].each do |data|
            child = send "generate_#{key.gsub(/s$/, '')}"
            base.set_child(folder)
            generate_ems_structure child, data
          end
        when Fixnum
          tree_data[key].times do
            child = send "generate_#{key.gsub(/s$/, '')}"
            base.set_child(folder)
          end
        end
      end
    end

    def generate_datacenter
      Datacenter.create! :name => "#{generate_acronym} - #{rand(5)}"
    end

    def generate_folder
      EmsFolder.create! :name => generate_acronym
    end

    def generate_vm
      vm_infra_klass.create! :name => generate_acronym,
                             :localtion => 'somewhere',
                             :vendor => 'vmware'
    end

    # Generate a random uppercase combination of letters between 3 and 5
    # characters long
    def generate_acronym
      (0..(rand(3)+2)).to_a.map{ |_| ("A".."Z").to_a.sample }.join
    end

    def analyze_subtree base, tree=[]
      base.each do |ems|
        subtree = {}
        subtree[:datacenters] = datacenter_subtree base
        subtree[:folders]     = folders_subtree base
        subtree[:vms]         = base.children(:of_type => "VmOrTemplate")
                                    .select { |v| v.kind_of?(MiqTemplate) }.count
      end

      tree
    end

    def datacenter_subtree base
      base
    end

    def infra_klass
      ManageIQ::Providers::Vmware::InfraManager
    end

    def vm_infra_klass
      ManageIQ::Providers::Vmware::InfraManager
    end

    def basic_tree_data
      [{:vms => rand(50)}]
    end
  end
end
