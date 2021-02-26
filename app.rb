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
    password = result["password"]
    id = result ["id"]

    if BCrypt::Password.new(password) == password
        session[:id] = id
        redirect('/creator')
    else
        "Wrong password!"
    end
end