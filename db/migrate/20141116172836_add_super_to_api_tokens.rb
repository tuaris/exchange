class AddSuperToAPITokens < ActiveRecord::Migration
  def change
    add_column :api_tokens, :super, :boolean, default: false
  end
end
