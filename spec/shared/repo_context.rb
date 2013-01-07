# ~*~ encoding: utf-8 ~*~
shared_context 'lesson repo' do

  def silence(dir, command)
    Dir.chdir dir do
      system "(#{command}) &> /dev/null"
    end
  end

  def commit_all
    silence @fake_repo, <<-eos
      git add .
      git ci --allow-empty -am 'test'
    eos
  end

  let(:url) { (@fake_repo + '.git').to_s }

  before(:all) { Lamp.settings.load! root: Dir.mktmpdir }
  after(:all)  { FileUtils.remove_entry_secure Lamp.settings.root }

  before(:each) do
    @fake_repo = Pathname.new Dir.mktmpdir
    silence @fake_repo, <<-eos
      git init
      echo {} > #{Aladdin::Config::FILE} && git add #{Aladdin::Config::FILE}
      touch #{Aladdin::INDEX_MD} && git add #{Aladdin::INDEX_MD}
      git ci -m 'first commit'
    eos
  end

  after(:each) { FileUtils.remove_entry_secure @fake_repo }

end
