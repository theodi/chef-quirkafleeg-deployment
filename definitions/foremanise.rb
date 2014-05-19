define :foremanise, :params => {} do

  script 'Generate foreman path environment' do
      interpreter 'bash'
      cwd params[:cwd]
      user params[:user]
      code <<-EOF
        RVMDIR=/home/#{user}/.rvm
        GEMDIR=`$RVMDIR/bin/rvm gemdir`
        RUBY=`basename $GEMDIR | cut -d '@' -f 1`
        echo "PATH=$RVMDIR/gems/$RUBY@global/bin:$RVMDIR/rubies/$RUBY/bin/" > /tmp/path_env
      EOF
  end

  script 'Start Me Up' do
    interpreter 'bash'
    cwd params[:cwd]
    user params[:user]
    code <<-EOF
        export rvmsudo_secure_path=1
        /home/#{params[:user]}/.rvm/bin/rvmsudo bundle exec foreman export \
          -a #{params[:name]} \
          -u #{params[:user]} \
          -l /var/log/#{params[:user]}/#{params[:name]} \
          -p #{params[:port]} \
          -e #{params[:cwd]}/.env,/tmp/path_env \
          upstart /etc/init
    EOF
  end
end
