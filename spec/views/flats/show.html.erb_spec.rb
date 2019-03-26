require 'rails_helper'

RSpec.describe "flats/show", type: :view do
  before(:each) do
    @flat = assign(:flat, Flat.create!(
      :price => 2.5,
      :surface => 3.5,
      :latitude => 4.5,
      :longitude => 5.5
    ))
  end

  it "renders attributes in <p>" do
    render
    expect(rendered).to match(/2.5/)
    expect(rendered).to match(/3.5/)
    expect(rendered).to match(/4.5/)
    expect(rendered).to match(/5.5/)
  end
end
