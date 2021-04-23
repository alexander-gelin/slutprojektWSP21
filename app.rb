require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions

get('/') do
    slim(:register)
end

get('/showlogin') do
    slim(:login)
end

post('/user/new') do
    username = params[:username]
    password = params[:password]
    password_confirm = params[:password_confirm]

    if (password == password_confirm)
        password_digest = BCrypt::Password.create(password)
        db = SQLite3::Database.new('db/charactercreator.db')
        db.execute("INSERT INTO user(username,password) VALUES(?,?)",username,password_digest)
        redirect('/')
    else
        "The passwords do not match!"
    end
end

post('/login') do
    username = params[:username]
    password = params[:password]
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM user WHERE username = ?",username).first
    pwdigest = result["password"]
    id = result ["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/overview')
    else
        "Wrong password!"
    end
end

get('/overview') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM character WHERE user_id = ?",id)
    slim(:"overview/index",locals:{character:result})
end

get('/creator/new') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM race")
    result2 = db.execute("SELECT * FROM klass")
    slim(:"creator/create",locals:{race:result,klass:result2})
end

post('/creator') do
    race = params[:race]
    klass = params[:klass]
    name = params[:name]
    age = params[:age]
    id = session[:id].to_i

    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    db.execute("INSERT INTO character(age,name,race,klass,user_id) VALUES(?,?,?,?,?)",age,name,race,klass,id)
    redirect('/overview')
end

