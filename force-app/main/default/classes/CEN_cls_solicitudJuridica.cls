/*
 * Name: CEN_cls_solicitudJuridica
 * Version: 1.0
 * Descripción:  Crear Solicitud para cliente jurídico
 * Fecha: 17/06/2020
 * Test: CEN_cls_solicitudJuridicaTest
 */
public with sharing class CEN_cls_solicitudJuridica extends CEN_Solicitud_PreSolicitud_Content {
  public CEN_cls_solicitudJuridica(
    String idOportunidad,
    Boolean esParaActualizar
  ) {
    this.esParaActualizar = esParaActualizar;
    this.idOportunidad = idOportunidad;
    getData();
  }
  public void getData() {
    getDataOportunidad();
    getClienteOportunidad();
    getRepresentantes();
    getCotizacion();
    getLotesCotizacion();
    getUsuario();
  }

  public void setData() {
    Comentario comentario = new Comentario();
    // -- por defecto
    this.comentarios.add(comentario);
    this.IdSolicitudSalesForce = oportunidad.Id;
    this.origen = 'Salesforce';
    this.fechaCreacion = Datetime.now()
      .format('dd/MM/yyyy HH:mm', 'America/Lima');
    this.tipoSolicitud = 'SOLICITUD';
    this.reserva = 'NO';
    this.usuarioAsesorIm = CEN_cls_XMLHelper.getString(
      usuario.CEN_UserNameAD__c
    );
    this.correoAsesorIm = CEN_cls_XMLHelper.getString(usuario.CorreoAD__c);
    //  oportunidad
    this.conversionarras = oportunidad.CEN_conversionARRAS__c ? 'SI' : 'NO';
    this.tipocontrato = oportunidad.CEN_esContratoARRAS__c
      ? 'ARRAS'
      : 'COMPRAVENTA';
    this.modalidad = oportunidad.CEN_modalidadPresencial__c
      ? 'PRESENCIAL'
      : 'NO PRESENCIAL';
    this.tipoPersona = oportunidad.Type.toUpperCase();
    this.sustento = oportunidad.CEN_Con_sustento__c;
    this.NroFinanciamiento_SAP = String.valueOf(
      Integer.valueOf(oportunidad.CEN_Proforma__c)
    );
    //this.tipoSolicitud = oportunidad.CEN_Tipo_de_solicitud__c;
    this.tipoVenta = CEN_cls_XMLHelper.getString(
      oportunidad.CEN_Tipo_de_venta__c
    );
    this.reserva = oportunidad.CEN_Tiene_Reserva__c;
    this.fechaPago = Datetime.newInstance(
        oportunidad.CloseDate.year(),
        oportunidad.CloseDate.month(),
        oportunidad.CloseDate.day()
      )
      .format('dd/MM/yyyy', 'America/Lima');
    this.medioPublicitario = oportunidad.CEN_Medio_Publicitario__c;
    this.motivoCompra = CEN_cls_XMLHelper.getString(
      oportunidad.CEN_Motivo_de_Compra__c
    );
    this.oficinaVenta = CEN_cls_XMLHelper.getString(
      oportunidad.CEN_Oficina_de_Venta__c
    );
    this.direccionLegal = oportunidad.CEN_Direcci_n_Legal_Contrato__c;
    this.departamento = oportunidad.CEN_Distrito_opp__r.Departamento__c;
    this.provincia = oportunidad.CEN_Distrito_opp__r.Provincia__c;
    this.distrito = oportunidad.CEN_Distrito_opp__r.Name;
    this.tipoMoneda = oportunidad.CEN_Moneda__c;
    this.refDireccion = CEN_cls_XMLHelper.getString(
      oportunidad.CEN_Referencia_Direcci_n__c
    );
    if (this.esParaActualizar) {
      this.NroSolicitud = oportunidad.CEN_esContratoARRAS__c
        ? oportunidad.CEN_Nro_solicitud_presolicitud_arras__c
        : oportunidad.CEN_Nro_solicitud_presolicitud__c;
      //this.estadoSolicitud = 'PENDIENTE';
    }
    this.canal = oportunidad.LeadSource;
    this.tipoRegimen = oportunidad.CEN_TipoRegimen__c;
    this.cuotaFacilote = oportunidad.CEN_Cuota_Facilote__c ? '1' : '0';
    //  cotización
    this.precioVenta_desc = cotizacion.CEN_Precio_de_venta_con_descuento__c;
    this.precioVenta = cotizacion.CEN_Precio_de_venta__c;
    this.inicialPrecio = cotizacion.CEN_Cuota_inicial__c;
    this.nroCuotasInicial = Integer.valueOf(
      cotizacion.CEN_N_cuotas_de_inicial_de_precio__c
    );
    // this.cuotaInicialPrecio = String.valueOf(
    //   cotizacion.CEN_Monto_cuota_de_inicial_de_precio__c
    // );
    this.cuotaInicialPrecio = cotizacion.CEN_FirstInstallmentAmount__c > 0
      ? String.valueOf(cotizacion.CEN_FirstInstallmentAmount__c)
      : String.valueOf(cotizacion.CEN_Monto_cuota_de_inicial_de_precio__c);
    this.saldoPrecio = cotizacion.CEN_Saldo_del_precio__c;
    this.nroCuotasSaldo = cotizacion.CEN_N_cuotas_del_saldo_de_precio__c;
    this.montoCuotaSaldo = String.valueOf(
      cotizacion.CEN_Monto_cuota_del_saldo_de_precio__c
    );
    this.cuotaSaldoPrecio = cotizacion.CEN_Monto_cuota_del_saldo_de_precio__c;
    //  lotes de cotización
    for (QuoteLineItem obj : this.lotesDeCotizacion) {
      DetalleFinanciero objDetalleFinanciero = new DetalleFinanciero();
      objDetalleFinanciero.urbanizacion = obj.CEN_urbanizacion_proyecto__c;
      objDetalleFinanciero.etapa = obj.CEN_etapa__c;
      objDetalleFinanciero.manzana = obj.CEN_manzana_del_lote__c;
      objDetalleFinanciero.lote = obj.CEN_lote__c;
      objDetalleFinanciero.areaTerreno = String.valueOf(
        obj.CEN_area_del_lote__c
      );
      objDetalleFinanciero.codMaterial = obj.CODLOTE__c;
      this.detallesFinanciero.add(objDetalleFinanciero);
    }
    // cliente juridico
    this.razonSocial = CEN_cls_XMLHelper.getString(cliente.Name);
    this.ruc = CEN_cls_XMLHelper.getString(
      cliente.CEN_Numero_de_documento_del__c
    );
    this.correoEmpresa = CEN_cls_XMLHelper.getString(
      cliente.CEN_fld_Correo_empresa__c
    );
    this.telefonoEmpresa = CEN_cls_XMLHelper.getString(cliente.Phone);

    for (Contact repre : representantes) {
      DatosTitular datos_titular = new DatosTitular();
      datos_titular.nombres = CEN_cls_XMLHelper.getString(repre.FirstName);
      datos_titular.apellidos = CEN_cls_XMLHelper.getString(repre.LastName);
      datos_titular.tipoDocIdentidad = CEN_cls_XMLHelper.getString(
        repre.CEN_Tipo_de_documento__c
      );
      datos_titular.nroDocIdentidad = CEN_cls_XMLHelper.getString(
        repre.CEN_N_mero_de_documento__c
      );
      datos_titular.telefonos = CEN_cls_XMLHelper.getString(repre.Phone);
      datos_titular.correo = CEN_cls_XMLHelper.getString(repre.Email);
      datos_titular.nroPartida = CEN_cls_XMLHelper.getString(
        repre.N_Partida_Vigencia_de_poder__c
      );
      datosTitular.add(datos_titular);
    }
  }

  //  realizar las validaciones de todos los campos obligatorios
  //  para la solicitud natural
  public void validarData() {
    this.mapEntidad_faltantes = new Map<String, List<String>>();
    //  validar para oportunidad
    if (this.oportunidad != null) {
      Map<String, String> obligatoriosOportunidad = setObligatoriosOportunidad();
      Map<String, Object> mapOportunidad = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(this.oportunidad)
      );
      List<String> faltantesOportunidad = validarDatos(
        obligatoriosOportunidad,
        mapOportunidad
      );
      if (faltantesOportunidad != null && !faltantesOportunidad.isEmpty()) {
        mapEntidad_faltantes.put('Oportunidad', faltantesOportunidad);
      }
    }

    //  validar para cuentas
    if (this.cliente != null) {
      Map<String, String> obligatoriosCuenta = setObligatoriosCuenta();
      Map<String, Object> mapCuenta = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(this.cliente)
      );
      List<String> faltantesCuenta = validarDatos(
        obligatoriosCuenta,
        mapCuenta
      );
      if (faltantesCuenta != null && !faltantesCuenta.isEmpty()) {
        mapEntidad_faltantes.put('Cuenta', faltantesCuenta);
      }
    }
    //  validar para cotizacion
    if (this.cotizacion != null) {
      Map<String, String> obligatoriosCotizacion = setObligatoriosCotizacion();
      Map<String, Object> mapCotizacion = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(this.cotizacion)
      );
      List<String> faltantesCotizacion = validarDatos(
        obligatoriosCotizacion,
        mapCotizacion
      );
      if (faltantesCotizacion != null && !faltantesCotizacion.isEmpty()) {
        mapEntidad_faltantes.put('Cotización', faltantesCotizacion);
      }
    }
    //  validar para lotes de cotizacion
    if (this.lotesDeCotizacion != null) {
      for (QuoteLineItem obj : this.lotesDeCotizacion) {
        Map<String, String> obligatoriosLoteCotizacion = setObligatoriosLoteCotizacion();
        Map<String, Object> mapLoteCotizado = (Map<String, Object>) JSON.deserializeUntyped(
          JSON.serialize(obj)
        );
        List<String> faltantesLoteCotizado = validarDatos(
          obligatoriosLoteCotizacion,
          mapLoteCotizado
        );
        if (faltantesLoteCotizado != null && !faltantesLoteCotizado.isEmpty()) {
          mapEntidad_faltantes.put(
            'Lote Cotizado ' + obj.LineNumber,
            faltantesLoteCotizado
          );
        }
      }
    }
    //  validar para representantes
    if (this.representantes != null) {
      Integer count = 1;
      for (Contact obj : this.representantes) {
        Map<String, String> obligatoriosRepresentante = setObligatoriosRepresentante();
        Map<String, Object> mapRepresentante = (Map<String, Object>) JSON.deserializeUntyped(
          JSON.serialize(obj)
        );
        List<String> faltantesRepresentante = validarDatos(
          obligatoriosRepresentante,
          mapRepresentante
        );
        if (
          faltantesRepresentante != null && !faltantesRepresentante.isEmpty()
        ) {
          mapEntidad_faltantes.put(
            String.valueOf(count) + '. Representante ' + obj.Name,
            faltantesRepresentante
          );
          count++;
        }
      }
    }
    //  validar datos del usuario
    if (this.usuario != null) {
      Map<String, String> obligatoriosLoteUsuario = setObligatoriosUsuario();
      Map<String, Object> mapUsuario = (Map<String, Object>) JSON.deserializeUntyped(
        JSON.serialize(this.usuario)
      );
      List<String> faltantesUsuario = validarDatos(
        obligatoriosLoteUsuario,
        mapUsuario
      );
      if (faltantesUsuario != null && !faltantesUsuario.isEmpty()) {
        mapEntidad_faltantes.put('Usuario', faltantesUsuario);
      }
    }
  }

  private Map<String, String> setObligatoriosOportunidad() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put('Type', 'Tipo');
    obligatorios.put('CEN_Con_sustento__c', '¿Con sustento?');
    obligatorios.put('CEN_Tipo_de_solicitud__c', 'Tipo de solicitud');
    obligatorios.put('CEN_Tipo_de_venta__c', 'Tipo de venta');
    obligatorios.put('CloseDate', 'Fecha de pago');
    obligatorios.put('CEN_Medio_Publicitario__c', 'Medio publicitario');
    obligatorios.put('CEN_Motivo_de_Compra__c', 'Motivo de compra');
    obligatorios.put('CEN_Oficina_de_Venta__c', 'Oficina de venta');
    obligatorios.put(
      'CEN_Direcci_n_Legal_Contrato__c',
      'Dirección Legal (Contrato)'
    );
    obligatorios.put('CEN_Distrito_opp__c', 'Distrito');
    obligatorios.put('CEN_Tiene_Reserva__c', 'Tiene Reserva');
    obligatorios.put('CEN_Moneda__c', 'Moneda');
    obligatorios.put('CEN_Referencia_Direcci_n__c', 'Referencia direccion');
    if (this.esParaActualizar) {
      if (oportunidad.CEN_esContratoARRAS__c) {
        obligatorios.put(
          'CEN_Nro_solicitud_presolicitud_arras__c',
          'Nro solicitud Onbase ARRAS'
        );
      } else {
        obligatorios.put(
          'CEN_Nro_solicitud_presolicitud__c',
          'Nro solicitud Onbase CVG'
        );
      }
    }
    return obligatorios;
  }

  private Map<String, String> setObligatoriosCuenta() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put('Name', 'Nombre');
    obligatorios.put('CEN_Tipo_de_documento__c', 'Tipo de documento');
    obligatorios.put('CEN_Numero_de_documento_del__c', 'Número de documento');
    return obligatorios;
  }
  private Map<String, String> setObligatoriosRepresentante() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put('FirstName', 'Nombre');
    obligatorios.put('LastName', 'Apellido');
    obligatorios.put('CEN_Tipo_de_documento__c', 'Tipo de documento');
    obligatorios.put('CEN_N_mero_de_documento__c', 'Número de documento');
    obligatorios.put(
      'N_Partida_Vigencia_de_poder__c',
      'N° Partida (Vigencia de poder)'
    );
    return obligatorios;
  }

  private Map<String, String> setObligatoriosCotizacion() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put(
      'CEN_Precio_de_venta_con_descuento__c',
      'Precio de venta con descuento'
    );
    obligatorios.put('CEN_Precio_de_venta__c', 'Precio de venta');
    obligatorios.put('CEN_Cuota_inicial__c', 'Inicial');
    obligatorios.put(
      'CEN_N_cuotas_de_inicial_de_precio__c',
      'Número de cuotas (inicial)'
    );
    obligatorios.put(
      'CEN_Monto_cuota_de_inicial_de_precio__c',
      'Monto de la cuota (inicial)'
    );
    obligatorios.put('CEN_Saldo_del_precio__c', 'Monto a financiar');
    obligatorios.put(
      'CEN_N_cuotas_del_saldo_de_precio__c',
      'Número de cuotas (financiamiento)'
    );
    obligatorios.put(
      'CEN_Monto_cuota_del_saldo_de_precio__c',
      'Monto de cuota (financiamiento)'
    );
    return obligatorios;
  }

  private Map<String, String> setObligatoriosLoteCotizacion() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put(
      'CEN_urbanizacion_proyecto__c',
      'Urbanización del Proyecto'
    );
    obligatorios.put('CEN_etapa__c', 'Etapa del Proyecto');
    obligatorios.put('CEN_manzana_del_lote__c', 'Manzana del lote');
    obligatorios.put('CEN_lote__c', 'Lote');
    obligatorios.put('CEN_area_del_lote__c', 'Área del Lote');
    return obligatorios;
  }

  private Map<String, String> setObligatoriosUsuario() {
    Map<String, String> obligatorios = new Map<String, String>();
    obligatorios.put('CEN_UserNameAD__c', 'UserNameAD');
    obligatorios.put('CorreoAD__c', 'CorreoAD');
    return obligatorios;
  }
}