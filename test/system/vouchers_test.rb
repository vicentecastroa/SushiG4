require "application_system_test_case"

class VouchersTest < ApplicationSystemTestCase
  setup do
    @voucher = vouchers(:one)
  end

  test "visiting the index" do
    visit vouchers_url
    assert_selector "h1", text: "Vouchers"
  end

  test "creating a Voucher" do
    visit vouchers_url
    click_on "New Voucher"

    fill_in "Hora entrega", with: @voucher.hora_entrega
    fill_in "Hora pedido", with: @voucher.hora_pedido
    fill_in "Id", with: @voucher.id
    fill_in "Iva pagado", with: @voucher.iva_pagado
    fill_in "Monto final", with: @voucher.monto_final
    fill_in "Monto neto", with: @voucher.monto_neto
    fill_in "Nombre", with: @voucher.nombre
    fill_in "Productos", with: @voucher.productos
    fill_in "Ubicacion", with: @voucher.ubicacion
    click_on "Create Voucher"

    assert_text "Voucher was successfully created"
    click_on "Back"
  end

  test "updating a Voucher" do
    visit vouchers_url
    click_on "Edit", match: :first

    fill_in "Hora entrega", with: @voucher.hora_entrega
    fill_in "Hora pedido", with: @voucher.hora_pedido
    fill_in "Id", with: @voucher.id
    fill_in "Iva pagado", with: @voucher.iva_pagado
    fill_in "Monto final", with: @voucher.monto_final
    fill_in "Monto neto", with: @voucher.monto_neto
    fill_in "Nombre", with: @voucher.nombre
    fill_in "Productos", with: @voucher.productos
    fill_in "Ubicacion", with: @voucher.ubicacion
    click_on "Update Voucher"

    assert_text "Voucher was successfully updated"
    click_on "Back"
  end

  test "destroying a Voucher" do
    visit vouchers_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Voucher was successfully destroyed"
  end
end
