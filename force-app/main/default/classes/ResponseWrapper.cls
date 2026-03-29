/*
 * Name: ResponseWrapper
 * Version: 1.0
 * Descripción: clase response wrapper para responses aura
 * Fecha: 8/11/2020
 * TestClass:
 */
public virtual class ResponseWrapper {
  @AuraEnabled
  public Boolean ok;
  @AuraEnabled
  public String mensaje;
  @AuraEnabled
  public String detalle;
  public ResponseWrapper(){
    this.ok = false;
    this.mensaje = null;
    this.detalle = null;
  }
}