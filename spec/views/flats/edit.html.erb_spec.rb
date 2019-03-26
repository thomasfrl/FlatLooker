require 'rails_helper'

RSpec.describe "flats/edit", type: :view do
  before(:each) do
    @flat = assign(:flat, Flat.create!(
      :price => 1.5,
      :surface => 1.5,
      :latitude => 1.5,
      :longitude => 1.5
    ))
  end

  it "renders the edit flat form" do
    render

    assert_select "form[action=?][method=?]", flat_path(@flat), "post" do

      assert_select "input[name=?]", "flat[price]"

      assert_select "input[name=?]", "flat[surface]"

      assert_select "input[name=?]", "flat[latitude]"

      assert_select "input[name=?]", "flat[longitude]"
    end
  end
end
