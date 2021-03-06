require 'rails_helper'

RSpec.describe 'As a visitor' do
  describe "when I visit show page '/applications/:id'" do
    it 'I should see the applicants information' do
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

      pet1 = Pet.create!(img: 'https://upload.wikimedia.org/wikipedia/commons/a/a3/June_odd-eyed-cat.jpg',
                         name: 'Mittens',
                         approximate_age: '6 years',
                         sex: 'Male',
                         shelter_id: shelter1.id)

      pet2 = Pet.create!(img: 'https://upload.wikimedia.org/wikipedia/commons/3/38/Adorable-animal-cat-20787.jpg',
                         name: 'Tiger',
                         approximate_age: '4 years',
                         sex: 'Male',
                         shelter_id: shelter1.id)

      application_1 = Application.create!(user_name: user.name, address: "#{user.street_address}, #{user.city}, #{user.state} #{user.zip}",
                                          description: 'I am an experienced pet owner for 5 years and I just love this pet!',
                                          pet_names: "#{pet1.name}, #{pet2.name}", user_id: user.id)

      PetApplication.create!(pet_id: pet1.id, application_id: application_1.id)
      PetApplication.create!(pet_id: pet2.id, application_id: application_1.id)

      visit "/applications/#{application_1.id}"

      expect(page).to have_content(application_1.user_name)
      expect(page).to have_content(application_1.address)
      expect(page).to have_content(application_1.description)

      within "#pet-#{pet1.id}" do
        expect(page).to have_link(pet1.name)
        click_link(pet1.name)
      end

      expect(current_path).to eq("/pets/#{pet1.id}")

      visit "/applications/#{application_1.id}"

      within "#pet-#{pet2.id}" do
        expect(page).to have_link(pet2.name)
        click_link(pet2.name)
      end

      expect(current_path).to eq("/pets/#{pet2.id}")
    end

    describe 'if the application has not yet been submitted' do
      it 'I can search for a pet with their name' do
        shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')

        pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Tony',
                                       approximate_age: '2',
                                       sex: 'male',
                                       description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
        pet_2 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/german-shorthaired-pointer-dogs-and-puppies/german-shorthaired-pointer-dogs-puppies-3.jpg',
                                       name: 'Ms. Snowballs',
                                       approximate_age: '5',
                                       sex: 'female',
                                       description: "Ms. Snowballs is my favorite and I don't want her to go...but then again, I do!")
        pet_3 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/akita-dogs-and-puppies/akita-dogs-puppies-2.jpg',
                                       name: 'Snowball',
                                       approximate_age: '1',
                                       sex: 'female',
                                       description: 'Just the cutest.')

        user_1 = User.create!(name: 'Holly Baker',
                              street_address: '4443 fountain ave',
                              city: 'Lakewood',
                              state: 'CO',
                              zip: '80009')

        application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                            description: 'I am an experienced pet owner for 5 years and I just love this pet!',
                                            pet_names: "#{pet_1.name}, #{pet_2.name}", user_id: user_1.id)

        PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id)

        visit "/applications/#{application_1.id}"

        within "#application-#{application_1.id}-status" do
          expect(page).to have_content('In Progress')
        end

        within '#pet-search' do
          expect(page).to have_content('Search for pets by name')
          expect(find_field(:pet_search).value).to eq(nil)
          click_button('Search')
        end

        within '#pet-search' do
          expect(page).to have_content('Sorry, that pet name does not exist in our records.')
          fill_in 'pet_search', with: 'George'
          click_button('Search')
        end

        within '#pet-search' do
          expect(page).to have_content('Sorry, that pet name does not exist in our records.')
          fill_in 'pet_search', with: pet_3.name.to_s
          click_button('Search')
        end

        within '#pet-search-results' do
          expect(page).to have_content(pet_3.name)
          expect(page).to have_content(pet_2.name)
          expect(page).to_not have_content(pet_1.name)
        end

        within '#pet-search' do
          fill_in 'pet_search', with: pet_1.name.to_s
          click_button('Search')
        end

        within '#pet-search-results' do
          expect(page).to_not have_content(pet_3.name)
          expect(page).to_not have_content(pet_2.name)
          expect(page).to have_content(pet_1.name)
        end
      end

      describe 'after I search for a pet' do
        it 'I can add the pet to my pet adoption list' do
          shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')

          pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                         name: 'Tony',
                                         approximate_age: '2',
                                         sex: 'male',
                                         description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
          pet_2 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/german-shorthaired-pointer-dogs-and-puppies/german-shorthaired-pointer-dogs-puppies-3.jpg',
                                         name: 'Ms. Snowballs',
                                         approximate_age: '5',
                                         sex: 'female',
                                         description: "Ms. Snowballs is my favorite and I don't want her to go...but then again, I do!")
          pet_3 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/akita-dogs-and-puppies/akita-dogs-puppies-2.jpg',
                                         name: 'Regina',
                                         approximate_age: '1',
                                         sex: 'female',
                                         description: 'Just the cutest.')

          user_1 = User.create!(name: 'Holly Baker',
                                street_address: '4443 fountain ave',
                                city: 'Lakewood',
                                state: 'CO',
                                zip: '80009')

          application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                              description: 'I am an experienced pet owner for 5 years and I just love this pet!',
                                              pet_names: "#{pet_1.name}, #{pet_2.name}", user_id: user_1.id)

          PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id)
          PetApplication.create!(pet_id: pet_2.id, application_id: application_1.id)

          visit "/applications/#{application_1.id}"

          within '#pet-search' do
            fill_in 'pet_search', with: pet_3.name.to_s
            click_button('Search')
          end

          within "#pet-#{pet_3.id}" do
            click_button('Adopt this Pet')
          end

          expect(current_path).to eq("/applications/#{application_1.id}")

          within '#application-pets' do
            expect(page).to have_link(pet_3.name)
          end
        end
      end

      describe 'if I have added one or more pets to my application' do
        it 'I can enter a (mandatory) application description and submit my application' do
          shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')
          shelter_2 = Shelter.create(name: 'Pets are Us',
                                     address: '1894 Lincoln.st',
                                     city: 'Tampa',
                                     state: 'Florida',
                                     zip: '32938')
          pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                         name: 'Tony',
                                         approximate_age: '2',
                                         sex: 'male',
                                         description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
          pet_2 = shelter_2.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/german-shorthaired-pointer-dogs-and-puppies/german-shorthaired-pointer-dogs-puppies-3.jpg',
                                         name: 'Ms. Snowballs',
                                         approximate_age: '5',
                                         sex: 'female',
                                         description: "Ms. Snowballs is my favorite and I don't want her to go...but then again, I do!")

          user_1 = User.create!(name: 'Holly Baker',
                                street_address: '4443 fountain ave',
                                city: 'Lakewood',
                                state: 'CO',
                                zip: '80009')

          application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                              pet_names: "#{pet_1.name}, #{pet_2.name}", user_id: user_1.id)

          description = 'I just absolutely love all animals. These two will get my best care!'

          PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id)
          PetApplication.create!(pet_id: pet_2.id, application_id: application_1.id)

          visit "/applications/#{application_1.id}"

          within "#application-#{application_1.id}-submission" do
            expect(page).to have_text('Explain why you would make a good owner for this/these pet(s).')
            expect(find_field('description').value).to eq(nil)
            click_button('Submit Application')
          end

          within "#application-#{application_1.id}-status" do
            expect(page).to have_content("In Progress")
          end

          within "#application-#{application_1.id}-submission" do
            expect(page).to have_content('Application not submitted: Please explain why you would be a good pet owner.')
            fill_in 'description', with: description
            click_button('Submit Application')
          end

          expect(current_path).to eq("/applications/#{application_1.id}")

          within "#application-#{application_1.id}-status" do
            expect(page).to have_content('Pending')
          end

          within '#application-pets' do
            expect(page).to have_content(pet_1.name)
            expect(page).to have_content(pet_2.name)
          end

          expect(page).to_not have_css('#pet-search')
          expect(page).to_not have_css("application-#{application_1.id}-submission")
        end
      end
    end

    describe 'when I have not added any pets to my application' do
      it 'should not see a section to submit my application' do
        shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')
        shelter_2 = Shelter.create(name: 'Pets are Us',
                                   address: '1894 Lincoln.st',
                                   city: 'Tampa',
                                   state: 'Florida',
                                   zip: '32938')
        pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Tony',
                                       approximate_age: '2',
                                       sex: 'male',
                                       description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
        pet_2 = shelter_2.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/german-shorthaired-pointer-dogs-and-puppies/german-shorthaired-pointer-dogs-puppies-3.jpg',
                                       name: 'Ms. Snowballs',
                                       approximate_age: '5',
                                       sex: 'female',
                                       description: "Ms. Snowballs is my favorite and I don't want her to go...but then again, I do!")

        user_1 = User.create!(name: 'Holly Baker',
                              street_address: '4443 fountain ave',
                              city: 'Lakewood',
                              state: 'CO',
                              zip: '80009')

        application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                            pet_names: "#{pet_1.name}, #{pet_2.name}", user_id: user_1.id)

        visit "/applications/#{application_1.id}"

        within '#application-pets' do
          expect(page).to_not have_link(pet_1.name)
          expect(page).to_not have_link(pet_2.name)
        end
        expect(page).to_not have_css("application-#{application_1.id}-submission")
      end
    end

    describe 'when I search a pet name' do
      it 'should return a partially matched name(s) as a result' do
        shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')

        pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Tony',
                                       approximate_age: '2',
                                       sex: 'male',
                                       description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')
        pet_2 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Toto',
                                       approximate_age: '4',
                                       sex: 'male',
                                       description: 'Toto is a energitic dog that loves to play a lot.')
        pet_3 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Tom',
                                       approximate_age: '9',
                                       sex: 'male',
                                       description: 'Tom is a great and lovable dog.')

        user_1 = User.create!(name: 'Holly Baker',
                              street_address: '4443 fountain ave',
                              city: 'Lakewood',
                              state: 'CO',
                              zip: '80009')

        application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                            description: 'I am an experienced pet owner for 5 years and I just love this pet!',
                                            pet_names: "#{pet_1.name}, #{pet_2.name}", user_id: user_1.id)

        PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id)

        visit "/applications/#{application_1.id}"

        within '#pet-search' do
          expect(page).to have_content('Search for pets by name')
          expect(find_field(:pet_search).value).to eq(nil)
          click_button('Search')
        end

        within '#pet-search' do
          fill_in 'pet_search', with: 'To'
          click_button('Search')
        end

        within '#pet-search-results' do
          expect(page).to have_content(pet_1.name)
          expect(page).to have_content(pet_2.name)
          expect(page).to have_content(pet_3.name)
        end
      end
    end

    describe "when I search for a pet name" do
      it "the search is case-insensitive" do
        shelter_1 = Shelter.create!(name: 'Mile High Adoptive Services', address: '500 w first st', city: 'Centennial', state: 'CO', zip: '80022')

        pet_1 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/austalian-shepherd-dog-breed-pictures/10-threequarters.jpg',
                                       name: 'Tony',
                                       approximate_age: '2',
                                       sex: 'male',
                                       description: 'Tony is a wild cracker at times, but is able to calm down and cuddle when needed.')

        pet_2 = shelter_1.pets.create!(img: 'https://dogtime.com/assets/uploads/gallery/akita-dogs-and-puppies/akita-dogs-puppies-2.jpg',
                                       name: 'Snowball',
                                       approximate_age: '1',
                                       sex: 'female',
                                       description: 'Just the cutest.')

        user_1 = User.create!(name: 'Holly Baker',
                             street_address: '4443 fountain ave',
                             city: 'Lakewood',
                             state: 'CO',
                             zip: '80009')

        application_1 = Application.create!(user_name: user_1.name, address: "#{user_1.street_address}, #{user_1.city}, #{user_1.state} #{user_1.zip}",
                                           user_id: user_1.id)

         visit "/applications/#{application_1.id}"

         within "#pet-search" do
           fill_in "pet_search", with: pet_1.name.downcase
           click_button "Search"
         end

         within "#pet-search-results" do
           expect(page).to have_content(pet_1.name)
         end

         within "#pet-search" do
           fill_in "pet_search", with: pet_2.name.upcase
           click_button "Search"
         end

         within "#pet-search-results" do
           expect(page).to have_content(pet_2.name)
         end

         within "#pet-search" do
           fill_in "pet_search", with: pet_1.name
           click_button "Search"
         end

         within "#pet-search-results" do
           expect(page).to have_content(pet_1.name)
         end
       end
     end 

  end
end
