# inspired by opscode::users, chef-solo-search
def whyrun_supported?
  true
end

def initialize(*args)
  super
  @action = :create
end

action :remove do
  search_data_bag(new_resource.data_bag, "#{new_resource.search_group}") do |u|
    user u['username'] ||= u['id'] do
      action :remove
    end
  end
  new_resource.updated_by_last_action(true)
end

action :create do
  security_group = Array.new

  search_data_bag("#{new_resource.data_bag}", "#{new_resource.search_group}").each do |u|
    u['username'] ||= u['id']
    security_group << u['username']

    if node['apache'] and node['apache']['allowed_openids']
      Array(u['openid']).compact.each do |oid|
        node.default['apache']['allowed_openids'] << oid unless node['apache']['allowed_openids'].include?(oid)
      end
    end

    # Set home to location in data bag,
    # or a reasonable default (/home/$user).
    if u['home']
      home_dir = u['home']
    else
      home_dir = "/home/#{u['username']}"
    end

    # The user block will fail if the group does not yet exist.
    # See the -g option limitations in man 8 useradd for an explanation.
    # This should correct that without breaking functionality.
    if u['gid'] and u['gid'].kind_of?(Numeric)
      group u['username'] do
        gid u['gid']
      end
    end

    # Create user object.
    # Do NOT try to manage null home directories.
    user u['username'] do
      uid u['uid']
      if u['gid']
        gid u['gid']
      end
      shell u['shell']
      comment u['comment']
      password u['password'] if u['password']
      if home_dir == "/dev/null"
        supports :manage_home => false
      else
        supports :manage_home => true
      end
      home home_dir
      action u['action'] if u['action']
    end

    if home_dir != "/dev/null"
      directory "#{home_dir}/.ssh" do
        owner u['username']
        group u['gid'] || u['username']
        mode "0700"
      end

      if u['ssh_keys']
        template "#{home_dir}/.ssh/authorized_keys" do
          source "authorized_keys.erb"
          cookbook new_resource.cookbook
          owner u['username']
          group u['gid'] || u['username']
          mode "0600"
          variables :ssh_keys => u['ssh_keys']
        end
      end

      if u['ssh_private_key']
        key_type = u['ssh_private_key'].include?("BEGIN RSA PRIVATE KEY") ? "rsa" : "dsa"
        template "#{home_dir}/.ssh/id_#{key_type}" do
          source "private_key.erb"
          cookbook new_resource.cookbook
          owner u['id']
          group u['gid'] || u['id']
          mode "0400"
          variables :private_key => u['ssh_private_key']
        end
      end

      if u['ssh_public_key']
        key_type = u['ssh_public_key'].include?("ssh-rsa") ? "rsa" : "dsa"
        template "#{home_dir}/.ssh/id_#{key_type}.pub" do
          source "public_key.pub.erb"
          cookbook new_resource.cookbook
          owner u['id']
          group u['gid'] || u['id']
          mode "0400"
          variables :public_key => u['ssh_public_key']
        end
      end
    end
  end

  group new_resource.group_name do
    if new_resource.group_id
      gid new_resource.group_id
    end
    members security_group
  end
  new_resource.updated_by_last_action(true)
end

def search_data_bag(bag_name, group)
  results = []
  data_bag("#{bag_name}").each do |bag_item_name|
    bag_item = load_data_bag_item("#{bag_name}", "#{bag_item_name}")

    groups = bag_item['groups'].is_a?(Array) ? bag_item['groups'] : [ bag_item['groups'] ]
    if groups.include?("#{group}")
      results << bag_item
    end
  end

  return results
end

def load_data_bag_item(bag_name, bag_item_name)
  if Chef::Config[:encrypted_data_bag_secret]
    bag_item = Chef::EncryptedDataBagItem.load("#{bag_name}", "#{bag_item_name}").to_hash
  end

  bag_item ||= data_bag_item("#{bag_name}", "#{bag_item_name}")
end
