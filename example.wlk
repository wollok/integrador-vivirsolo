object mundo{ 
  const personas = []

  method transcurrirUnMes(){
    calendario.pasarMes()
    personas.forEach{persona => persona.cobrarSalario()}
  }

  method personaConMasCosas() = personas.max({persona => persona.cantidadCosas()})
}

object calendario {
  var property mes = 1
  method pasarMes() {
    mes = mes + 1
  }
}

class Persona{
  const efectivo = new PagoInmediato()
  const formasPago = [efectivo]  
  const cosas = []
  const cuotas = []
  var formaPreferida

  var property salario
  var montoParaPagarCuotas

// compras
  method modificarForma(){
    formaPreferida = formasPago.anyOne()
  }

  method comprar(cosa){
    if(self.puedeComprar(cosa)){
      self.pagar(cosa)
      cosas.add(cosa)
    }
  }

  method puedeComprar(cosa) = formaPreferida.puedePagar(cosa)

  method pagar(cosa){
    formaPreferida.pagar(cosa,self)
  }

  method agregarCuota(cuota){
    cuotas.add(cuota)
  }

// sueldo

  method cobrarSalario(){
    montoParaPagarCuotas = salario
    self.pagarCuotas() 
    efectivo.aumentar(montoParaPagarCuotas)
  }

  method pagarCuotas(){
    self.cuotasVencidas().forEach({cuota => self.pagarCuota(cuota)})
  }

  method cuotasVencidas() = cuotas.filter({cuota => cuota.estaVencida()})

  method pagarCuota(cuota){
    if (montoParaPagarCuotas > cuota.importe() ){
      montoParaPagarCuotas -= cuota.importe()
      cuota.pagar()
    }
  }

  method totalDeuda() = self.cuotasVencidas().sum{cuota => cuota.importe()}
  
  method cantidadCosas() = cosas.size()
}

class Cosa{
  var property precio
  method precioFinanciado() = precio * (1 + bancoCentral.tasaInteres())
}

class FormaPago {
  method puedePagar(cosa) = cosa.precio() <= self.disponible()
  method disponible()
}
class PagoInmediato inherits FormaPago{ // Para debito y efectivo
  var property disponible = 0

  method aumentar(importe) {
    disponible = disponible + importe
  }
  
  method pagar(cosa,persona){
    self.aumentar( -cosa.precio() )
  }
}

class PagoCredito inherits FormaPago {
  const banco
  var cantidadCuotas

  override method disponible() = banco.maximoPermitido()

  method pagar(cosa,persona){
    cantidadCuotas.times{ numero => 
      persona.agregarCuota(
        new Cuota(mes = calendario.mes() + numero, importe = cosa.precioFinanciado())
      )
    }
  } 
}

class Cuota{
  const mes 
  const property importe
  var property pagada = false

  method pagar(){
    pagada = true
  }

  method vencida() = mes <= calendario.mes() && not pagada
}


object bancoCentral{
  var property tasaInteres = 0.1
}

class Banco {
  var property montoMaximo
}

// Segunda parte

class CompradorCompulsivo inherits Persona{
  override method puedeComprar(cosa) = formasPago.any({formaPago => formaPago.puedePagar(cosa)})

  override method pagar(cosa){
    formasPago.find{formaPago => formaPago.puedePagar(cosa)}.pagar(cosa,self)
  }
}

class PagadorCompulsivo inherits Persona{
  override method pagarCuotas(){
    super()
    montoParaPagarCuotas += efectivo.disponible()
    efectivo.disponible(0)
    super()
   }
}
