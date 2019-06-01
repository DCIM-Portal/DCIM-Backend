class ConvertBmcHostIpAddressFieldToBinary < ActiveRecord::Migration[5.2]
  def change
    ActiveRecord::Base.transaction do
      reversible do |dir|
        dir.up do
          add_column :bmc_hosts, :ip_address_bin, :binary, limit: 16, after: :ip_address

          BmcHost.all.each do |bmc_host|
            ip = bmc_host.attributes_before_type_cast['ip_address']
            bmc_host.update_column(:ip_address_bin, IPAddr.new(ip).to_i)
          rescue StandardError => e
            p("Error while converting BmcHost #{bmc_host.id}: #{e}")
          end

          remove_column :bmc_hosts, :ip_address
          rename_column :bmc_hosts, :ip_address_bin, :ip_address

          add_index :bmc_hosts, %i[ip_address zone_id], unique: true
        end

        dir.down do
          add_column :bmc_hosts, :ip_address_string, :string, after: :ip_address

          BmcHost.all.each do |bmc_host|
            ip = bmc_host.attributes_before_type_cast['ip_address'].to_i
            bmc_host.update_column(:ip_address_string, IPAddr.new(ip, Socket::AF_INET6).native.to_s)
          rescue StandardError => e
            p("Error while converting BmcHost #{bmc_host.id}: #{e}")
          end

          remove_column :bmc_hosts, :ip_address
          rename_column :bmc_hosts, :ip_address_string, :ip_address

          add_index :bmc_hosts, :ip_address, unique: true
        end
      end
    end
  end
end
