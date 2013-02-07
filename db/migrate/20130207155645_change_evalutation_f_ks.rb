class ChangeEvalutationFKs < ActiveRecord::Migration
  def up
    remove_foreign_key :evaluations, name: :tests_schedule_id_fk
    add_foreign_key :evaluations, :schedules, dependent: :delete
  end

  def down
  end
end
