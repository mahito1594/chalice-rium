class DungeonsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_own_dungeon, only: %i[edit update destroy]
  before_action :set_rites, only: %i[new create edit update]

  @@rites = Rite.all

  def show
    @dungeon = Dungeon.find(params[:id])
  end

  def new
    @dungeon = current_user.dungeons.build.prepare_for_form
  end

  def create
    @dungeon = current_user.dungeons.build(dungeon_params)

    if @dungeon.save
      # add additional rites
      @dungeon.rites = Rite.where(id: params[:dungeon][:rite_ids])
      redirect_to @dungeon, notice: "Successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dungeon.prepare_for_form
  end

  def update
    if @dungeon.update(update_dungeon_params)
      # disallow to update rites
      redirect_to @dungeon, notice: "Successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dungeon.destroy!
    redirect_to root_path, notice: "Successfully deleted."
  end

  private

  def set_own_dungeon
    @dungeon = current_user.dungeons.find(params[:id])
  end

  def set_rites
    @rites = @@rites
  end

  def dungeon_params
    params.require(:dungeon).permit(:glyph,
                                    :area,
                                    :depth,
                                    :is_open,
                                    :comment,
                                    rite_ids: [],
                                    layers_attributes: [ :level, :boss_name ])
  end

  def update_dungeon_params
    params.require(:dungeon).permit(:comment,
                                    layers_attributes: [ :level, :boss_name, :id ])
  end
end
