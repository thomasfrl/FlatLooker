require 'rails_helper'

RSpec.describe "flats/new", type: :view do
  before(:each) do
    assign(:flat, Flat.new(
      :price => 1.5,
      :surface => 1.5,
      :latitude => 1.5,
      :longitude => 1.5
    ))
  end

  it "renders new flat form" do
    render

    assert_select "form[action=?][method=?]", flats_path, "post" do

      assert_select "input[name=?]", "flat[price]"

      assert_select "input[name=?]", "flat[surface]"

      assert_select "input[name=?]", "flat[latitude]"

      assert_select "input[name=?]", "flat[longitude]"
    end
  end
end
