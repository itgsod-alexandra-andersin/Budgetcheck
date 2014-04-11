class Main < Sinatra::Base

  enable :sessions



  get '/' do
    slim :'login'
  end



  post '/login' do
    user = User.first(username: params[:username].downcase)
    if user && user.password == params[:password].downcase
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
    i = 0
    usernameerror = 0
    while i < User.last.id
      i += 1
      if params[:regusername] == User.last(id: i).username
        usernameerror = 1
      end
    end
    if usernameerror == 1
      return "Username #{params[:regusername]} already exist, please choose another"
    else
      User.create(username: params[:regusername].downcase, password: params[:regpassword].downcase).save
    end
    redirect '/'
  end



  post '/addbudget' do
    Budget.create(income: params[:income], food: params[:food], clothes: params[:clothes], loans: params[:loans], leisures: params[:leisures], amorizations: params[:amorizations], misc: params[:misc], savings: params[:savings], date: params[:date], user_id: params[:user_id])
    session[:id] = Budget.last.id
    redirect '/overview'
  end


  get '/overview' do
    @user = User.get(session[:user])
    @newdate = (session[:id])
    @id = Budget.first_or_create(id: @newdate).id
    if @newdate
      @id = @newdate
    end
    @totalsavings = Budget.sum(:savings, user: @user)
    @food_avg = Budget.avg(:food, user: @user).round
    @clothes_avg = Budget.avg(:clothes, user: @user).round
    @loans_avg = Budget.avg(:loans, user: @user).round
    @leisures_avg = Budget.avg(:leisures, user: @user).round
    @amorizations_avg = Budget.avg(:amorizations, user: @user).round
    @misc_avg = Budget.avg(:misc, user: @user).round
    @savings_avg = @totalsavings
    @lastbudget = Budget.first_or_create(:food => 0, :clothes => 0, :loans => 0, :loans => 0, :leisures => 0, :amorizations => 0, :misc => 0, :savings => 0)
    @totalunspent = 0
    @income = 0
    @failcheck = Budget.last(user: @user, id: @id)
    if @failcheck
      @lastbudget = Budget.last(user: @user, id: @id)
      @income = Budget.last(user: @user, id: @newdate).income
      @totalunspent = -Budget.last(user: @user, id: @newdate).food - Budget.last(user: @user, id: @newdate).clothes - Budget.last(user: @user, id: @newdate).loans - Budget.last(user: @user, id: @newdate).leisures - Budget.last(user: @user, id: @newdate).amorizations - Budget.last(user: @user, id: @newdate).misc - Budget.last(user: @user, id: @newdate).savings + Budget.last(user: @user, id: @newdate).income
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
      session[:id] = nil
    end
    slim :'overview'
  end



  get '/stats' do
    File.read(File.join('views', 'stats.html'))
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
    session[:id] = params[:newdate]

    redirect '/overview'
  end


end