namespace :db do
  desc "Pull production database into the local development environment."
  task :pull do
    puts cmd = "mysqldump -h fringe.inf.ufrgs.br -u mom-rails-ro --password=Onk37EJd mom-rails_production --set-gtid-purged=OFF --skip-lock-tables | mysql -u mom-rails --password=A2VuLGfhzuauMfBT mom-rails_development"
    system cmd
    puts "Done."
  end
end
