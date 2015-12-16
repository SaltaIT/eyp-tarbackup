require 'spec_helper'
describe 'tarbackup' do

  context 'with defaults for all parameters' do
    it { should contain_class('tarbackup') }
  end
end
