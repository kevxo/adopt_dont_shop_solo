require 'rails_helper'

describe "When I visit a pet show page and click on 'Delete Pet'" do
  it 'when I click Im redirected to pet index page' do
    shelter1 = Shelter.create(name: 'Dogs and Cats',
                              address: '1234 spoon.st',
                              city: 'Tampa',
                              state: 'Florida',
                              zip: '34638')
    pet1 = Pet.create(img: 'https://upload.wikimedia.org/wikipedia/commons/a/a3/June_odd-eyed-cat.jpg',
                      name: 'Mittens',
                      description: "He's healthy",
                      approximate_age: '6 years',
                      sex: 'Male',
                      adoptable: 'Yes',
                      shelter_id: shelter1.id)
    visit "/pets/#{pet1.id}"
    click_button 'Delete Pet'

    expect(current_path).to eq('/pets')
  end
end