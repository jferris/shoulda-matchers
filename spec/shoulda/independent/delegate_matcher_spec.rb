require 'spec_helper'

describe Shoulda::Matchers::Independent::DelegateMatcher do
  it 'raises an error if no target object is defined' do
    matcher = delegate_method(:name)
    expect {
      matcher.matches?(stub)
    }.to raise_exception Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefined
  end

  context 'given a method that does not delegate' do
    let(:object) do
      define_class(:non_delegator) do
        def name; "My Name"; end
      end
    end

    it 'confirms that the method is not delegated' do
      object.should_not delegate_method(:name).to(:anything)
    end

    it 'provides a useful negative failure message' do
      matcher = delegate_method(:name)
      matcher.negative_failure_message.
        should == 'Expected not to delegate #name.'
    end
  end

  context 'given a method that delegates properly' do
    before do
      define_class(:mailman)
      define_class(:post_office) do
        def mailman
          Mailman.new
        end

        def deliver_mail
          mailman.deliver_mail
        end
      end
    end

    it 'confirms that the method is delegated' do
      post_office = PostOffice.new
      post_office.should delegate_method(:deliver_mail).to(:mailman)
    end

    it 'provides a useful failure message' do
      post_office = PostOffice.new
      matcher = delegate_method(:nonexistent).to(:mailman)
      matcher.matches?(post_office)
      matcher.failure_message.should == "Expected to delegate #nonexistent to #mailman, but did not delegate."
    end
  end
end

describe Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefined do
  it 'has a useful message' do
    error = Shoulda::Matchers::Independent::DelegateMatcher::TargetNotDefined.new
    error.message.should include "Delegation needs a target."
  end
end
