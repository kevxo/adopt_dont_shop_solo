class SheltersController < ApplicationController
  def index
    @shelters = Shelter.all
  end

  def new; end

  def create
    shelter = Shelter.new({
                            name: params[:shelter][:name],
                            address: params[:shelter][:address],
                            city: params[:shelter][:city],
                            state: params[:shelter][:state],
                            zip: params[:shelter][:zip]
                          })

    shelter.save

    redirect_to '/shelters'
  end

  def show
    @shelter = Shelter.find(params[:id])
    @reviews = Review.where(shelter_id: @shelter.id)
  end

  def edit
    @shelter = Shelter.find(params[:id])
  end

  def update
    shelter = Shelter.find(params[:id])
    shelter.update({
                     name: params[:shelter][:name],
                     address: params[:shelter][:address],
                     city: params[:shelter][:city],
                     state: params[:shelter][:state],
                     zip: params[:shelter][:zip]
                   })

    shelter.save
    redirect_to "/shelters/#{shelter.id}"
  end

  def destroy
    Shelter.destroy(params[:id])
    redirect_to '/shelters'
  end

  def pet_index
    shelter_id = params[:id]
    @pets = Pet.where("shelter_id  = #{shelter_id}")
  end

  def review_new
    @shelter_id = params[:id]
  end

  def review_create
    review = Review.new({
                          name: params[:review][:name],
                          title: params[:review][:title],
                          picture: params[:review][:picture],
                          content: params[:review][:content],
                          rating: params[:review][:rating],
                          user_id: params[:review][:user_id],
                          shelter_id: params[:id]
                        })

    binding.pry

    review.save!
    redirect_to "/shelters/#{params[:id]}"
  end
end
