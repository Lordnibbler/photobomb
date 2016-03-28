# alias FG to save typing!
FG = FactoryGirl

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods

  # lint all factories to check validity before running suite
  # config.before(:suite) do
  #   begin
  #     DatabaseCleaner.start
  #     FactoryGirl.lint
  #   ensure
  #     DatabaseCleaner.clean
  #   end
  # end
end
