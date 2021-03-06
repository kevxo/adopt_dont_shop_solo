require 'rails_helper'

RSpec.describe PetApplication, type: :model do
  describe "relationships" do
    it { should belong_to :application}
    it { should belong_to :pet}
  end

  describe "instance methods" do
    it "default_status" do
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

      application_1 = Application.create!(user_name: user.name, user_id: user.id)

      pet_application_1 = PetApplication.create!(pet_id: pet1.id, application_id: application_1.id)
      pet_application_2 = PetApplication.create!(pet_id: pet2.id, application_id: application_1.id)

      expect(pet_application_1.application_status).to eq("Pending")
      expect(pet_application_2.application_status).to eq("Pending")
    end

    it "all_approved?" do
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

      shelter_2 = Shelter.create!(name: "Colorado Cares", address: "867 magnolia st", city: "Lakewood", state: "CO", zip: "80022")


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

      pet_3 = shelter_2.pets.create!(img: "https://dogtime.com/assets/uploads/gallery/akita-dogs-and-puppies/akita-dogs-puppies-2.jpg",
                                     name: "Snowball",
                                     approximate_age: "1",
                                     sex: "female",
                                     description: "Just the cutest.")

      pet_4 = shelter_2.pets.create!(img: "https://dogtime.com/assets/uploads/gallery/golden-retriever-dogs-and-puppies/golden-retriever-dogs-puppies-10.jpg",
                                     name: "Watson",
                                     approximate_age: "3",
                                     sex: "male",
                                     description: "He may look dumb, and he is.")

      application_1 = Application.create!(user_name: user.name, user_id: user.id, application_status: "Pending")

      pet_app_1 = PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id, application_status: "Approved")
      pet_app_2 = PetApplication.create!(pet_id: pet_2.id, application_id: application_1.id, application_status: "Approved")
      pet_app_3 = PetApplication.create!(pet_id: pet_3.id, application_id: application_1.id, application_status: "Approved")
      pet_app_4 = PetApplication.create!(pet_id: pet_4.id, application_id: application_1.id, application_status: "Approved")

      application_pets = PetApplication.where(application_id: application_1.id)

      expect(PetApplication.all_approved?(application_1.id)).to eq(true)

      pet_app_1.update!(application_status: "Rejected")

      expect(PetApplication.all_approved?(application_1.id)).to eq(false)
    end

    it "any_pending?" do
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

      shelter_2 = Shelter.create!(name: "Colorado Cares", address: "867 magnolia st", city: "Lakewood", state: "CO", zip: "80022")


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

      pet_3 = shelter_2.pets.create!(img: "https://dogtime.com/assets/uploads/gallery/akita-dogs-and-puppies/akita-dogs-puppies-2.jpg",
                                     name: "Snowball",
                                     approximate_age: "1",
                                     sex: "female",
                                     description: "Just the cutest.")

      pet_4 = shelter_2.pets.create!(img: "https://dogtime.com/assets/uploads/gallery/golden-retriever-dogs-and-puppies/golden-retriever-dogs-puppies-10.jpg",
                                     name: "Watson",
                                     approximate_age: "3",
                                     sex: "male",
                                     description: "He may look dumb, and he is.")

      application_1 = Application.create!(user_name: user.name, user_id: user.id, application_status: "Pending")

      pet_app_1 = PetApplication.create!(pet_id: pet_1.id, application_id: application_1.id, application_status: "Approved")
      pet_app_2 = PetApplication.create!(pet_id: pet_2.id, application_id: application_1.id, application_status: "Rejected")
      pet_app_3 = PetApplication.create!(pet_id: pet_3.id, application_id: application_1.id, application_status: "Approved")
      pet_app_4 = PetApplication.create!(pet_id: pet_4.id, application_id: application_1.id, application_status: "Pending")

      expect(PetApplication.any_pending?(application_1.id)).to eq(true)

      pet_app_4.update!(application_status: "Rejected")

      expect(PetApplication.any_pending?(application_1.id)).to eq(false)
    end

    it "self.find_pet_applications(pet_id)" do
      user_1 = User.create!(name: 'Bob Woodword',
                          street_address: '1234 Test Dr',
                          city: 'Denver',
                          state: 'Colorado',
                          zip: '12345')

      user_2  = User.create!(name: 'Jeff Daniels',
                          street_address: '455 west dr',
                          city: 'Denver',
                          state: 'Colorado',
                          zip: '87709')

      user_3 = User.create!(name: 'Holly Baker',
                          street_address: '4443 fountain ave',
                          city: 'Lakewood',
                          state: 'CO',
                          zip: '80009')

      shelter_1 = Shelter.create!(name: "Rocky Mountain High", address: "1234 fake st.", city: "Denver", state: "CO", zip: "45505")

      pet1 = Pet.create!(img: 'https://upload.wikimedia.org/wikipedia/commons/a/a3/June_odd-eyed-cat.jpg',
                         name: 'Mittens',
                         approximate_age: '6 years',
                         sex: 'Male',
                         shelter_id: shelter_1.id)

      application_1 = Application.create!(user_name: user_1.name, user_id: user_1.id, application_status: "Pending")
      application_2 = Application.create!(user_name: user_2.name, user_id: user_1.id, application_status: "Pending")
      application_3 = Application.create!(user_name: user_3.name, user_id: user_1.id, application_status: "Pending")

      pet_app_1 = PetApplication.create!(pet_id: pet1.id, application_id: application_1.id)
      pet_app_2 = PetApplication.create!(pet_id: pet1.id, application_id: application_2.id)
      pet_app_3 = PetApplication.create!(pet_id: pet1.id, application_id: application_3.id)

      applications_result = [application_1, application_2, application_3]

      expect(PetApplication.find_pet_applications(pet1.id)).to eq(applications_result)
    end
  end
end
