class SeriesController < ApplicationController
  before_action :set_series, only: [:show, :edit, :update, :destroy]

  # GET /series
  # GET /series.json
  def index
    @series = Series.all
  end

  # GET /series/1
  # GET /series/1.json
  def show
    # @standings = Result.where(event_id: @series.events.pluck(:id)).group(:user_id).sum(:sprint, :kom, :total)
    @standings = Result.where(event_id: @series.events.pluck(:id)).group(:user_id).pluck('user_id', 'SUM(sprint)', 'SUM(kom)', 'SUM(total)')
    @standings = @standings.sort_by{|r| -r[3]}
  end

  # GET /series/new
  def new
    @series = Series.new
  end

  # GET /series/1/edit
  def edit
  end

  # POST /series
  # POST /series.json
  def create
    @series = Series.new(series_params)

    respond_to do |format|
      if @series.save
        format.html { redirect_to @series, notice: 'Series was successfully created.' }
        format.json { render :show, status: :created, location: @series }
      else
        format.html { render :new }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /series/1
  # PATCH/PUT /series/1.json
  def update
    respond_to do |format|
      if @series.update(series_params)
        format.html { redirect_to @series, notice: 'Series was successfully updated.' }
        format.json { render :show, status: :ok, location: @series }
      else
        format.html { render :edit }
        format.json { render json: @series.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /series/1
  # DELETE /series/1.json
  def destroy
    @series.destroy
    respond_to do |format|
      format.html { redirect_to series_index_url, notice: 'Series was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_series
      @series = Series.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def series_params
      params.require(:series).permit(:name, :description, :start_date, :end_date)
    end
end
