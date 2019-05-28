require 'test_helper'

class DocumentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @document = documents(:one)
  end

  test "should get index" do
    get documents_url
    assert_response :success
  end

  test "should get new" do
    get new_document_url
    assert_response :success
  end

  test "should create document" do
    assert_difference('Document.count') do
      post documents_url, params: { document: { anulacion: @document.anulacion, canal: @document.canal, cantidad: @document.cantidad, cantidadDespachada: @document.cantidadDespachada, cliente: @document.cliente, estado: @document.estado, fechaEntrega: @document.fechaEntrega, notas: @document.notas, order_id: @document.order_id, precioUnitario: @document.precioUnitario, proveedor: @document.proveedor, rechazo: @document.rechazo, sku: @document.sku, urlNotificacion: @document.urlNotificacion } }
    end

    assert_redirected_to document_url(Document.last)
  end

  test "should show document" do
    get document_url(@document)
    assert_response :success
  end

  test "should get edit" do
    get edit_document_url(@document)
    assert_response :success
  end

  test "should update document" do
    patch document_url(@document), params: { document: { anulacion: @document.anulacion, canal: @document.canal, cantidad: @document.cantidad, cantidadDespachada: @document.cantidadDespachada, cliente: @document.cliente, estado: @document.estado, fechaEntrega: @document.fechaEntrega, notas: @document.notas, order_id: @document.order_id, precioUnitario: @document.precioUnitario, proveedor: @document.proveedor, rechazo: @document.rechazo, sku: @document.sku, urlNotificacion: @document.urlNotificacion } }
    assert_redirected_to document_url(@document)
  end

  test "should destroy document" do
    assert_difference('Document.count', -1) do
      delete document_url(@document)
    end

    assert_redirected_to documents_url
  end
end
