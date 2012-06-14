namespace :deploy do
  namespace :automation do
    desc "Get all referenced pivotal tracker stories"
    task :create_changelog, [:message]  => :environment do |t, args|
      
      changelog_location = "#{Rails.root}/CHANGELOG.md"
      changelog = {:features => [], :bugs => []}
      # get current repo
      repo = Grit::Repo.new Rails.root
      # last release
      # last_rel = "REL-2012-06-12_10-38-04"
      last_rel = repo.git.describe({'abbrev' => 0, 'tags' => true, 'match' => 'REL-*'}).gsub!("\n","")
      p "LAST RELEASE: #{last_rel}"
      # validate
      raise "Could not find previous release tag" unless last_rel
       
      # lets tag the new release
      time = Time.new
      tag_name = time.to_formatted_s :release_tag
      repo.git.tag({ 'a' => true,  'm' => "creating release tag for #{tag_name}"}, tag_name)
      repo.git.push({'tags' => true})
      
      # current release
      cur_rel = repo.git.describe({'abbrev' => 0, 'tags' => true, 'match' => 'REL-*'}).gsub!("\n","")
      p "CURRENT RELEASE: #{cur_rel}"
      # validate
      raise "Could not find latest release tag" unless cur_rel
      # Now lets get all the commit messages with PT story references
      commits = repo.git.log({'grep' => "\[[ a-z]*[ ]*#[0-9]+[ ]*\]", 'E' => true, 'i' => true, 'format' => 'format:%s'}, "#{last_rel}...#{cur_rel}")
      p commits
      # Only if we have commit do we need to carry on
      if not commits.blank?
         # Lets extract the sory references
        story_ids = commits.scan(/\[[ a-z]*[ ]*#([0-9]+)[ ]*\]/).flatten!.uniq
        p story_ids
        # Pivotal Tracker
        accepted_status = [:started, :finished, :delivered, :accepted]
        # Manually set API Token
        PivotalTracker::Client.token = Rails.application.config.pivotal_tracker_token
        # return all projects
        projects = PivotalTracker::Project.all
        # We need to order the projects by the likelyhood of stories being contained within them to speed up the process
        projects = projects.sort { |p1, p2| p2.last_activity_at <=> p1.last_activity_at }
        projects.map do |project|
          break unless story_ids
          p "checking project #{project.name} for stories"
          story_ids.each do |id|
            story = project.stories.find id
            if story
              if accepted_status.include? story.current_state.to_sym
                if story.story_type == "feature"
                  changelog[:features] << story.name
                  story.update :current_state => :accepted
                elsif story.story_type == "bug"
                  changelog[:bugs] << story.name
                  story.update :current_state => :accepted
                end
              end
            end
          end
        end
        # Now lets assemble the changelog
        head = "\n## Release #{tag_name}\nPlease find all changes below.\n"
        # assemble the features
        features = "\n### New features deployed:\n"
        if changelog[:features]
          changelog[:features].each do |feature|
            features << "* #{feature}\n"
          end
        else
          features << "**No new features deployed**\n"
        end
        # Assemble the bug fixes
        bugs = "\n### Bug fixes deployed:\n"
        if changelog[:bugs]
          changelog[:bugs].each do |bug|
            bugs << "* #{bug}\n"
          end
        else
          bugs << "**No bug fixes deployed**\n"
        end
        # Write the changelog to the changelog file
        open(changelog_location, 'a') do |f|
          f << head
          f << features
          f << bugs
        end
        #  And commit them to the remote
        # p changelog_location
        repo.git.add({}, changelog_location)
        c = repo.git.commit({'m' => "updating changelog for release #{tag_name}"}, changelog_location).scan(/^\[(\w+)[\s]{1}([a-zA-Z0-9]+)\]/).flatten
        if c.first and c.last
          repo.git.push({}, "origin #{c.last}:#{c.first}")
        end
      else
        p "No commits with story references identified"
      end
    end
  end
end
    