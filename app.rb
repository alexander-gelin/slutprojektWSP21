require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
enable :sessions
include Model

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
    id = result["id"]

    if BCrypt::Password.new(pwdigest) == password
        session[:id] = id
        redirect('/creator/')
    else
        "Wrong password!"
    end
end

get('/creator/') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM character WHERE user_id = ?",id)
    slim(:"creator/index",locals:{character:result})
end

get('/creator/new') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM race")
    result2 = db.execute("SELECT * FROM klass")
    slim(:"creator/new",locals:{race:result,klass:result2})
end

post('/creator') do
    db = SQLite3::Database.new('db/charactercreator.db')
    id = session[:id].to_i
    race = params[:race]
    klass = params[:klass]
    name = params[:name]
    age = params[:age]

    klass_id = db.execute("SELECT id FROM klass WHERE class_name = ?",klass)

    spec = db.execute("SELECT spec.spec_name FROM klass_spec_relation INNER JOIN spec ON klass_spec_relation.spec_id = spec.id WHERE klass_id = ?",klass_id)
    character = db.execute("INSERT INTO character(name,age,race,klass,spec,user_id) VALUES(?,?,?,?,?,?)",name,age,race,klass,spec,id)
    redirect('/creator/')
end

post('/creator/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.execute("DELETE FROM character WHERE id = ?",id)
    redirect('/creator/')
end