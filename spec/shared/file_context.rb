# ~*~ encoding: utf-8 ~*~
shared_context 'file ops' do

  require 'securerandom'
  def random_file(path)
    rand = SecureRandom.uuid
    IO.write path, ( block_given? ? yield(rand) : rand )
    rand
  end

  def empty_directory(path)
    path.rmtree if path.exist?
    path.mkpath
    path
  end

end
