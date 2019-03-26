require 'rails_helper'

RSpec.describe "flats/index", type: :view do
  before(:each) do
    assign(:flats, [
      Flat.create!(
        :price => 2.5,
        :surface => 3.5,
        :latitude => 4.5,
        :longitude => 5.5
      ),
      Flat.create!(
        :price => 2.5,
        :surface => 3.5,
        :latitude => 4.5,
        :longitude => 5.5
      )
    ])
  end

  it "renders a list of flats" do
    render
    assert_select "tr>td", :text => 2.5.to_s, :count => 2
    assert_select "tr>td", :text => 3.5.to_s, :count => 2
    assert_select "tr>td", :text => 4.5.to_s, :count => 2
    assert_select "tr>td", :text => 5.5.to_s, :count => 2
  end
end
