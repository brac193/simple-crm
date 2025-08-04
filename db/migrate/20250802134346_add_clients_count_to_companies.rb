class AddClientsCountToCompanies < ActiveRecord::Migration[8.0]
  def change
    add_column :companies, :clients_count, :integer, default: 0, null: false
    add_index :companies, :clients_count

    Company.find_each do |company|
      Company.reset_counters(company.id, :clients)
    end
  end
end
