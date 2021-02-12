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