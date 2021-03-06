DB_CONFIG = YAML.load_file(File.expand_path("../../../config/database.yml", __FILE__))

namespace :db do
  desc "Pull production database into the local development environment."
  task :pull do
    puts cmd = "pg_dump -h fringe.inf.ufrgs.br -U mom-rails mom-rails_production -c | psql -U mom-rails mom-rails_development"
    system cmd
    puts "Done."
  end

  desc "Pull production database into the local development environment. (With a temporary SQL file)"
  task :pull2 do
    puts cmd = "pg_dump -h fringe.inf.ufrgs.br -U mom-rails mom-rails_production -W > production.sql"
    system cmd
  	puts cmd = "cat production.sql | psql -U mom-rails mom-rails_development -W"
  	system cmd
  	puts cmd = "rm production.sql"
  	system cmd
    puts "Done."
  end

  desc "Pull production database into the local development environment. (with pg_wrapper support)"
  task :pull_with_wrapper do
    puts cmd = "pg_dump --cluster 9.1/main -h fringe.inf.ufrgs.br -U mom-rails mom-rails_production -c | psql --cluster 9.1/main -U mom-rails mom-rails_development"
    system cmd
    puts "Done."
  end



  desc "Updates the PostgreSQL Sequences after importation from SQL scripts"
  task :pgsql_fix_seq do
	ActiveRecord::Base.establish_connection(DB_CONFIG[Rails.env])
    ActiveRecord::Base.connection.tables.each do |table|
      begin
        result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
        if result.any?
          ai_val = result.first['id'].to_i + 1
          puts "Resetting auto increment ID for #{table} to #{ai_val}"
          ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
        end
      rescue Exception => e
        puts e
      end
    end
  end
end
