class Main < Sinatra::Base
  enable :sessions

  get '/' do
    slim :'login'
  end

  post '/login' do
    user = User.first(username: params[:username])
    if user && user.password == params[:password]
      session[:user] = user.id
      redirect "/user/#{user.id}"
    else
      return 403, 'Invalid username or password. Please try again!'
    end
  end

  get '/user/:id' do |id|
    if session[:user] == id.to_i
      @user = User.get(session[:user])
    end
    slim :'user/index'
  end

  post '/register' do
    slim :'register'
  end

  post '/adduser' do
    User.create(username: params[:regusername], password: params[:regpassword]).save
    redirect '/'
  end

  post '/addbudget' do
  ## SAVE BITCH
    redirect '/overview'
  end

  get '/overview' do
    slim :'overview'
  end

end