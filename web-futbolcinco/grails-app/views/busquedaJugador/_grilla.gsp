<!--  CHUSMEAR EL JS!!!!!!!!!!! -->
		<div class="col-md-12">
			<table class="table table-striped table-bordered table-hover table-condensed">
				<thead>
					<g:sortableColumn title="Nombre" property="nombre"/>
					<g:sortableColumn title="Edad" property="edad"/>
					<g:sortableColumn title ="Handicap" property="handicap"/>
				</thead>
				<tbody>
					<g:each in="${socios}" var="socio">
						<tr class="info">
							<td class="col-md-2">
								<g:link controller="busquedaJugador" action="datosJugador" id="${socio.id}" >${socio.nombre}</g:link>
							</td>
							<td class="col-md-2">
								${socio.edad }
							</td>
							<td class="col-md-2">
							${socio.handicap }
							</td>
						</tr>
					</g:each>
				</tbody>
			</table>
		</div>