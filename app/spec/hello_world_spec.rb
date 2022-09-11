require_relative '../hello_world'

RSpec.describe "hello" do
  it "can run the tests" do
    hello
    expect(true).to eq true
  end
end
