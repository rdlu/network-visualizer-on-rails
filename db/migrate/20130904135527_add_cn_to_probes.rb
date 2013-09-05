class AddCnToProbes < ActiveRecord::Migration
  def up
    add_column :probes, :cn, :integer
    puts "Adicionada coluna CN"
    Probe.inheritance_column = 'type2'
    Probe.reset_column_information
    Probe.all.each do |probe|
      Probe.cns.each do |cn|
        if cn[0] == probe.state.upcase
          probe.cn = cn[1]
          break
        end
      end
      puts "Atualizando info da sonda #{probe.name} com CN #{probe.cn}"
      probe.save
    end
  end

  def down
    remove_column :probes, :cn
  end
end
