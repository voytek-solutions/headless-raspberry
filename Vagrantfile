
rootDir = File.expand_path('.')

Vagrant.configure(2) do |config|

	config.vm.box = "ubuntu/xenial64"
	config.vm.box_check_update = true

	config.ssh.forward_agent = true

	config.vm.provider :virtualbox do |vb|
		vb.customize ["modifyvm", :id, "--memory", 1024]
		vb.customize ["modifyvm", :id, "--cpus", 1]
		vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
		vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
	end

	config.vm.provision "shell" do |shell|
		shell.inline = "ls /usr/bin/python || ( apt-get update \
			&& apt-get install python2.7 -y \
			&& ln -fs /usr/bin/python2.7 /usr/bin/python)"
	end

	config.vm.provision "ansible" do |ansible|
		ansible.playbook = "#{rootDir}/ansible/playbooks/build.yml"
		ansible.extra_vars = {
			'hosts' => 'default',
			'pwd' => rootDir,
			'image_id' => ENV['RPI_ID'],
			'role' => ENV['ROLE']
		}
		ansible.verbose = "#{ENV['VERBOSE']}" if ENV['VERBOSE']
	end
end
