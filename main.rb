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
    slim :user/index
  end

  post '/register' do
    slim :'register'
  end

  post '/adduser' do
    User.create(username: params[:regusername], password: params[:regpassword]).save
    redirect '/'
  end

  post '/addbudget' do
    Budget.create(income: params[:income], food: params[:food], clothes: params[:clothes], loans: params[:loans], leisures: params[:leisures], amorizations: params[:amorizations], misc: params[:misc], savings: params[:savings], unspent: 10, date: params[:date], user_id: params[:user_id])
    redirect '/overview'
  end

  get '/overview' do
    slim :'overview'
  end

  get '/stats' do
    File.read(File.join('views', 'stats.html'))
  end


  get '/home' do
    redirect '/login'
  end

end