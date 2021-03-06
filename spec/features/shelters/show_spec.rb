require 'rails_helper'

describe 'As a visitor' do
  describe "When I visit '/shelters/:id' " do
    it "I should display the shelter's id and information" do
      shelter1 = Shelter.create(name: 'Dogs and Cats',
                                address: '1234 spoon.st',
                                city: 'Tampa',
                                state: 'Florida',
                                zip: '34638')

      visit "/shelters/#{shelter1.id}"

      expect(page).to have_content(shelter1.id.to_s)
      expect(page).to have_content(shelter1.name.to_s)
      expect(page).to have_content(shelter1.address.to_s)
      expect(page).to have_content(shelter1.city.to_s)
      expect(page).to have_content(shelter1.state.to_s)
      expect(page).to have_content(shelter1.zip.to_s)
    end

    it "I should see a link 'Update shelter'" do
      shelter1 = Shelter.create(name: 'Dogs and Cats',
                                address: '1234 spoon.st',
                                city: 'Tampa',
                                state: 'Florida',
                                zip: '34638')

      visit "/shelters/#{shelter1.id}"
      expect(page).to have_link('Update Shelter')

      visit "/shelters/#{shelter1.id}"
      click_link 'Update Shelter'

      expect(current_path).to eq("/shelters/#{shelter1.id}/edit")
    end

    it 'I should see a button to delete the shelter' do
      shelter1 = Shelter.create(name: 'Dogs and Cats',
                                address: '1234 spoon.st',
                                city: 'Tampa',
                                state: 'Florida',
                                zip: '34638')

      visit "/shelters/#{shelter1.id}"

      expect(page).to have_button('Delete Shelter')
    end

    it 'I should see a link that takes me to the Shelters Pet Index page' do
      shelter1 = Shelter.create(name: 'Dogs and Cats',
                                address: '1234 spoon.st',
                                city: 'Tampa',
                                state: 'Florida',
                                zip: '34638')
      visit "/shelters/#{shelter1.id}"

      expect(page).to have_link('Pet Index for This Shelter')

      visit "/shelters/#{shelter1.id}"

      click_link 'Pet Index for This Shelter'

      expect(current_path).to eq("/shelters/#{shelter1.id}/pets")
    end

    it 'I can edit each review listed' do
      shelter_1 = Shelter.create!(name: 'Colorado Cares', address: '867 magnolia st',
                                  city: 'Lakewood', state: 'CO', zip: '80022')

      user_1 = User.create!(name: 'Holly Baker',
                            street_address: '4443 fountain ave',
                            city: 'Lakewood',
                            state: 'CO',
                            zip: '80009')
      user_2 = User.create!(name: 'Jeff Daniels',
                            street_address: '455 west dr',
                            city: 'Denver',
                            state: 'Colorado',
                            zip: '87709')

      review_1 = shelter_1.reviews.new(title: 'Colorado Cares is the best', rating: 5,
                                       content: 'I absolutely love this shelter. I have found the best friend a woman could have!',
                                       user_name: 'Holly', picture: 'https://tilasto.info/arkkitehti/wp-content/uploads/2019/02/kirkkokivi1.jpg')
      review_1.user_id = user_1.id
      review_1.save!

      review_2 = shelter_1.reviews.new(title: 'Ehhhhh', rating: 1,
                                       content: 'All I can say is nope', user_name: 'Jeff', picture: 'https://cdn.hpm.io/wp-content/uploads/2019/06/25143552/Dogs-1000x750.jpg')
      review_2.user_id = user_2.id
      review_2.save!

      visit "/shelters/#{shelter_1.id}"

      within("#review-#{review_1.id}") do
        expect(page).to have_button('edit review')
        click_button('edit review')
      end

      visit "/shelters/#{shelter_1.id}/reviews/#{review_1.id}/edit"

      expect(current_path).to eq("/shelters/#{shelter_1.id}/reviews/#{review_1.id}/edit")
      expect(find_field(:title).value).to eq(review_1.title)
      expect(find_field(:rating).value).to eq(review_1.rating.to_s)
      expect(find_field(:content).value).to eq(review_1.content)
      expect(find_field(:picture).value).to eq(review_1.picture)
      expect(find_field(:user_name).value).to eq(review_1.user_name)
      expect(find_field(:title).value).to_not eq(review_2.title)
      expect(find_field(:rating).value).to_not eq(review_2.rating.to_s)
      expect(find_field(:content).value).to_not eq(review_2.content)
      expect(find_field(:picture).value).to_not eq(review_2.picture)
      expect(find_field(:user_name).value).to_not eq(review_2.user_name)

      new_rating = 4
      new_name = 'Jeff Daniels'

      fill_in :rating, with: new_rating
      fill_in :user_name, with: new_name

      click_on('update review')

      expect(current_path).to eq("/shelters/#{shelter_1.id}")
      expect(page).to have_xpath("//img [contains(@src, '#{review_1.picture}')]")
      expect(page).to have_content(new_name)
      expect(page).to have_content(review_1.title)
      expect(page).to have_content(new_rating)
      expect(page).to have_content(review_1.content)
      expect(page).to have_xpath("//img [contains(@src, '#{review_1.picture}')]")
      expect(page).to have_content(review_2.user_name)
      expect(page).to have_content(review_2.title)
      expect(page).to have_content(review_2.rating)
      expect(page).to have_content(review_2.content)
    end

    it 'I should show a list of reviews for that shelter' do
      shelter1 = Shelter.create!(name: 'Dogs and Cats',
                                 address: '1234 spoon.st',
                                 city: 'Tampa',
                                 state: 'Florida',
                                 zip: '34638')
      shelter2 = Shelter.create!(name: 'Pets for You',
                                 address: '1234 test.st',
                                 city: 'Miami',
                                 state: 'Florida',
                                 zip: '34638')
      user1 = User.create!(name: 'Bob',
                           street_address: '1234 Test Dr',
                           city: 'Denver',
                           state: 'Colorado',
                           zip: '12345')
      user2 = User.create!(name: 'Tony',
                           street_address: '1234 Review Dr',
                           city: 'Denver',
                           state: 'Colorado',
                           zip: '19345')
      review1 = Review.create!(title: 'My Rating',
                               rating: 3,
                               content: 'The place is not bad.',
                               picture: 'https://upload.wikimedia.org/wikipedia/commons/6/6a/Bob_Gibson_crop.JPG',
                               shelter_id: shelter1.id,
                               user_id: user1.id,
                               user_name: user1.name)
      review2 = Review.create!(title: 'My thoughts',
                               rating: 4,
                               content: 'Great place for pets',
                               picture: 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Tony_Romo_2015.jpg',
                               shelter_id: shelter2.id,
                               user_id: user2.id,
                               user_name: user2.name)
      review3 = Review.create!(title: 'My Rating',
                               rating: 3,
                               content: 'Its okay. Cute pets they have.',
                               picture: 'https://upload.wikimedia.org/wikipedia/commons/6/6a/Bob_Gibson_crop.JPG',
                               shelter_id: shelter1.id,
                               user_id: user1.id,
                               user_name: user1.name)
      review4 = Review.create!(title: 'My Concerns',
                               rating: 2,
                               content: 'This place is not great',
                               picture: 'https://upload.wikimedia.org/wikipedia/commons/4/4e/Tony_Romo_2015.jpg',
                               shelter_id: shelter2.id,
                               user_id: user2.id,
                               user_name: user2.name)

      visit "/shelters/#{shelter1.id}"
      expect(page).to have_content(review1.title)
      expect(page).to have_content(review1.rating.to_s)
      expect(page).to have_content(review1.content)
      expect(page).to have_xpath("//img[contains(@src,'#{review1.picture}')]")
      expect(page).to have_content(review3.user_name)
      expect(page).to have_content(review3.title)
      expect(page).to have_content(review3.rating.to_s)
      expect(page).to have_content(review3.content)
      expect(page).to have_xpath("//img[contains(@src,'#{review3.picture}')]")
      expect(page).to have_content(review3.user_name)
      expect(page).to_not have_content(review2.title)
      expect(page).to_not have_content(review2.content)
      expect(page).to_not have_xpath("//img[contains(@src,'#{review2.picture}')]")
      expect(page).to_not have_content(review4.user_name)
      expect(page).to_not have_content(review4.title)
      expect(page).to_not have_content(review4.content)
      expect(page).to_not have_xpath("//img[contains(@src,'#{review4.picture}')]")
      expect(page).to_not have_content(review4.user_name)
    end

    it 'I should see a link to add a new review' do
      shelter1 = Shelter.create!(name: 'Dogs and Cats',
                                 address: '1234 spoon.st',
                                 city: 'Tampa',
                                 state: 'Florida',
                                 zip: '34638')
      user1 = User.create!(name: 'Bob',
                           street_address: '1234 Test Dr',
                           city: 'Denver',
                           state: 'Colorado',
                           zip: '12345')
      review1 = Review.create!(title: 'My Rating',
                               rating: 3,
                               content: 'The place is not bad.',
                               picture: 'https://upload.wikimedia.org/wikipedia/commons/6/6a/Bob_Gibson_crop.JPG',
                               shelter_id: shelter1.id,
                               user_id: user1.id,
                               user_name: user1.name)
      visit "/shelters/#{shelter1.id}"

      expect(page).to have_link('New Review')

      visit "/shelters/#{shelter1.id}"
      click_link 'New Review'

      expect(current_path).to eq("/shelters/#{shelter1.id}/reviews/new")
    end

    it 'I can delete the each review' do
      shelter_1 = Shelter.create!(name: 'Colorado Cares', address: '867 magnolia st',
                                  city: 'Lakewood', state: 'CO', zip: '80022')

      user_1 = User.create!(name: 'Holly Baker',
                            street_address: '4443 fountain ave',
                            city: 'Lakewood',
                            state: 'CO',
                            zip: '80009')
      user_2 = User.create!(name: 'Jeff Daniels',
                            street_address: '455 west dr',
                            city: 'Denver',
                            state: 'Colorado',
                            zip: '87709')

      review_1 = shelter_1.reviews.new(title: 'Colorado Cares is the best', rating: 5,
                                       content: 'I absolutely love this shelter. I have found the best friend a woman could have!',
                                       user_name: 'Holly', picture: 'https://tilasto.info/arkkitehti/wp-content/uploads/2019/02/kirkkokivi1.jpg')
      review_1.user_id = user_1.id
      review_1.save!

      review_2 = shelter_1.reviews.new(title: 'Ehhhhh', rating: 1,
                                       content: 'All I can say is nope', user_name: 'Jeff', picture: 'https://cdn.hpm.io/wp-content/uploads/2019/06/25143552/Dogs-1000x750.jpg')
      review_2.user_id = user_2.id
      review_2.save!

      visit "/shelters/#{shelter_1.id}"

      within("#review-#{review_1.id}") do
        expect(page).to have_content(review_1.user_name.to_s)
        expect(page).to have_content(review_1.title.to_s)
        expect(page).to have_xpath("//img[contains(@src,'#{review_1.picture}')]")
        expect(page).to have_content(review_1.content.to_s)
        expect(page).to have_content(review_1.rating.to_s)
        click_button('delete review')
      end

      expect(current_path).to eq("/shelters/#{shelter_1.id}")
      expect(page).to_not have_content(review_1.user_name.to_s)
      expect(page).to_not have_content(review_1.title.to_s)
      expect(page).to_not have_xpath("//img[contains(@src,'#{review_1.picture}')]")
      expect(page).to_not have_content(review_1.content.to_s)
      expect(page).to_not have_content(review_1.rating.to_s, exact: true)
      expect(page).to have_content(review_2.user_name.to_s)
      expect(page).to have_content(review_2.title.to_s)
      expect(page).to have_xpath("//img[contains(@src,'#{review_2.picture}')]")
      expect(page).to have_content(review_2.content.to_s)
      expect(page).to have_content(review_2.rating.to_s)
    end

    it 'should see statistics for that shelter.' do
      shelter_1 = Shelter.create!(name: 'Colorado Cares', address: '867 magnolia st',
                                  city: 'Lakewood', state: 'CO', zip: '80022')

      pet1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                    name: 'Tony',
                                    approximate_age: '2',
                                    sex: 'male',
                                    description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
      pet2 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/german-shorthaired-pointer-dogs-and-puppies/german-shorthaired-pointer-dogs-puppies-3.jpg',
                                    name: 'Isabell',
                                    approximate_age: '5',
                                    sex: 'female',
                                    description: "Isabell is my favorite and I don't want her to go...but then again, I do!")
      user_1 = User.create!(name: 'Holly Baker',
                            street_address: '4443 fountain ave',
                            city: 'Lakewood',
                            state: 'CO',
                            zip: '80009')
      user_2 = User.create!(name: 'Jeff Daniels',
                            street_address: '455 west dr',
                            city: 'Denver',
                            state: 'Colorado',
                            zip: '87709')

      review_1 = shelter_1.reviews.new(title: 'Colorado Cares is the best', rating: 5,
                                       content: 'I absolutely love this shelter. I have found the best friend a woman could have!',
                                       user_name: 'Holly', picture: 'https://tilasto.info/arkkitehti/wp-content/uploads/2019/02/kirkkokivi1.jpg')
      review_1.user_id = user_1.id
      review_1.save!

      review_2 = shelter_1.reviews.new(title: 'Ehhhhh', rating: 1,
                                       content: 'All I can say is nope', user_name: 'Jeff', picture: 'https://cdn.hpm.io/wp-content/uploads/2019/06/25143552/Dogs-1000x750.jpg')
      review_2.user_id = user_2.id
      review_2.save!

      application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                          description: 'I am an experienced pet owner for 5 years and I just love this pet!',
                                          pet_names: pet1.name.to_s, user_id: user_1.id)
      application_2 = Application.create!(user_name: user_2.name, address: "#{user_2.street_address}, #{user_2.city}, #{user_2.state} #{user_2.zip}",
                                          description: 'I would be a loving owner for any of these pets. Enough said.',
                                          pet_names: pet2.name.to_s, user_id: user_2.id)

      PetApplication.create!(pet_id: pet1.id, application_id: application_1.id)
      PetApplication.create!(pet_id: pet2.id, application_id: application_2.id)

      visit "/shelters/#{shelter_1.id}"

      within '#shelter-stats' do
        expect(page).to have_content('Amount of Pets - 2')
        expect(page).to have_content('Applications on file - 2')
      end

      within '#review-stats' do
        expect(page).to have_content('Average Shelter Rating - 3')
      end
    end

    it 'cannot delete shelter' do
      user = User.create!(name: 'Bob',
                          street_address: '1234 Test Dr',
                          city: 'Denver',
                          state: 'Colorado',
                          zip: '12345')

      shelter1 = Shelter.create!(name: 'Dogs and Cats',
                                 address: '1234 spoon.st',
                                 city: 'Tampa',
                                 state: 'Florida',
                                 zip: '34638')

      pet_1 = Pet.create!(img: 'https://upload.wikimedia.org/wikipedia/commons/a/a3/June_odd-eyed-cat.jpg',
                          name: 'Mittens',
                          approximate_age: '6 years',
                          sex: 'Male',
                          shelter_id: shelter1.id)

      pet_2 = Pet.create!(img: 'https://upload.wikimedia.org/wikipedia/commons/3/38/Adorable-animal-cat-20787.jpg',
                          name: 'Tiger',
                          approximate_age: '4 years',
                          sex: 'Male',
                          adoptable: 'No',
                          shelter_id: shelter1.id)

      application_1 = Application.create!(user_name: user.name, user_id: user.id, application_status: 'Approved')

      pet_app_1 = PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id, application_status: 'Approved')
      pet_app_2 = PetApplication.create!(pet_id: pet_2.id, application_id: application_1.id, application_status: 'Approved')

      application_pets = PetApplication.where(application_id: application_1.id)

      visit "/shelters/#{shelter1.id}"

      within "#shelter-#{shelter1.id}" do
        expect(page).to have_button('Delete')
        click_button 'Delete'
      end
      expect(page).to have_content("Shelter can't be deleted: Pet status is pending/approved")
    end
  end
end
