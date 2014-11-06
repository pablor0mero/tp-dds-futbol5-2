package futbolcinco

import java.util.LinkedList
import java.util.Set
import java.util.HashSet
import Exceptions.PartidoCompletoException
import futbolcinco.JugadorPropuesto

import Exceptions.NoInscriptoExceptionimport Exceptions.CalificacionRepetidaException
import Exceptions.CalificadorNoJugoEnElPartidoException
import Exceptions.CalificadoNoJugoEnElPartidoException
import Exceptions.NoSePuedeCalificarASiMismoException
import Exceptions.PartidoNoJugadoException
import Exceptions.PuntuacionIncorrectaException
import Exceptions.PartidoCerradoException
import futbolcinco.homes.PartidosDelSistema
import javax.persistence.Entity
import javax.persistence.Table
import javax.persistence.GeneratedValue
import javax.persistence.Id
import javax.persistence.Column
import javax.persistence.OneToMany
import javax.persistence.CascadeType
import javax.persistence.FetchType
import javax.persistence.ManyToMany

@Entity
@Table (name="Socios") 
class Socio {
	@Id
	@GeneratedValue
	@Property Long id
	
	@Column
	@Property String nombre
	
	@Column
	@Property Integer edad
	
	@Column
	@Property String casilla
	
	@OneToMany(fetch = FetchType.LAZY, cascade=CascadeType.ALL) //meterlo al getter no funcionan los @Property en collections
	@Property Set<Partido> inscripciones
	
	//No va a funcar supositoriamente
	@ManyToMany(fetch = FetchType.LAZY) //Chusmear: http://stackoverflow.com/questions/1656113/hibernate-many-to-many-association-with-the-same-entity
	@Property Set<Socio> amigos
	
	@OneToMany(fetch = FetchType.LAZY)
	@Property LinkedList<Infraccion> infracciones
	
	//////////////////////////////////////////////////////////////////////////
	/*
	 * 	Estaria bueno que alguno me diga como piensan mapear esta negrada
	 */
	@Property LinkedList<Calificacion> misCalificaciones
		
	@Property HashSet<Calificacion> calificacionesHechas
	
	//////////////////////////////////////////////////////////////////////////
	
	@Column
	@Property Integer handicap
	
	// Ya existia la lista de partidos!! El que lo hizo que lo cambie pls, borren y donde se use cambienla por partidos
	@Property LinkedList<Partido> misPartidos
	
	
	//what
	@Property PartidosDelSistema homePartidos //NO ESTOY SEGURO DE ESTO, CONSULTAR. PUEDE TENER ADMIN O OTRA COSA
	
	
	// Hibernate necesita un constructor vacio
	new() {
		
	}
	new (String nombre,Integer anios,String mail,Administrador admin){
		this.nombre = nombre
		this.edad = anios
		this.casilla = mail
		this.inscripciones = new HashSet<Partido>
		this.amigos = new HashSet<Socio>
		this.infracciones = new LinkedList<Infraccion>	
		this.misPartidos = new LinkedList<Partido>
		this.misCalificaciones = new LinkedList<Calificacion>
		this.calificacionesHechas = new HashSet<Calificacion>
		this.handicap = 5
		this.homePartidos = admin.homePartidos
	}
	
	/*new(JugadorPropuesto jugador){
		new Socio(jugador.nombre,jugador.edad,jugador.casilla,)
	}*/
	
//////////////ModificacionesEnPartidos//////////////////
	def void inscribirseA(Partido partido,ModoInscripcion modoInscripcion, (Partido)=>boolean condicion) {
		if(partido.todosEstandares()) {
			throw new PartidoCompletoException
		}
		if(!homePartidos.partidosArmandose.contiene(partido)){
			throw new PartidoCerradoException
		}
		
			modoInscripcion.inscribirA(this, partido, condicion)
			inscripciones.add(partido)
		
	}
	
	def void inscribirseA(Partido partido,ModoInscripcion modoInscripcion){
		this.inscribirseA(partido,modoInscripcion,null)
	}
	
	
	def void desinscribirseA(Partido partido){
		if(!partido.getInscriptos.exists[ficha | ficha.inscripto==this ]){
			throw new NoInscriptoException 
		}
		if(!homePartidos.partidosArmandose.contiene(partido)){
			throw new PartidoCerradoException
		}
		partido.desinscribirA(this)	
	}
	
	
	def void remplazameEn(Partido partido,Socio remplazo,ModoInscripcion modoInscripcion, (Partido)=>boolean condicion ){
		if(!partido.getInscriptos.exists[ficha | ficha.inscripto==this ]){
			throw new NoInscriptoException 
			}
		if(!homePartidos.partidosArmandose.contiene(partido)){
			throw new PartidoCerradoException
		}
		var ficha = new FichaInscripcion(remplazo,modoInscripcion,null)
		partido.remplazame(this,ficha)
	}
	
	def void remplazameEn(Partido partido,Socio remplazo,ModoInscripcion modoInscripcion){
		this.remplazameEn(partido,remplazo,modoInscripcion,null)
	}
	
	
	//////////Infraccion//////////////
	def aplicarInfraccion(Integer desde, Integer hasta,String motivo) {
		this.infracciones.add(new Infraccion(desde,hasta,motivo))
	}
	
	/////////AñadirGente//////////////
	def void proponerAmigo(String nombre,Integer anios,String mail, Administrador admin){
		var amigo = new JugadorPropuesto(nombre,anios,mail)
		admin.homeJugadoresPropuestos.agregar(amigo)
	}
	
	
	////////////////////calificaciones/////////////////	
	def void calificar(Partido partido, Socio socio, Integer nota, String opinion){
		
		if(!homePartidos.partidosJugados.contiene(partido)){
			throw new PartidoNoJugadoException
		}else{
		if(this == socio){
			throw new NoSePuedeCalificarASiMismoException
		}else{
		if(!partido.inscriptos.exists(ficha | ficha.inscripto == socio)){
			throw new CalificadoNoJugoEnElPartidoException
		}else{
		if(!partido.inscriptos.exists(ficha | ficha.inscripto == this)){
			throw new CalificadorNoJugoEnElPartidoException
		}else{
		if(this.calificacionesHechas.exists(cal | cal.calificado == socio)){
			throw new CalificacionRepetidaException
		}else{
		if(nota<1 || nota>10){
			throw new PuntuacionIncorrectaException	
		}else{
			socio.agregarAMisCalificaciones(partido,this,socio,nota,opinion) 
			this.agregarACalificacionesHechas(partido,this,socio,nota,opinion)
			partido.agregarCalificacion(partido,socio,this,nota,opinion)
			}
	}}}}}
}
	
	def void agregarAMisCalificaciones(Partido partido, Socio unSocio, Socio otroSocio, Integer nota, String opinion) {
		otroSocio.misCalificaciones.add(new Calificacion(partido,unSocio,otroSocio,nota,opinion))
	}
	
	
	def void agregarACalificacionesHechas(Partido partido, Socio unSocio, Socio otroSocio, Integer nota, String opinion) {
		unSocio.calificacionesHechas.add(new Calificacion(partido,unSocio,otroSocio,nota,opinion))
	}



//////////////ObtenerPromedios

	def getPromedio(){
		 var a = 0.0
		 if(misCalificaciones.isEmpty())
		 	return 0.0
		 for(Calificacion calificacion : misCalificaciones)	 {
		 	a += calificacion.puntaje
		 }
		 return a/misCalificaciones.size()
	}
}