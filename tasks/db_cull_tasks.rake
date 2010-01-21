def add_to_seeds(lines)
  File.open ("#{RAILS_ROOT}/db/seeds.rb", 'a') do |f|
    lines.each do |l|
      f.puts l
    end
  end
  true
end

namespace :db do
  # rake syntax is crazy.
  # task name: sow
  # sole argument: table
  # dependency: environment task
  # example: rake db:sow[person]
  # result: in an empty db, you can write rake db:seed to get the data back.
  desc "Copy all data from table into seeds.rb"
  task :sow, [:table] => :environment do |t, args|

    begin
      model = args.table.classify.constantize
      #model.descends_from_active_record? # no method error if not AR
    rescue
      puts "Error: no such ActiveRecord class."
    end

    unless model.nil?
      lines = []
      lines << "# Seeds sown from database using db_sow"
      lines << "#   Table:  #{model}"
      lines << "#   Schema: #{ActiveRecord::Migrator.current_version}"
      lines << "#   Added:  #{Time.now}"
      lines << ""

      create = "  #{model}.create! ( "
      indent = Array.new(create.size, ' ').join

      count = 0
      model.all.each do |record|
        count += 1
        prefix = create

        lines << "  # Retrieved from organiztion ##{record.id}"
        record.attributes.each do |att, val|
          next if att == model.primary_key
          lines << prefix + ":#{att} = \"#{val}\","
          prefix = indent
        end
        lines.last.chop! # get rid of that last comma
        lines.last  << " )"
      end
      lines << ""
      lines << "# (end of #{model} seeds)"
      lines << ""
      if add_to_seeds(lines)
        puts "Wrote #{count} entries to db/seeds.rb"
      else
        puts "Error"
      end
    end
  end
end

