shared_examples 'a JSON log writer' do
  let(:log_hash) do
    { 'foo' => 'bar', 'baz' => 'quux' }
  end

  it 'writes JSON dump of hash to log with corresponding level key' do
    allow(Time).to receive(:now).and_return('foobar')

    expect(log_output_obj).to receive(msg) do |json_dump|
      h = { 'timestamp' => 'foobar', 'uuid' => 'n/a', 'level' => level.to_s }
      expect(JSON.parse(json_dump)).to eq(h.merge(log_hash))
    end

    logger.send(level, log_hash)
  end

  it 'automatically includes a timestamp' do
    expect(log_output_obj).to receive(msg) do |json_dump|
      t = JSON.parse(json_dump)['timestamp']
      expect { DateTime.parse(t) }.not_to raise_error
    end

    logger.send(level, log_hash)
  end

  it 'outputs the timestamp first' do
    expect(log_output_obj).to receive(msg) do |json_dump|
      h = JSON.parse(json_dump)
      expect(h.first[0].to_sym).to be(:timestamp)
    end

    logger.send(level, log_hash)
  end

  context 'when a session is set' do
    it 'provides a static reader method' do
      described_class.session = fn
      expect(described_class.session?).to eq('instance-variable')

      described_class.send(:remove_instance_variable, :@session)
      expect(described_class.session?).to be(nil)
    end
  end

  context 'when a user defined function is provided' do
    it 'displays a custom session value' do
      expect(log_output_obj).to receive(msg) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h['uuid']).to eq('foo')
      end

      described_class.session = fn
      logger.send(level, binding, log_hash)
      described_class.session = -> { 'n/a' }
    end
  end

  context 'when a user defined function is not provided' do
    it 'displays a default session value' do
      expect(log_output_obj).to receive(msg) do |json_dump|
        h = JSON.parse(json_dump)
        expect(h['uuid']).to eq('n/a')
      end

      logger.send(level, log_hash)
    end
  end
end

shared_examples 'a JSON log non writer' do
  before do
    allow(Time).to receive(:now).and_return('foobar')
    logger.send(level, log_hash)
  end

  it 'does not write' do
    expect(log_output_obj).not_to receive(msg)
  end
end

shared_context 'nested log hash' do
  let(:log_hash) { { 'nest' => nest } }

  let(:nest) { { 'bird' => 'eggs' } }
end

shared_examples 'nested JSON message flattened to strings' do
  include_context 'nested log hash'

  specify do
    expect(log_output_obj).to receive(msg) do |json_dump|
      expect(JSON.parse(json_dump)['nest']).to eq(nest.to_s)
    end

    logger.send(level, log_hash)
  end
end

shared_examples 'nesting allowed' do
  include_context 'nested log hash'

  specify do
    expect(log_output_obj).to receive(msg) do |json_dump|
      expect(JSON.parse(json_dump)).to eq(log_hash)
    end

    logger.send(level, log_hash)
  end
end

shared_examples 'gracefully fails with string message' do
  let(:log_message) { 'Unable to connect to server' }

  specify { expect(log_output_obj).not_to receive(msg) }

  specify do
    expect { logger.debug(log_message) }.not_to raise_error
  end
end
