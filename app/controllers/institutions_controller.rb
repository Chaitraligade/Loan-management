# app/controllers/institutions_controller.rb
class InstitutionsController < ApplicationController
  before_action :set_institution, only: [:show, :edit, :update, :destroy]

  def index
    @institutions = Institution.all
  end

  def show
  end

  def new
    @institution = Institution.new
  end

  def create
    @institution = Institution.new(institution_params)

    if @institution.save
      redirect_to @institution, notice: 'Institution was successfully created.'
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @institution.update(institution_params)
      redirect_to @institution, notice: 'Institution was successfully updated.'
    else
      render :edit
    end
  end

  def destroy
    @institution.destroy
    redirect_to institutions_url, notice: 'Institution was successfully destroyed.'
  end

  private

  def set_institution
    @institution = Institution.find(params[:id])
  end

  def institution_params
    params.require(:institution).permit(:name)
  end
end
