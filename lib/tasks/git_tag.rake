namespace :scm do
  Time::DATE_FORMATS[:release_tag] = "REL-%Y-%m-%d_%H-%M-%S"
  namespace :git do
    desc  "create git tag"
    task :tag_release do
      repo = Grit::Repo.new Rails.root
      time = Time.new
      tag_name = time.to_formatted_s :release_tag
      repo.git.tag({ 'a' => true,  'm' => "creating release tag for #{tag_name}"}, tag_name)
      repo.git.push({'tags' => true})
    end
    
    desc  "get two release tags"
    task :latest_release_tag do
      # First we need to setup the repo
      repo = Grit::Repo.new Rails.root
      # lets retrive the latest release tag
      last_rel_tag = repo.git.describe({'abbrev' => 0, 'tags' => true, 'match' => 'REL-*'}).gsub!("\n","")
      p Grit::Tag.find_all repo
    end
        
  end
end