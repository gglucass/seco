class Repo
  include DataMapper::Resource
  DataMapper::Property::String.length(255)
   
   property :id,          Serial, :key => false
   property :keynameown,     String, :key => true
   property :keyword,     String
   property :created,     DateTime
   property :description, String
   property :followers,   Integer
   property :fork,        Boolean
   property :forks,       Integer
   property :language,    String
   property :name,        String
   property :owner,       String
   property :pushed,      DateTime
   property :username,    String
   property :watchers,    String
  
  def perform
    self.update()
    
  end
  
  after :create do
    self.perform
  end
end