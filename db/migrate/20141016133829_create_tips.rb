class CreateTips < ActiveRecord::Migration
  def change
    create_table :tips do |t|
      t.string :payer
      t.string :payee
      t.decimal :amount
      t.integer :currency
      t.string :msg
      t.string :source
      t.boolean :payer_settled, default: false
      t.boolean :payee_settled, default: false
      t.datetime :deleted_at

      t.timestamps
    end
  end
end
