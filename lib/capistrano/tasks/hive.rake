# some vagrant-like tasks
# user can ignore tasks under 'lxc' namespace in most cases
# and be happy :P

desc 'Create a base image using bootstrap folder configurations'
task :bootstrap do
end

desc 'Launch new containers from the base image'
task :up, :name do

end

desc 'destroy container'
task :destroy, :name do
end

desc 'resume a halted container'
task :resume, :name do
end

desc 'halt container'
task :halt, :name do
end

desc 'reload container'
task :reload, :name do
end

desc 'port foward services so you can talk to container'
task :link, :name do
end

desc 'status:list available images and containers'
task :status do
end
