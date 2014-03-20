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



  get '/register' do
    slim :'register'
  end



  post '/adduser' do
    User.create(username: params[:regusername], password: params[:regpassword]).save
    redirect '/'
  end



  post '/addbudget' do
    Budget.create(income: params[:income], food: params[:food], clothes: params[:clothes], loans: params[:loans], leisures: params[:leisures], amorizations: params[:amorizations], misc: params[:misc], savings: params[:savings], date: params[:date], user_id: params[:user_id])
    redirect '/overview'
  end



  get '/overview' do
    @user = User.get(session[:user])
    @newdate = Budget.get(session[:date])
    @date = Budget.last.date
    if @newdate
      @date = @newdate
    end
    @totalsavings = Budget.sum(:savings, user: @user)
    @food_avg = Budget.avg(:food, user: @user).round
    @clothes_avg = Budget.avg(:clothes, user: @user).round
    @loans_avg = Budget.avg(:loans, user: @user).round
    @leisures_avg = Budget.avg(:leisures, user: @user).round
    @amorizations_avg = Budget.avg(:amorizations, user: @user).round
    @misc_avg = Budget.avg(:misc, user: @user).round
    @savings_avg = @totalsavings
    @income = Budget.last.income
    @totalunspent = -Budget.last.food - Budget.last.clothes - Budget.last.loans - Budget.last.leisures - Budget.last.amorizations - Budget.last.misc - Budget.last.savings + Budget.last.income
    @failcheck = Budget.last(user: @user, date: @date)
    if @failcheck
      @lastbudget = Budget.last(user: @user, date: @date)
    else
      @lastbudget = Budget.first_or_create(:food => 0, :clothes => 0, :loans => 0, :loans => 0, :leisures => 0, :amorizations => 0, :misc => 0, :savings => 0)
      @totalunspent = 0
      @income = 0
    end
    if @totalunspent < 0
      @warning = "You have less income than expenses and you have lost money this month. Consider the following:"
      if Budget.last.food > @food_avg
        @foodwarning = "Eat at cheaper places or try to buy cheaper groceries"
      end
      if Budget.last.clothes > @clothes_avg
        @clotheswarning = "Try to use old clothes instead of buying new ones"
      end
      if Budget.last.loans > @loans_avg
        @loanswarning = "See if you can cut down the payment loan for a while"
      end
      if Budget.last.leisures > @leisures_avg
        @leisureswarning = "Spend more time at home and try not to buy things you won't use"
      end
      if Budget.last.amorizations > @amorizations_avg
        @amorizationswarning = "Spend less on amorizations for a while."
      end
      if Budget.last.misc > @misc_avg
        @miscwarning = "Try to keep the spending on things you don't need to a minimum"
      end
      if Budget.last.savings > 0
        @savingswarning = "You have (#{@totalsavings}) in savings, use it"
      end
    end
    slim :'overview'
  end



  get '/stats' do
#    File.read(File.join('views', 'stats.html'))
  end



  get '/home' do
    redirect '/login'
  end



  get '/history' do
    @user = User.get(session[:user])
    @budgetcounts = Budget.all(user: @user)
    slim :'history'
  end



  get '/newdate' do
    #@newdate = params[:newdate]
    session[:date] = params[:newdate]
    redirect '/overview'
  end



end