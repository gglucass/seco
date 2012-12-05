require 'octokit'
require 'sqlite3'
require 'data_mapper'
require 'dm-sqlite-adapter'
require 'hashie'
require File.dirname(__FILE__) + '/repo'

class Seco
  DataMapper::Logger.new($stdout, :debug)
  DataMapper.setup(:default, 'sqlite:data.db')
  
  def data
    keywords = {"Azure" => ["Azure"], "NodeJitsu" => ["NodeJitsu", "Node Jitsu", "Node_Jitsu", "Node-Jitsu"], "EngineYard" => ["EngineYard", "Engine Yard", "Engine_Yard", "Engine-Yard"], "Cloud Foundry" => ["CloudFoundry", "Cloud Foundry", "Cloud_Foundry", "Cloud-Foundry"], "DotCloud" => ["DotCloud", "Dot Cloud", "Dot_Cloud", "Dot-Cloud"], "Google App Engine" => ["GoogleAppEngine", "Google App Engine", "Google_App_Engine", "Google-App-Engine"], "Heroku" => ["Heroku"], "OpenShift" => ["OpenShift", "Open Shift", "Open_Shift", "Open-Shift"]}
    
    keywords.each_key do |key|
      keywords[key].each do |keyword|
        puts "Searching for repo: " + keyword 
        client = Octokit::Client.new(:login => "kevinvanrooij", :password => "wachtwoord")

        #if keyword isn't found at all, abort
        if client.search_repositories(URI.encode(keyword), options = {start_page: 0}).empty?
          puts "No results for " + keyword
        end

        #start at page 0, go up until array is empty
        count = 0
        while client.search_repositories(URI.encode(keyword), options = {start_page: count}).any?
          results = client.search_repositories(URI.encode(keyword), options = {start_page: count})
          self.process(results: results, keyword: key)    
          puts "Got first " + ((count+1)*100).to_s() + " results."
          count += 1
        end
      end
    end
  end
  
  def process(params)
    results = params[:results]
    results.each do |result|
      Thread.new{mash = Hashie::Mash.new(result)      
      Repo.create(keyword: params[:keyword], created: DateTime.parse(mash.created), description: mash.description, keynameown: params[:keyword]+mash.name+mash.owner, followers: mash.followers, fork: mash.fork, forks: mash.forks,
       language: mash.language, name: mash.name, owner: mash.owner, pushed: DateTime.parse(mash.pushed), username: mash.username, watchers: mash.watchers)}
     end
  end
end

