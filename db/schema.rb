# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_05_09_192134) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "grupos", primary_key: "group_id", id: :integer, default: nil, force: :cascade do |t|
    t.string "url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grupos_productos", id: false, force: :cascade do |t|
    t.bigint "grupo_id", null: false
    t.bigint "producto_id", null: false
    t.index ["producto_id", "grupo_id"], name: "index_grupos_productos_on_producto_id_and_grupo_id"
  end

  create_table "ingredientes_associations", force: :cascade do |t|
    t.string "producto_id"
    t.string "ingrediente_id"
    t.float "cantidad"
    t.integer "lote_produccion"
    t.float "cantidad_lote"
    t.float "unidades_bodega"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "productos", primary_key: "sku", id: :string, force: :cascade do |t|
    t.string "nombre"
    t.integer "precio_venta"
    t.float "equivalencia_un_bodega"
    t.integer "lote_produccion"
    t.integer "espacio_produccion"
    t.integer "espacio_recepcion"
    t.integer "stock_minimo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "duracion_h"
    t.float "tiempo_produccion_min"
    t.string "lugar_fabricacion"
    t.integer "costo_prod_lote"
  end

end
