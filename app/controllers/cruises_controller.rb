class CruisesController < ApplicationController
  before_action :set_cruise, only: [:show, :edit, :update, :destroy]

  # GET /cruises
  # GET /cruises.json
  def index
    cruises = Cruise.joins(stops: :port).pluck(:id, 'cruises.code AS code', 'cruises.start AS start',
                               'cruises.days AS days', 'cruises.price AS price',
                               'ports.name AS port',
                               'stops.d_from AS d_from', 'stops.d_to AS d_to')
    @cruises = cruises.each_with_object({}) do |cruise, s|
      cruise_data = s[cruise[0]]
      unless cruise_data
        cruise_data = s[cruise[0]] = { id: cruise[0], code: cruise[1], start: cruise[2],
                                       days: cruise[3], price: cruise[4],
                                       ports: [] }
      end
      cruise_data[:ports] << { port: cruise[5], dFrom: cruise[6], dTo: cruise[7] }
    end.values
  end

  # GET /cruises/1
  # GET /cruises/1.json
  def show
  end

  # GET /cruises/new
  def new
    @cruise = Cruise.new
  end

  # GET /cruises/1/edit
  def edit
  end

  # POST /cruises
  # POST /cruises.json
  def create
    @cruise = Cruise.new(cruise_params)

    respond_to do |format|
      if @cruise.save
        format.html { redirect_to @cruise, notice: 'Cruise was successfully created.' }
        format.json { render :show, status: :created, location: @cruise }
      else
        format.html { render :new }
        format.json { render json: @cruise.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /cruises/1
  # PATCH/PUT /cruises/1.json
  def update
    respond_to do |format|
      if @cruise.update(cruise_params)
        format.html { redirect_to @cruise, notice: 'Cruise was successfully updated.' }
        format.json { render :show, status: :ok, location: @cruise }
      else
        format.html { render :edit }
        format.json { render json: @cruise.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /cruises/1
  # DELETE /cruises/1.json
  def destroy
    @cruise.destroy
    respond_to do |format|
      format.html { redirect_to cruises_url, notice: 'Cruise was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cruise
      @cruise = Cruise.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cruise_params
      params.require(:cruise).permit(:line_id, :code, :start, :days)
    end
end
