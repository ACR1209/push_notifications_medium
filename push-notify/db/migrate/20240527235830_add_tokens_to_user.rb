class AddTokensToUser < ActiveRecord::Migration[7.1]
  def change
    create_table :tokens do |t|
      t.belongs_to :user
      t.string :token
    end
  end
end
