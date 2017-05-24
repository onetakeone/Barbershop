require 'SQLite3'

db = SQLite3::Database.new 'barbershop.db'
db.results_as_hash = true
db.execute 'select * from clients' do |row|
   print row['client'] 
   print "-"
   puts row['number']
end