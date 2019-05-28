require "application_system_test_case"

class DocumentsTest < ApplicationSystemTestCase
  setup do
    @document = documents(:one)
  end

  test "visiting the index" do
    visit documents_url
    assert_selector "h1", text: "Documents"
  end

  test "creating a Document" do
    visit documents_url
    click_on "New Document"

    fill_in "Anulacion", with: @document.anulacion
    fill_in "Canal", with: @document.canal
    fill_in "Cantidad", with: @document.cantidad
    fill_in "Cantidaddespachada", with: @document.cantidadDespachada
    fill_in "Cliente", with: @document.cliente
    fill_in "Estado", with: @document.estado
    fill_in "Fechaentrega", with: @document.fechaEntrega
    fill_in "Notas", with: @document.notas
    fill_in "Order", with: @document.order_id
    fill_in "Preciounitario", with: @document.precioUnitario
    fill_in "Proveedor", with: @document.proveedor
    fill_in "Rechazo", with: @document.rechazo
    fill_in "Sku", with: @document.sku
    fill_in "Urlnotificacion", with: @document.urlNotificacion
    click_on "Create Document"

    assert_text "Document was successfully created"
    click_on "Back"
  end

  test "updating a Document" do
    visit documents_url
    click_on "Edit", match: :first

    fill_in "Anulacion", with: @document.anulacion
    fill_in "Canal", with: @document.canal
    fill_in "Cantidad", with: @document.cantidad
    fill_in "Cantidaddespachada", with: @document.cantidadDespachada
    fill_in "Cliente", with: @document.cliente
    fill_in "Estado", with: @document.estado
    fill_in "Fechaentrega", with: @document.fechaEntrega
    fill_in "Notas", with: @document.notas
    fill_in "Order", with: @document.order_id
    fill_in "Preciounitario", with: @document.precioUnitario
    fill_in "Proveedor", with: @document.proveedor
    fill_in "Rechazo", with: @document.rechazo
    fill_in "Sku", with: @document.sku
    fill_in "Urlnotificacion", with: @document.urlNotificacion
    click_on "Update Document"

    assert_text "Document was successfully updated"
    click_on "Back"
  end

  test "destroying a Document" do
    visit documents_url
    page.accept_confirm do
      click_on "Destroy", match: :first
    end

    assert_text "Document was successfully destroyed"
  end
end
