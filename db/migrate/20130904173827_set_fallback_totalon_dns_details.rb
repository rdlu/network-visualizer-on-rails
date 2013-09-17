class SetFallbackTotalonDnsDetails < ActiveRecord::Migration
  def up
    puts "Setando os valores de total de testes DNS para 10"
    execute <<-SQL
      UPDATE dns_details SET "total" = 10
    SQL
  end

  def down
  end
end
