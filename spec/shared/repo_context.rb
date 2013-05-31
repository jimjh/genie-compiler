# ~*~ encoding: utf-8 ~*~
shared_context 'lesson repo' do

  def silence(dir, command)
    Dir.chdir dir do
      system "(#{command}) &> /dev/null"
    end
  end

  def commit_all
    silence repo, <<-eos
      git add .
      git ci --allow-empty -am 'test'
    eos
  end

  def clone_lesson(name='test', opts={})
    Lamp::Lesson.clone_from url, name, opts
  end

  let(:url)  { (repo + '.git').to_s }
  let(:repo) { Pathname.new Dir.mktmpdir }

  before(:each) do
    silence repo, <<-eos
      git init
      echo {} > #{Spirit::MANIFEST} && git add #{Spirit::MANIFEST}
      touch #{Spirit::INDEX} && git add #{Spirit::INDEX}
      git ci -m 'first commit'
    eos
  end

  after(:each) { FileUtils.remove_entry_secure repo }

end
