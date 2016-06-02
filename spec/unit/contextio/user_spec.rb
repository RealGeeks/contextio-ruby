require 'contextio/user'

describe ContextIO::User do
  let(:api) { double('api', url_for: 'url from api') }

  subject { ContextIO::User.new(api, id: '1234') }

  describe ".new" do
    context "with an id passed in" do
      it "doesn't raise an error" do
        expect { ContextIO::User.new(api, id: '1234') }.to_not raise_error
      end
    end

    context "with neither an id nor a resource_url passed in" do
      it "raises an ArgumentError" do
        expect { ContextIO::User.new(api, foo: 'bar') }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#update" do
    before do
      allow(api).to receive(:request).and_return({'success' => true})
    end

    subject { ContextIO::User.new(api, id: '1234', first_name: 'old first name') }

    it "posts to the api" do
      expect(api).to receive(:request).with(
        :post,
        'url from api',
        first_name: 'new first name'
      )

      subject.update(first_name: 'new first name')
    end

    it "updates the object" do
      subject.update(first_name: 'new first name')

      expect(subject.first_name).to eq('new first name')
    end

    it "doesn't make any more API calls than it needs to" do
      expect(api).to_not receive(:request).with(:get, anything, anything)

      subject.update(first_name: 'new first name')
    end
  end
end