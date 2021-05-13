require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
# require_relative 'model/model.rb'
enable :sessions

# Displays Landing Page
#
get('/') do
    slim(:register)
end

# Displays Login Page
#
get('/showlogin') do
    slim(:login)
end

# Creates a new user and if successful, redirects to '/'
#
# @param [String] username, the user's username
# @param [String] password, the user's password
# @param [String] password_confirm, the users password again
#
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

# Login using created user and if successful, redirects to '/creator/'
# 
# @param [String] username, the user's username
# @param [String] password, the user's password
#
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

# Displays user's created characters
#
get('/creator/') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM character WHERE user_id = ?",id)
    slim(:"creator/index",locals:{character:result})
end

# Displays a form for creating characters
#
get('/creator/new') do
    id = session[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM race")
    result2 = db.execute("SELECT * FROM klass")
    slim(:"creator/new",locals:{race:result,klass:result2})
end

# Creates a new character and redirects to '/creator/'
#
# @param [String] race, the character's race
# @param [String] klass, the character's class
# @param [String] name, the character's name
# @param [Integer] age, the character's age
# @param [String] spec, the character's specialization
#
post('/creator') do
    db = SQLite3::Database.new('db/charactercreator.db')
    user_id = session[:id].to_i
    race = params[:race]
    klass = params[:klass]
    name = params[:name]
    age = params[:age]

    klass_id = db.execute("SELECT id FROM klass WHERE class_name = ?",klass)

    spec = db.execute("SELECT spec.spec_name FROM klass_spec_relation INNER JOIN spec ON klass_spec_relation.spec_id = spec.id WHERE klass_id = ?",klass_id)
    character = db.execute("INSERT INTO character(name,age,race,klass,spec,user_id) VALUES(?,?,?,?,?,?)",name,age,race,klass,spec,user_id)
    redirect('/creator/')
end

# Deletes an existing character and redirects to '/creator/'
#
post('/creator/:id/delete') do
    id = params[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.execute("DELETE FROM character WHERE id = ?",id)
    redirect('/creator/')
end

get('/creator/:id/edit') do
    id = params[:id].to_i
    db = SQLite3::Database.new('db/charactercreator.db')
    db.results_as_hash = true
    result = db.execute("SELECT * FROM character WHERE id = ?",id)[0]
    result2 = db.execute("SELECT * FROM race")
    result3 = db.execute("SELECT * FROM klass")
    slim(:"creator/edit",locals:{character:result,race:result2,klass:result3,id:id})
end

post('/creator/:id/update') do
    db = SQLite3::Database.new('db/charactercreator.db')
    id = params[:id].to_i
    user_id = session[:id].to_i
    race = params[:race]
    klass = params[:klass]
    name = params[:name]
    age = params[:age]
    
    klass_id = db.execute("SELECT id FROM klass WHERE class_name = ?",klass)
    spec = db.execute("SELECT spec.spec_name FROM klass_spec_relation INNER JOIN spec ON klass_spec_relation.spec_id = spec.id WHERE klass_id = ?",klass_id)

    character_update = db.execute("UPDATE character SET name = ?, age = ?, race = ?, klass = ?, spec = ? WHERE id = #{id}",name,age,race,klass,spec)
    redirect('/creator/')
end