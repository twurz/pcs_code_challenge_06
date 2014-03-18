require 'rubygems'
require 'sinatra'
require 'pry'
require 'data_mapper'
require_relative 'suckersinput.rb'
require_relative 'persistance.rb'
require_relative 'lib/concat_sql.rb'

enable :sessions

configure do
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/suckers.sqlite3")
end

class SuckerEntity
  include DataMapper::Resource

  property :id,             Serial
  property :name_prefix,    String
  property :first_name,     String
  property :middle_name,    String
  property :last_name,      String
  property :suffix,         String
  property :country_code,   String
  property :area_code,      String
  property :phone_prefix,   String
  property :line,           String
  property :extension,      String
  property :twitter,        String
  property :email,          String
  property :created_at,     DateTime
end

DataMapper.finalize
DataMapper.auto_upgrade!

get '/' do
  erb :index
end

post '/suckers' do
  s = SuckerParse.new
  s.name = params[:name]
  s.phone = params[:phone]
  s.twitter = params[:twitter]
  s.email = params[:email]

  sucker = SuckerEntity.create( name_prefix: s.name[0],
                                first_name: s.name[1],
                                middle_name: s.name[2],
                                last_name: s.name[3],
                                suffix: s.name[4],
                                country_code: s.phone[0],
                                area_code: s.phone[1],
                                phone_prefix: s.phone[2],
                                line: s.phone[3],
                                extension: s.phone[4],
                                twitter: s.twitter[0],
                                email: s.email[0],
                                created_at: Time.now)
  session[:name] = params[:name]
  redirect to('/thanks')
end

get '/thanks' do
  # s = get_last_sucker
  @name = session[:name]
  erb :thanks, locals: { nm: @name }
end

get '/suckers' do
  @suckers = SuckerEntity.all.reverse
  session[:suckers_array] = ConcatSQL.concat_entities(@suckers)
  erb :suckers, locals: { suck: session[:suckers_array] }
end

get '/suckers/:num' do |number|
  deets = SuckerEntity.get(number.to_i + 1)
  deets = ConcatSQL.concat_entity(deets)
  binding.pry
  erb :suckers_detail, locals: { info: deets }
end
