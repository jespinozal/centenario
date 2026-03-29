/*
 * Name: CEN_Solicitud_PreSolicitud_Content
 * Version: 1.0
 * Descripción: Clase virtual para validar y estructurar la solicitud que se enviara a onbase
 * Fecha: 26/11/2020
 * Test: CEN_cls_Onbase
 */

public virtual class CEN_Solicitud_PreSolicitud_Content {
  public String IdSolicitudSalesForce;
  public String NroSolicitud;
  public String origen;
  public String tipoPersona;
  public String sustento;
  public String tipoSolicitud;
  public String tipoVenta;
  public String tipoMoneda;
  public String cuotaInicialPrecio;
  public String fechaPago;

  public String conversionarras;
  public String modalidad;
  public String tipocontrato;

  public String montoCuotaSaldo;
  public Decimal precioVenta;
  public Decimal saldoPrecio;
  public Decimal precioVenta_desc;
  public Decimal nroCuotasSaldo;
  public Decimal inicialPrecio;
  public Decimal cuotaSaldoPrecio;
  public Integer nroCuotasInicial;

  public String medioPublicitario;
  public String motivoCompra;
  public String oficinaVenta;
  public String reserva;
  public String direccionLegal;
  public String departamento;
  public String provincia;
  public String distrito;
  public String refDireccion;
  public String estadoSolicitud;
  public String usuarioAsesorIm;
  public String correoAsesorIm;
  public String fechaCreacion;
  public String fechaCambioEstado;
  public String razonSocial;
  public String ruc;
  public String telefonoEmpresa2;
  public String telefonoEmpresa;
  public String correoEmpresa;
  public String USupervisorVentas;
  public String CSupervisorVentas;
  public String NroFinanciamiento_SAP;
  public String DescripcionAnexo;
  public String canal;
  public String tipoRegimen;
  public String cuotaFacilote;
  public List<DatosTitular> datosTitular = new List<DatosTitular>();
  public List<DetalleFinanciero> detallesFinanciero = new List<DetalleFinanciero>();
  public List<Comentario> comentarios = new List<Comentario>();
  //  Account-Contact
  public class DatosTitular {
    public String nombres;
    public String apellidos;
    public String cargoOcupado;
    public String centroTrabajo;
    public String correo;
    public String direccionTrabajo;
    public String estadoCivil;
    public String fechaNac;
    public String jefe;
    public String lugarNacimiento;
    public String nacionalidad;
    public String tipoDocIdentidad;
    public String nroDocIdentidad;
    public String telefonos;
    public String profesion;
    public String relacionLaboral;
    public String telefonoTrabajo;
    public String tipoMonedaTitular;
    public Decimal promIngresosMensuales;
    public String nroPartida;
    public String paisresidencia;

    public String apoderadoApellido;
    public String apoderadoCheck;
    public String apoderadoDomicilio;
    public String apoderadoNacionalidad;
    public String apoderadoNombre;
    public String apoderadoNroDocumento;
    public String apoderadoNumPartidaRegistral;
    public String apoderadoTipoDocumento;

    public String centroTrabajoDepartamento;
    public String centroTrabajoDistrito;
    public String centroTrabajoProvincia;

    public String detalleActividad;
  }
  //  PRODUCT 2 - LOTE
  public class DetalleFinanciero {
    public String areaTerreno;
    public String urbanizacion;
    public String etapa;
    public String manzana;
    public String lote;
    public String codMaterial;
    public Decimal preciolistalote;
    public Decimal precioventalote;
  }
  //    No es obligatorio
  public class Comentario {
    public String usuarioComentario;
    public String fechaComentario;
    public String motivoComentario;
  }

  // obtiene el xml body para crear la solicitud
  public String getXMLsolicitud() {
    String body =
      '<Formulario xmlns:i="http://www.w3.org/2001/XMLSchema-instance" ' +
      'xmlns="http://schemas.datacontract.org/2004/07/webAuthentic.Models">\r\n' +
      '  <CSupervisorVentas>' +
      CSupervisorVentas +
      '</CSupervisorVentas>\r\n';
    //  para los datos de los titulares
    if (datosTitular.size() > 0) {
      String datos_titulares = '  <DatosTitulares>\r\n';
      for (DatosTitular titular : datosTitular) {
        datos_titulares +=
          '    <Formulario.DatosTitular>\r\n' +
          '      <apellidos>' +
          titular.apellidos +
          ' </apellidos>\r\n' +
          '      <apoderadoApellido>' +
          titular.apoderadoApellido +
          '</apoderadoApellido>\r\n' +
          '      <apoderadoCheck>' +
          titular.apoderadoCheck +
          '</apoderadoCheck>\r\n' +
          '      <apoderadoDomicilio>' +
          titular.apoderadoDomicilio +
          '</apoderadoDomicilio>\r\n' +
          '      <apoderadoNacionalidad>' +
          titular.apoderadoNacionalidad +
          '</apoderadoNacionalidad>\r\n' +
          '      <apoderadoNombre>' +
          titular.apoderadoNombre +
          '</apoderadoNombre>\r\n' +
          '      <apoderadoNroDocumento>' +
          titular.apoderadoNroDocumento +
          '</apoderadoNroDocumento>\r\n' +
          '      <apoderadoNumPartidaRegistral>' +
          titular.apoderadoNumPartidaRegistral +
          '</apoderadoNumPartidaRegistral>\r\n' +
          '      <apoderadoTipoDocumento>' +
          titular.apoderadoTipoDocumento +
          '</apoderadoTipoDocumento>\r\n' +
          '      <cargoOcupado>' +
          titular.cargoOcupado +
          '</cargoOcupado>\r\n' +
          '      <centroTrabajo>' +
          titular.centroTrabajo +
          '</centroTrabajo>\r\n' +
          '      <centroTrabajoDepartamento>' +
          titular.centroTrabajoDepartamento +
          '</centroTrabajoDepartamento>\r\n' +
          '      <centroTrabajoDistrito>' +
          titular.centroTrabajoDistrito +
          '</centroTrabajoDistrito>\r\n' +
          '      <centroTrabajoProvincia>' +
          titular.centroTrabajoProvincia +
          '</centroTrabajoProvincia>\r\n' +
          '      <correo>' +
          titular.correo +
          '</correo>\r\n' +
          '      <detalleActividad>' +
          titular.detalleActividad +
          '</detalleActividad>\r\n' +
          '      <direccionTrabajo>' +
          titular.direccionTrabajo +
          '</direccionTrabajo>\r\n' +
          '      <estadoCivil>' +
          titular.estadoCivil +
          '</estadoCivil>\r\n' +
          '      <fechaNac>' +
          titular.fechaNac +
          '</fechaNac>\r\n' +
          '      <jefe>' +
          titular.jefe +
          '</jefe>\r\n' +
          '      <lugarNacimiento>' +
          titular.lugarNacimiento +
          '</lugarNacimiento>\r\n' +
          '      <nacionalidad>' +
          titular.nacionalidad +
          '</nacionalidad>\r\n' +
          '      <nombres>' +
          titular.nombres +
          '</nombres>\r\n' +
          '      <nroDocIdentidad>' +
          titular.nroDocIdentidad +
          '</nroDocIdentidad>\r\n' +
          '      <nroPartida>' +
          titular.nroPartida +
          '</nroPartida>\r\n' +
          '      <profesion>' +
          titular.profesion +
          '</profesion>\r\n' +
          '      <promIngresosMensuales>' +
          titular.promIngresosMensuales +
          '</promIngresosMensuales>\r\n' +
          '      <relacionLaboral>' +
          titular.relacionLaboral +
          '</relacionLaboral>\r\n' +
          '      <telefonoTrabajo>' +
          titular.telefonoTrabajo +
          '</telefonoTrabajo>\r\n' +
          '      <telefonos>' +
          titular.telefonos +
          '</telefonos>\r\n' +
          '      <tipoDocIdentidad>' +
          titular.tipoDocIdentidad +
          '</tipoDocIdentidad>\r\n' +
          '      <tipoMonedaTitular>' +
          titular.tipoMonedaTitular +
          '</tipoMonedaTitular>\r\n' +
          '      <vPaisresidencia>' +
          titular.paisresidencia +
          '</vPaisresidencia>\r\n' +
          '    </Formulario.DatosTitular>\r\n';
      }
      datos_titulares += '  </DatosTitulares>\r\n';
      body += datos_titulares;
    }
    system.debug('XML PARTE1: ' + body);
    body +=
      '  <DescripcionAnexo>' +
      DescripcionAnexo +
      '</DescripcionAnexo>\r\n';
    //  para los lotes y los detalles financieros
    if (detallesFinanciero.size() > 0) {
      String detalles_financiero = '    <DetalleFinanciero>\r\n';
      for (DetalleFinanciero det_financiero : detallesFinanciero) {
        detalles_financiero +=
          '  <Formulario.DetFinanciero>\r\n' +
          '      <areaTerreno>' +
          det_financiero.areaTerreno +
          '</areaTerreno>\r\n' +
          '      <etapa>' +
          det_financiero.etapa +
          '</etapa>\r\n' +
          '      <lote>' +
          det_financiero.lote +
          '</lote>\r\n' +
          '      <manzana>' +
          det_financiero.manzana +
          '</manzana>\r\n' +
          '      <urbanizacion>' +
          det_financiero.urbanizacion +
          '</urbanizacion>\r\n' +
          '      <vPreciolista>' +
          det_financiero.preciolistalote +
          '</vPreciolista>\r\n' +
          '      <vPrecioventa>' +
          det_financiero.precioventalote +
          '</vPrecioventa>\r\n' +
          '      <zCodigoMaterial>' +
          det_financiero.codMaterial +
          '</zCodigoMaterial>\r\n' +
          '    </Formulario.DetFinanciero>\r\n';
      }
      detalles_financiero = detalles_Financiero + '  </DetalleFinanciero>\r\n';
      body = body + detalles_financiero;
    }
    system.debug('XML PARTE1: ' + body);
    // para la informacion del registro
    body +=
      '  <IdSolicitudSalesForce>' +
      IdSolicitudSalesForce +
      '</IdSolicitudSalesForce>\r\n' +
      '  <MontoCuotaSaldo>' +
      cuotaSaldoPrecio +
      '</MontoCuotaSaldo>\r\n' +
      '  <NroFinanciamiento_SAP>' +
      NroFinanciamiento_SAP +
      '</NroFinanciamiento_SAP>\r\n';
    if (this.esParaActualizar) {
      body += '  <NroSolicitud>' + NroSolicitud + '</NroSolicitud>\r\n';
    }
    system.debug('XML PARTE1: ' + body);
    body +=
      '  <USupervisorVentas>' +
      USupervisorVentas +
      '</USupervisorVentas>\r\n';
    //  para los comentarios
    if (comentarios.size() > 0) {
      String lista_comentario = '  <comentarios>\r\n';
      for (Comentario detalle_comentario : comentarios) {
        lista_comentario +=
          '    <Formulario.Comentarios>\r\n' +
          '      <fechaComentario>' +
          detalle_comentario.fechaComentario +
          '</fechaComentario>\r\n' +
          '      <motivoComentario>' +
          detalle_comentario.motivoComentario +
          '</motivoComentario>\r\n' +
          '      <usuarioComentario>' +
          detalle_comentario.usuarioComentario +
          '</usuarioComentario>\r\n' +
          '    </Formulario.Comentarios>\r\n';
      }
      lista_comentario += '  </comentarios>\r\n';
      body += lista_comentario;
    }
    system.debug('XML PARTE1: ' + body);
    body +=
      '  <correoAsesorIm>' +
      correoAsesorIm +
      '</correoAsesorIm>\r\n' +
      '  <correoEmpresa>' +
      correoEmpresa +
      '</correoEmpresa>\r\n' +
      '  <cuotaInicialPrecio>' +
      String.valueOf(Decimal.valueOf(cuotaInicialPrecio).setScale(2)) +
      '</cuotaInicialPrecio>\r\n';
    if (String.isNotBlank(String.valueOf(cuotaSaldoPrecio))) {
      body +=
        '  <cuotaSaldoPrecio>' +
        String.valueOf(cuotaSaldoPrecio.setScale(2)) +
        '</cuotaSaldoPrecio>\r\n';
    } else {
      body += '  <cuotaSaldoPrecio></cuotaSaldoPrecio>\r\n';
    }
    system.debug('XML PARTE1: ' + body);
    body +=
      '  <departamento>' +
      departamento +
      '</departamento>\r\n' +
      '  <direccionLegal>' +
      direccionLegal +
      '</direccionLegal>\r\n' +
      '  <distrito>' +
      distrito +
      '</distrito>\r\n' +
      '  <estadoSolicitud>' +
      estadoSolicitud +
      '</estadoSolicitud>\r\n' +
      '  <fechaCambioEstado>' +
      fechaCambioEstado +
      '</fechaCambioEstado>\r\n' +
      '  <fechaCreacion>' +
      fechaCreacion +
      '</fechaCreacion>\r\n' +
      '  <fechaPago>' +
      fechaPago +
      '</fechaPago>\r\n';
    if (String.isNotBlank(String.valueOf(inicialPrecio))) {
      body +=
        '  <inicialPrecio>' +
        String.valueOf(inicialPrecio.setScale(2)) +
        '</inicialPrecio>\r\n';
    } else {
      body += '  <inicialPrecio></inicialPrecio>\r\n';
    }
    body +=
      '  <medioPublicitario>' +
      medioPublicitario +
      '</medioPublicitario>\r\n' +
      '  <motivoCompra>' +
      motivoCompra +
      '</motivoCompra>\r\n';
    if (String.isNotBlank(String.valueOf(nroCuotasInicial))) {
      body +=
        '  <nroCuotasInicial>' +
        String.valueOf(nroCuotasInicial) +
        '</nroCuotasInicial>\r\n';
    } else {
      body += '  <nroCuotasInicial></nroCuotasInicial>\r\n';
    }
    if (String.isNotBlank(String.valueOf(nroCuotasSaldo))) {
      body +=
        '  <nroCuotasSaldo>' +
        String.valueOf(nroCuotasSaldo.setScale(0)) +
        '</nroCuotasSaldo>\r\n';
    } else {
      body += '  <nroCuotasSaldo></nroCuotasSaldo>\r\n';
    }
    body +=
      '  <oficinaVenta>' +
      oficinaVenta +
      '</oficinaVenta>\r\n' +
      '  <origen>' +
      origen +
      '</origen>\r\n';
    if (String.isNotBlank(String.valueOf(precioVenta))) {
      body +=
        '  <precioVenta>' +
        String.valueOf(precioVenta.setScale(2)) +
        '</precioVenta>\r\n';
    } else {
      body += '  <precioVenta></precioVenta>\r\n';
    }
    if (String.isNotBlank(String.valueOf(precioVenta_desc))) {
      body +=
        '  <precioVenta_desc>' +
        String.valueOf(precioVenta_desc.setScale(2)) +
        '</precioVenta_desc>\r\n';
    } else {
      body += '  <precioVenta_desc></precioVenta_desc>\r\n';
    }
    body +=
      '  <provincia>' +
      provincia +
      '</provincia>\r\n' +
      '  <razonSocial>' +
      razonSocial +
      '</razonSocial>\r\n' +
      '  <refDireccion>' +
      refDireccion +
      '</refDireccion>\r\n' +
      '  <reserva>' +
      reserva +
      '</reserva>\r\n' +
      '  <ruc>' +
      ruc +
      '</ruc>\r\n';
    if (String.isNotBlank(String.valueOf(saldoPrecio))) {
      body +=
        '  <saldoPrecio>' +
        String.valueOf(saldoPrecio.setScale(2)) +
        '</saldoPrecio>\r\n';
    } else {
      body += '  <saldoPrecio></saldoPrecio>\r\n';
    }
    system.debug('XML PARTE1: ' + body);
    body +=
      '  <sustento>' +
      sustento +
      '</sustento>\r\n' +
      '  <telefonoEmpresa>' +
      telefonoEmpresa +
      '</telefonoEmpresa>\r\n' +
      '  <telefonoEmpresa2>' +
      telefonoEmpresa2 +
      '</telefonoEmpresa2>\r\n' +
      '  <tipoMoneda>' +
      tipoMoneda +
      '</tipoMoneda>\r\n' +
      '  <tipoPersona>' +
      tipoPersona +
      '</tipoPersona>\r\n' +
      '  <tipoSolicitud>' +
      tipoSolicitud +
      '</tipoSolicitud>\r\n' +
      '  <tipoVenta>' +
      tipoVenta +
      '</tipoVenta>\r\n' +
      '  <usuarioAsesorIm>' +
      usuarioAsesorIm +
      '</usuarioAsesorIm>\r\n' +
      '  <vCanal>' +
      canal +
      '</vCanal>\r\n' +
      '  <vConversionarras>' +
      conversionarras +
      '</vConversionarras>\r\n' +
      '  <vCuotaFacilote>' +
      cuotaFacilote +
      '</vCuotaFacilote>\r\n' +
      '  <vModalidad>' +
      modalidad +
      '</vModalidad>\r\n' +
      '  <vTipoContrato>' +
      tipocontrato +
      '</vTipoContrato>\r\n' +
      '  <vTipoRegimen>' +
      tipoRegimen +
      '</vTipoRegimen>\r\n';

    body += '</Formulario>\r\n';
    body = body.remove('null');
    system.debug('XML PARTE FINAL: ' + body);
    return body;
  }
  //    mas datos que tratar
  public String idOportunidad;
  public Map<String, List<String>> mapEntidad_faltantes = new Map<String, List<String>>();
  public Boolean esParaActualizar = false;
  public Quote cotizacion = null;
  public Opportunity oportunidad = null;
  public Account cliente = null;
  public User usuario = null;
  public List<Contact> representantes = new List<Contact>();
  public List<AccountContactRelation> cuenta_contacto_relaciones = new List<AccountContactRelation>();
  public List<Product2> lotes = new List<Product2>();
  public List<OpportunityLineItem> lotes_de_oportunidad = new List<OpportunityLineItem>();
  public List<OpportunityPartner> socios_de_oportunidad = new List<OpportunityPartner>();
  public List<Account> cuentas_socios_oportunidad = new List<Account>();
  public List<QuoteLineItem> lotesDeCotizacion = new List<QuoteLineItem>();

  public void getDataOportunidad() {
    try {
      oportunidad = [
        SELECT
          Id,
          CEN_Nro_solicitud_presolicitud__c,
          CEN_Nro_solicitud_presolicitud_arras__c,
          CEN_Tipo_de_solicitud__c,
          Type,
          AccountId,
          CEN_fld_totalPrecioVentaDscto__c,
          CEN_Tiene_Reserva__c,
          CEN_Motivo_de_Compra__c,
          CEN_Con_sustento__c,
          //CEN_Moneda__c,
          tolabel(CEN_Moneda__c),
          tolabel(CEN_Medio_Publicitario__c),
          tolabel(Leadsource),
          tolabel(CEN_TipoRegimen__c),
          tolabel(CEN_Tipo_de_venta__c),
          tolabel(CEN_Oficina_de_Venta__c),
          Amount,
          CEN_Sub_estado__c,
          CEN_Fecha_de_pago__c,
          CEN_Distrito_opp__c,
          CEN_Distrito_opp__r.Name,
          CEN_Distrito_opp__r.Departamento__c,
          CEN_Distrito_opp__r.Provincia__c,
          CEN_Direcci_n_Legal_Contrato__c,
          CEN_Referencia_Direcci_n__c,
          CloseDate,
          CEN_modalidadPresencial__c,
          CEN_Cuota_Facilote__c,
          CEN_conversionARRAS__c,
          CEN_esContratoARRAS__c,
          CEN_Proforma__c
        FROM Opportunity
        WHERE Id = :idOportunidad
        LIMIT 1
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception generando data xml: ' +
          ex.getMessage() +
          '. Line: ' +
          ex.getLineNumber() +
          '. Type: ' +
          ex.getTypeName()
      );
      mapEntidad_faltantes.put(
        'Oportunidad',
        new List<String>{ 'Registro de Oportunidad' }
      );
    }
  }

  public void getSociosOportunidad() {
    if (
      oportunidad != null &&
      oportunidad.Type != null &&
      oportunidad.Type == 'Natural'
    ) {
      socios_de_oportunidad = [
        SELECT
          Id,
          OpportunityId,
          AccountToId,
          Role,
          IsPrimary,
          CreatedDate,
          CreatedById,
          LastModifiedDate,
          LastModifiedById,
          SystemModstamp,
          IsDeleted,
          ReversePartnerId
        FROM OpportunityPartner
        WHERE
          OpportunityId = :idOportunidad
          AND AccountToId != :oportunidad.AccountId
          AND IsDeleted = FALSE
      ];
      Set<Id> socios_id = new Set<Id>();
      if (socios_de_oportunidad != null && socios_de_oportunidad.size() > 0) {
        for (OpportunityPartner opt : socios_de_oportunidad) {
          socios_id.add(opt.AccountToId);
        }
      }
      cuentas_socios_oportunidad = [
        SELECT
          Id,
          Name,
          LastName,
          FirstName,
          CEN_N_mero_de_documento__pc,
          CEN_Numero_de_documento_del__c,
          Phone,
          PersonEmail,
          CEN_Lugar_de_nacimiento__pc,
          CEN_Distrito__c,
          CEN_Distrito__pc,
          CEN_Distrito__r.Name,
          CEN_Distrito__r.Departamento__c,
          CEN_Distrito__r.Provincia__c,
          CEN_Distrito__pr.Name,
          CEN_Distrito__pr.Departamento__c,
          CEN_Distrito__pr.Provincia__c,
          CEN_Direcci_n__c,
          CEN_Direccion__pc,
          toLabel(CEN_Nacionalidad__pc),
          CEN_Tel_fono_Trabajo__pc,
          CEN_Fecha_de_Nacimiento__c,
          CEN_Nro_deudor_SAP__pc,
          CEN_Tipo_de_documento__c,
          CEN_Tipo_de_documento__pc,
          CEN_Nro_deudor_SAP__c,
          RecordType.Name,
          PersonContactId,
          Moneda__pc,
          CEN_Estado_civil__pc,
          CEN_Tipo_de_relaci_n_laboral__pc,
          CEN_Jefe_Directo__pc,
          CEN_Profesion_u_oficio__pc,
          CEN_Cargo_que_ocupa__pc,
          CEN_Promedio_Mensual_Ingresos__pc,
          CEN_Centro_de_trabajo__c,
          CEN_Direcci_n_Centro_de_Trabajo__pc,
          PersonMobilePhone,
          CEN_Referencia_direccion__c,
          CEN_fld_Numero_de_partida_registral__c,
          CEN_fld_Detalle_de_actividad__c,
          CEN_fld_Tiene_apoderado__c,
          CEN_fld_Nombres_Apoderado__c,
          CEN_fld_Apellidos_apoderado__c,
          CEN_fld_Apellido_mat_apoderado__c,
          CEN_fld_Tipo_de_documento_de_apoderado__c,
          CEN_fld_Numero_de_documento_apoderado__c,
          toLabel(CEN_fld_Nacionalidad_apoderado__c),
          CEN_fld_Direccion_apoderado__c,
          CEN_fld_Correo_empresa__c,
          CEN_paisResidencia__pc
        FROM Account
        WHERE Id IN :socios_id
      ];
    }
  }
  public void getClienteOportunidad() {
    try {
      cliente = [
        SELECT
          Id,
          Name,
          LastName,
          FirstName,
          CEN_N_mero_de_documento__pc,
          CEN_Numero_de_documento_del__c,
          Phone,
          PersonEmail,
          CEN_Lugar_de_nacimiento__pc,
          CEN_Distrito__c,
          CEN_Distrito__pc,
          CEN_Distrito__r.Name,
          CEN_Distrito__r.Departamento__c,
          CEN_Distrito__r.Provincia__c,
          CEN_Distrito__pr.Name,
          CEN_Distrito__pr.Departamento__c,
          CEN_Distrito__pr.Provincia__c,
          CEN_Direcci_n__c,
          CEN_Direccion__pc,
          toLabel(CEN_Nacionalidad__pc),
          CEN_Tel_fono_Trabajo__pc,
          CEN_Fecha_de_Nacimiento__c,
          CEN_Nro_deudor_SAP__pc,
          CEN_Tipo_de_documento__c,
          CEN_Tipo_de_documento__pc,
          CEN_Nro_deudor_SAP__c,
          RecordType.Name,
          PersonContactId,
          Moneda__pc,
          CEN_Estado_civil__pc,
          CEN_Tipo_de_relaci_n_laboral__pc,
          CEN_Jefe_Directo__pc,
          CEN_Profesion_u_oficio__pc,
          CEN_Cargo_que_ocupa__pc,
          CEN_Promedio_Mensual_Ingresos__pc,
          CEN_Centro_de_trabajo__c,
          CEN_Direcci_n_Centro_de_Trabajo__pc,
          PersonMobilePhone,
          CEN_Referencia_direccion__c,
          CEN_fld_Numero_de_partida_registral__c,
          CEN_fld_Detalle_de_actividad__c,
          CEN_fld_Tiene_apoderado__c,
          CEN_fld_Nombres_Apoderado__c,
          CEN_fld_Apellidos_apoderado__c,
          CEN_fld_Apellido_mat_apoderado__c,
          CEN_fld_Tipo_de_documento_de_apoderado__c,
          CEN_fld_Numero_de_documento_apoderado__c,
          toLabel(CEN_fld_Nacionalidad_apoderado__c),
          CEN_fld_Direccion_apoderado__c,
          CEN_fld_Correo_empresa__c,
          CEN_paisResidencia__pc
        FROM Account
        WHERE Id = :oportunidad.AccountId
        LIMIT 1
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception: ' +
          ex.getMessage() +
          '. Line: ' +
          ex.getLineNumber() +
          '. Type: ' +
          ex.getTypeName()
      );
      mapEntidad_faltantes.put(
        'Cliente',
        new List<String>{ 'Registro de Cliente relacionado a la oportunidad.' }
      );
    }
  }
  public void getRepresentantes() {
    cuenta_contacto_relaciones = [
      SELECT Id, ContactId, AccountId, IsActive, IsDirect, IsDeleted
      FROM AccountContactRelation
      WHERE AccountId = :cliente.Id
      LIMIT 50000
    ];
    Set<Id> ids_contactos = new Set<Id>();
    for (AccountContactRelation acr : cuenta_contacto_relaciones) {
      if (String.isNotBlank(acr.ContactId)) {
        ids_contactos.add(acr.ContactId);
      }
    }
    representantes = [
      SELECT
        Id,
        Name,
        LastName,
        FirstName,
        AccountId,
        CEN_N_mero_de_documento__c,
        CEN_Tipo_de_documento__c,
        MobilePhone,
        Phone,
        Email,
        toLabel(CEN_Nacionalidad__c),
        CEN_Tel_fono_Trabajo__c,
        N_Partida_Vigencia_de_poder__c
      FROM Contact
      WHERE Id IN :ids_contactos
      LIMIT 50000
    ];
  }
  public void getCotizacion() {
    try {
      cotizacion = [
        SELECT
          Id,
          CEN_Area__c,
          CEN_Cuota_inicial__c,
          CEN_Inicial__c,
          CEN_Inicial_porct__c,
          CEN_Lote__c,
          CEN_Manzana__c,
          CEN_Monto_cuota_de_inicial_de_precio__c,
          CEN_FirstInstallmentAmount__c,
          CEN_Monto_cuota_del_saldo_de_precio__c,
          CEN_N_cuotas_de_inicial_de_precio__c,
          CEN_N_cuotas_del_saldo_de_precio__c,
          CEN_Numero_de_cuotas_a_financiar__c,
          CEN_Precio_de_venta__c,
          CEN_Precio_de_venta_con_descuento__c,
          CEN_Precio_por_mt2__c,
          CEN_Saldo_del_precio__c,
          CEN_Tasa_de_Interes_compensatorio_anual__c,
          CEN_Tipologia__c,
          LineItemCount,
          OpportunityId,
          CEN_Tipo_de_moneda__c
        FROM Quote
        WHERE OpportunityId = :oportunidad.Id
        ORDER BY CreatedDate DESC
        LIMIT 1
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception: ' +
          ex.getMessage() +
          '. Line: ' +
          ex.getLineNumber() +
          '. Type: ' +
          ex.getTypeName()
      );
      mapEntidad_faltantes.put(
        'Cotización',
        new List<String>{ 'No se encontró últimas cotizaciones generadas.' }
      );
    }
  }
  public void getLotesCotizacion() {
    try {
      lotesDeCotizacion = [
        SELECT
          LineNumber,
          CEN_area_del_lote__c,
          CEN_etapa__c,
          CEN_lote__c,
          CEN_manzana_del_lote__c,
          CEN_precio_m2_cotizado_lote__c,
          CEN_precio_venta_cotizado_lote__c,
          CEN_tipologia_del_lote__c,
          CEN_urbanizacion_proyecto__c,
          Id,
          Product2Id,
          CODLOTE__c,
          CEN_fld_precioVentaDscto__c
        FROM QuoteLineItem
        WHERE QuoteId = :cotizacion.Id
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception: ' +
          ex.getMessage() +
          '. Line: ' +
          ex.getLineNumber() +
          '. Type: ' +
          ex.getTypeName()
      );
    }
    if (lotesDeCotizacion == null || lotesDeCotizacion.isEmpty()) {
      mapEntidad_faltantes.put(
        'Lotes de Cotización',
        new List<String>{
          'No se encontró registros de Lotes de la Cotización.'
        }
      );
    }
  }
  public void getUsuario() {
    try {
      usuario = [
        SELECT
          Id,
          Username,
          CorreoAD__c,
          FederationIdentifier,
          CEN_UserNameAD__c
        FROM User
        WHERE Id = :System.UserInfo.getUserId()
        LIMIT 1
      ];
    } catch (Exception ex) {
      System.debug(
        'Exception: ' +
          ex.getMessage() +
          '. Line: ' +
          ex.getLineNumber() +
          '. Type: ' +
          ex.getTypeName()
      );
      mapEntidad_faltantes.put(
        'Usuario',
        new List<String>{ 'No se encontró más datos de su usuario' }
      );
    }
  }

  //    validador iterativo
  public List<String> validarDatos(
    Map<String, String> campos,
    Map<String, Object> datos
  ) {
    List<String> faltantes = new List<String>();
    for (String field : datos.keySet()) {
      if (campos.keySet().contains(field)) {
        if (
          (datos.get(field) == null ||
          String.isBlank(String.valueOf(datos.get(field))))
        ) {
          faltantes.add(campos.get(field));
        }
        //  debe encontrar los campos que envie
        campos.remove(field);
      }
    }
    //  si quedo restantes en campos, no se encontraron
    faltantes.addAll(campos.values());
    return faltantes;
  }
}