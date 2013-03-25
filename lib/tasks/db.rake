namespace :db do
  desc "Pull production database into the local development environment."
  task :pull do
    puts cmd = "mysqldump -h fringe.inf.ufrgs.br -u mom-rails-ro --password=Onk37EJd mom-rails_production --set-gtid-purged=OFF --skip-lock-tables | mysql -u mom-rails --password=A2VuLGfhzuauMfBT mom-rails_development"
    system cmd
    puts "Done."
  end

  desc "Updates the PostgreSQL Sequences after importation from SQL scripts"
  task :pgsql_fix_seq do
	ActiveRecord::Base.establish_connection(DB_CONFIG['development'])
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
