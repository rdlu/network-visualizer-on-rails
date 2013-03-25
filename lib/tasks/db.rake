DB_CONFIG = YAML.load_file(File.expand_path("../../../config/database.yml", __FILE__))

namespace :db do
  desc "Pull production database into the local development environment."
  task :pull do
    puts cmd = "pg_dump -h fringe.inf.ufrgs.br -U mom-rails mom-rails_production -W > production.sql"
    system cmd
	puts cmd = "cat production.sql | psql -U mom-rails mom-rails_development -W"
	system cmd
	puts cmd = "rm production.sql"
	system cmd
    puts "Done."
  end

  desc "Updates the PostgreSQL Sequences after importation from SQL scripts"
  task :pgsql_fix_seq do
	ActiveRecord::Base.establish_connection(DB_CONFIG['development'])
    ActiveRecord::Base.connection.tables.each do |table|
		unless table == 'schema_migrations' || table == 'roles_users' # Those ones have no ID
		  result = ActiveRecord::Base.connection.execute("SELECT id FROM #{table} ORDER BY id DESC LIMIT 1")
		  if result.any?
			ai_val = result.first['id'].to_i + 1
			puts "Resetting auto increment ID for #{table} to #{ai_val}"
			ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{table}_id_seq RESTART WITH #{ai_val}")
		  end
		end
    end
  end
end
