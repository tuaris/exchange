class AddReasonToTips < ActiveRecord::Migration
  def change
    add_column :tips, :reason, :string
  end
end
