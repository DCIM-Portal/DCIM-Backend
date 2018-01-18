class BmcHostSplitSystemModelIntoBrandAndProduct < ActiveRecord::Migration[5.1]
  def up
    add_column :bmc_hosts, :brand, :string
    add_column :bmc_hosts, :product, :string

    BmcHost.all.each do |bmc_host|
      if bmc_host.system_model.is_a? String
        brand, product = bmc_host.system_model.split(' ', 2)
        bmc_host.update(brand: brand, product: product)
      end
    end

    remove_column :bmc_hosts, :system_model
  end

  def down
    add_column :bmc_hosts, :system_model, :string

    BmcHost.all.each do |bmc_host|
      bmc_host.update(system_model: [bmc_host.brand, bmc_host.product].join(' ')) if bmc_host.brand.is_a?(String) && bmc_host.product.is_a?(String)
    end

    remove_column :bmc_hosts, :brand
    remove_column :bmc_hosts, :product
  end
end
