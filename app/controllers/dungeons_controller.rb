class DungeonsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create]

  @@rites = Rite.all

  def show
    @dungeon = Dungeon.find(params[:id])
  end

  def new
    @dungeon = current_user.dungeons.build
    4.times { |i| @dungeon.layers.build(level: i + 1) }
    @rites = @@rites
  end

  def create
    @dungeon = current_user.dungeons.build(dungeon_params)

    if @dungeon.save
      # add additional rites
      @dungeon.rites = Rite.where(id: params[:dungeon][:rite_ids])
      redirect_to @dungeon, notice: "Successfully created."
    else
      @rites = @@rites
      render :new, status: :unprocessable_entity
    end
  end

  private

  def dungeon_params
    params.require(:dungeon).permit(:glyph,
                                    :area,
                                    :depth,
                                    :is_open,
                                    :comment,
                                    rite_ids: [],
                                    layers_attributes: [ :level, :boss_name ])
  end
end
