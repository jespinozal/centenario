({
  doInit: function(component, event, helper) {
    component.set("v.loaded", false);
    var recordId = component.get("v.recordId");
    var action = component.get("c.getFinanciamiento");
    action.setParams({
      "recordId": recordId
    });
    action.setCallback(this, function(response) {
      var state = response.getState();
      if (state === "SUCCESS") {
        var finan = response.getReturnValue();
        //console.log("finan: " + JSON.stringify(finan));
        if (finan.mensaje == "OK") {
            component.set("v.mydata", finan.cabeceras);
            component.set("v.cuenta", finan.cuenta);
            component.set("v.total_financiamientos", finan.cabeceras.length);
          if (finan.cabeceras.length > 0) {
            // console.log("Felipe"+ JSON.stringify(finan.cabeceras[0]));
            component.set("v.proforma", finan.cabeceras[0]);
            var i = 0,
              list = [];
            for (i = 0; i < finan.cabeceras.length; i++) {
              if (i + 1 > 3) {
                break;
              } else {
                list.push(finan.cabeceras[i]);
              }
            }

            component.set("v.data", list);
            var lf = component.find("last-financiamiento");
            $A.util.addClass(lf, "slds-show");
            $A.util.removeClass(lf, "slds-hide");

          }
        } else {
          component.set("v.mensaje", finan.mensaje);
        }
      }
    });
    $A.enqueueAction(action);
  },
  verDetalle: function(component, event, helper) {
    var item = event.getSource().get("v.value");
    //console.log("detalle"+ JSON.stringify(item));
    component.set("v.proforma", item);
      component.set("v.verDetalle", true);
    helper.getDetalleDelFinanciamiento(component, event, item.proforma.PROFORMA, item.proforma.VERSION);

    //Setear Attributes
    component.set("v.localidad", item.proforma.LOCAL_REGISTRO);
    component.set("v.kardex", item.proforma.NUMERO_KARDEX);
    component.set("v.notaria", item.proforma.NOMBRE_NOTARIO);
    component.set("v.partida", item.proforma.PARTIDA_NO);
    component.set("v.fecha", item.proforma.FECHA_ENTREGA_FIS2);

    const username = component.get('v.CurrentUser')['Profile'].Name;
    if(username == 'CEN_Asesor_post_venta' || username == 'System Administrator' || username == 'Administrador del sistema'){
      component.set("v.activeProfile", true);
    }else{
      component.set("v.activeProfile", false);
    }
    //console.log('username: ' + username);
  },
  verTodos: function(component, event, helper) {
    component.set("v.verFinanciamientos", true);
  },
  Cerrar: function(component, event, helper) {
    component.set("v.verFinanciamientos", false);
        component.set("v.proforma", null);
      component.set("v.proformaDetalles", null);
      component.set("v.lotesProforma", null);
      component.set("v.verCampo", true);
  },
  CerrarDetalleProforma: function(component, event, helper) {
      component.set("v.verDetalle", false);
      component.set("v.proforma", null);
      component.set("v.proformaDetalles", null);
      component.set("v.lotesProforma", null);
    component.set("v.verFinanciamientos", true);
    component.set("v.verCampo", true);
  },
  showHide: function (component, event, helper){
    var bol = component.get("v.verCampo");
    bol = !bol;
    component.set("v.verCampo", bol);
  },
  SaveFinancing: function (component, event, helper){

    var item = component.get("v.proforma");
    console.log(component.get("v.kardex"));
    
    var kardex = component.find("inputNumeroKardex").get("v.value");
    var notaria = component.find("inputNombreNotario").get("v.value");
    var localidad = component.find("inputLocalidad").get("v.value");
    var partida = component.find("inputPartidaNo").get("v.value");
    var fecha = '';
    var kardex_x = component.get("v.kardex") !== kardex ? 'X': ''; 
    var notaria_x = component.get("v.notaria")  !== notaria ? 'X': '';
    var localidad_x = component.get("v.localidad")  !== localidad ? 'X': '';
    var partida_x = component.get("v.partida")  !==partida ? 'X': '';
    var fecha_x = '';

    if(item.proforma.ESTADO2 == 'E' && item.proforma.SUBESTADO == 'NI'){
      fecha = component.find("inputFechaEntregaFis2").get("v.value");
      fecha_x = component.get("v.fecha")  !== fecha ? 'X': '';
    }

    // const username = component.get('v.CurrentUser')['Profile'].Name;
    // console.log('username: ' + username);
    var bol = component.get("v.verCampo");
    bol = !bol;
    component.set("v.verCampo", bol);
    
    //var prf = component.find("numberProforma").get("v.value");

    var jsonReq = {
      "proforma": item.proforma.PROFORMA, 
      "notaria": notaria, 
      "localidad": localidad, 
      "kardex": kardex, 
      "partida": partida, 
      "fecha": fecha,
      "notaria_x": notaria_x, 
      "localidad_x": localidad_x, 
      "kardex_x": kardex_x, 
      "partida_x": partida_x, 
      "fecha_x": fecha_x,
    };
    //var req = JSON.parse(JSON.stringify(jsonReq));

    helper.setUpdateOfFinancing(component, event, jsonReq);
    console.log(jsonReq);

    //helper.getDetalleDelFinanciamiento(component, event, item.proforma.PROFORMA, item.proforma.VERSION);

    //setear los atributos FALTA;
    // component.set("v.localidad", localidad);
    // component.set("v.kardex", kardex);
    // component.set("v.notaria", notaria);
    // component.set("v.partida", partida);
    // component.set("v.fecha", fecha);

      setTimeout(function(){
        window.location.reload(1);
    }, 7000);
  },
});