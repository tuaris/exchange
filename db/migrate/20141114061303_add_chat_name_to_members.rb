class AddChatNameToMembers < ActiveRecord::Migration
  def change
    add_column :members, :nickname_for_chatroom, :string
  end
end
