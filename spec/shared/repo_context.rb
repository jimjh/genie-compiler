# ~*~ encoding: utf-8 ~*~
shared_context 'lesson repo' do

    before(:all) { Lamp.settings.load! root: Dir.mktmpdir }
    after(:all)  { FileUtils.remove_entry_secure Lamp.settings.root }

    before(:each) do
      @fake_repo = Pathname.new Dir.mktmpdir
      Dir.chdir @fake_repo do
        system <<-eos
          (
            git init
            echo {} > manifest.json && git add manifest.json
            touch index.md && git add index.md
            git ci -m 'first commit'
          ) &> /dev/null
        eos
      end
    end

    let(:url) { (@fake_repo + '.git').to_s }
    after(:each) { FileUtils.remove_entry_secure @fake_repo }

    def commit_all
      Dir.chdir @fake_repo do
        system <<-eos
          (git add .
           git ci --allow-empty -am 'test') &> /dev/null
        eos
      end
    end

end
