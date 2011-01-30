class RenameHostColumnToHosts < ActiveRecord::Migration
  def self.up
    rename_column :podcasts, :host, :hosts
  end

  def self.down
    rename_column :podcasts, :hosts, :host
  end
end
