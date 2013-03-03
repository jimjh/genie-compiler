# ~*~ encoding: utf-8 ~*~
RSpec::Matchers.define :validate_presence_of do |index, key|
  message = /#{key} must not be blank/
  chain :with do |args|
    @args = args.clone
  end
  chain :on do |method|
    @method = method
  end
  match do |subject|
    expect { subject.public_send @method, *@args }.to_not raise_error
    @args[index] = ''
    expect { subject.public_send @method, *@args }.to \
      raise_error(Lamp::RPCError, message)
  end
end

RSpec::Matchers.define :validate_uri_format_of do |index, key|
  message = /#{key} must be a valid http\(s\) URI/
  chain :with do |args|
    @args = args.clone
  end
  chain :on do |method|
    @method = method
  end
  match do |subject|
    expect { subject.public_send @method, *@args }.to_not raise_error
    @args[index] = 'x'
    expect { subject.public_send @method, *@args }.to \
      raise_error(Lamp::RPCError, message)
  end
end
