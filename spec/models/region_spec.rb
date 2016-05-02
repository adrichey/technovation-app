require 'rails_helper'

describe Region, type: :model do
  describe '.name' do
    subject(:region) { build(:region, region_name: 'Region', division: division).name }

    context 'when division is ms' do
      let(:division) { 0 }
      it{is_expected.to eq 'Middle School - Region'}
    end
    context 'when division is hs' do
      let(:division) { 1 }
      it{is_expected.to eq 'High School - Region'}
    end
    context 'when division is x' do
      let(:division) { 2 }
      it{is_expected.to eq 'Invalid Division - Region'}
    end
  end
end
