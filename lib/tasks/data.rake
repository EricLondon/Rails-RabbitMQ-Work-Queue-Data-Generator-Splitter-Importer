require 'csv'

namespace :data do

  desc 'Generate data'
  task :generate, [:model, :how_many] => :environment  do |t, args|
    default_args = args.with_defaults(how_many: '1000')
    DataGenerator.new(default_args[:model], default_args[:how_many].to_i).start
  end

  desc 'Split input files'
  task split_input_files: :environment do
    CsvSplitter.split_all
  end

  desc 'Import files'
  task import_files: :environment do
    FileImporter.queue_all
  end

  desc 'Start worker'
  task start_worker: :environment do
    Worker.new.start
  end

end
