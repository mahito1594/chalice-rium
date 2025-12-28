class DungeonsController < ApplicationController
  before_action :authenticate_user!, only: %i[new create edit update destroy]
  before_action :set_own_dungeon, only: %i[edit update destroy]
  before_action :set_rites, only: %i[new create edit update index]

  def index
    @dungeons = Dungeon.all
                       .with_area(filter_params[:area])
                       .with_depth(filter_params[:depth])
                       .with_all_rites(filter_params[:rite_ids])
                       .preload(:rites)
                       .order(created_at: :desc)
                       .page(params[:page])

    # Filter form options
    @area_options = Dungeon.areas.keys.map { |area| [ t("enums.dungeon.area.#{area}"), area ] }
    @depth_options = (1..5).to_a.reverse
  end

  def show
    @dungeon = Dungeon.find(params[:id])
  end

  def new
    @dungeon = current_user.dungeons.build.prepare_for_form
  end

  def create
    @dungeon = current_user.dungeons.build(dungeon_params)
    # add additional rites
    @dungeon.rites = Rite.where(id: params[:dungeon][:rite_ids])

    if @dungeon.save
      redirect_to @dungeon, notice: "聖杯ダンジョンが登録されました。" # TODO: Use I18n
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
      redirect_to @dungeon, notice: "聖杯ダンジョンが更新されました。" # TODO: Use I18n
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @dungeon.destroy!
    redirect_to root_path, notice: "聖杯ダンジョンが削除されました。" # TODO: Use I18n
  end

  private

  def set_own_dungeon
    @dungeon = current_user.dungeons.find(params[:id])
  end

  def set_rites
    @rites = Rite.all.order(id: :asc)
  end

  def filter_params
    params.fetch(:filter, {}).permit(:area, :depth, rite_ids: [])
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
