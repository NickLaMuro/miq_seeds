module MiqSeeds
  LIB_FOLDER      = File.dirname(File.expand_path __FILE__)
  GENERATOR_DIR   = File.join(LIB_FOLDER, 'miq_seeds', 'generators')
  GENERATOR_FILES = File.join(GENERATOR_DIR, '*.rb')

  # Public: list generators available, or display documentation for a specific
  # generator if a name is given
  #
  # For the documentation to be displayed, the generator must implement a
  # ::documentation method
  #
  # TODO:  Switch this to reading the documentation from RDOC documenation
  # comments so the documentation can also be digested in other forms
  #
  # name - The name of the generator to view documentation for (default: nil)
  #
  # Examples
  #
  #   MiqSeeds.generators
  #   # :service
  #   # :miq_reports
  #   #=> nil
  #
  #   MiqSeeds.generators :service
  #   # (displays documation from the `service` generator)
  #   #=> nil
  def self.generators(name=nil)
    if name
      puts klassify(name.to_s).documentation
    else
      Dir[MiqSeeds::GENERATOR_FILES].each do |generator|
        puts ":#{File.basename generator, '.rb'}"
      end
    end
    puts # Return nil and add an extra newline
  end


  # Public: Run the specific generator script
  #
  # generator - The name of the generator being run
  # args      - The args to be passed into the generators `initialize` method
  #
  # Examples
  #
  #   MiqSeeds.generate :service
  #   # (runs the service generator)
  #   #=> nil
  def self.generate(generator, *args)
     klassify(generator.to_s).new(*args).generate
  end

  # Public: Analyze the current database to build out a generator script based
  # on the data in the current database
  #
  # generator - The name of the generator being run
  #
  # Examples
  #
  #   MiqSeeds.analyze :service
  #   # (01.0ms)  INSERT INTO  ...
  #   # (02.0ms)  INSERT INTO  ...
  #   #=> nil
  def self.analyze(generator)
    generator_args = klassify(generator.to_s).analyze
                                             .map(&:inspect)
                                             .join(', ')

    puts "MiqSeed.generate :#{generator}, #{generator_args}"
  end

  # Public: Load all of the generators in the generator dirs
  def self.require_generators
    Dir[MiqSeeds::GENERATOR_FILES].each do |generator|
      require generator
    end
  end

  private

  def self.klassify(string)
    MiqSeeds.const_get(string.split('_').map(&:capitalize).join)
  end
end

# TODO:  Lazy load generators instead of requiring all of them at the start
MiqSeeds.require_generators
