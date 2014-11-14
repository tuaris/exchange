class AddSuperToOauthApplications < ActiveRecord::Migration
  def change
    add_column :oauth_applications, :super, :boolean
  end
end
