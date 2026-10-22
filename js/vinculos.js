// =====================================================================
//  Alta vinculada ("crear y editar" estilo Odoo): cuando un dato capturado en una pantalla depende de un
//  catálogo y no existe, se abre la MISMA pantalla de alta del catálogo (una sola plantilla, una sola base)
//  como subventana encima de la pantalla de origen, que no se pierde ni se re-dibuja. Al guardar, la
//  subventana se cierra y se devuelve el registro creado a quien la pidió.
//
//  Cómo funciona: la <section> real del catálogo (#view-alta-articulo, #view-proveedores…) se MUDA al panel
//  de la subventana mientras está abierta y se regresa a su lugar al cerrar; así no hay un segundo formulario
//  que mantener. El módulo del catálogo avisa al guardar con `avisarRegistroGuardado(entidad, id)`.
//  Para sumar un catálogo: una línea en ENTIDADES + llamar a avisarRegistroGuardado en su guardado.
// =====================================================================
const ENTIDADES = {
    producto: { vista: 'alta-articulo', titulo: 'Alta de artículo', campoNombre: 'prodNombre', nuevo: 'btnNuevoModo' },
    cliente: { vista: 'clientes', titulo: 'Clientes', campoNombre: 'cliNombre', nuevo: 'cliNuevo',
        cargar: async () => { const m = await import('./clientes.js'); await m.cargarModuloClientes('clientes'); } },
    proveedor: { vista: 'proveedores', titulo: 'Proveedores', campoNombre: 'provNombre', nuevo: 'btnLimpiarProveedor' },
};

let abierta = null;   // { entidad, cerrar, onGuardado } — una sola alta vinculada a la vez por catálogo

export function avisarRegistroGuardado(entidad, id) {
    window.dispatchEvent(new CustomEvent('registro-guardado', { detail: { entidad, id } }));
}

window.addEventListener('registro-guardado', (e) => {
    if (!abierta || abierta.entidad !== e.detail.entidad) return;
    const { onGuardado } = abierta;
    abierta.cerrar();
    try { onGuardado?.({ id: e.detail.id }); } catch (err) { console.error('onGuardado (alta vinculada):', err); }
});

export function abrirAltaVinculada(entidad, { nombre = '', onGuardado } = {}) {
    const cfg = ENTIDADES[entidad];
    const seccion = cfg && document.getElementById(`view-${cfg.vista}`);
    if (!cfg || !seccion) { alert('No se encontró la pantalla de alta de este catálogo.'); return; }
    if (abierta) { alert('Ya hay una alta abierta; termínala o ciérrala primero.'); return; }

    // La sección vuelve a su lugar exacto al cerrar (marcador en el DOM).
    const marcador = document.createComment('alta-vinculada');
    seccion.parentNode.insertBefore(marcador, seccion);
    const estabaOculta = seccion.classList.contains('hidden');

    const id = window.idSubventana ? window.idSubventana(`altaVinculada_${entidad}`) : `altaVinculada_${entidad}`;
    const ov = document.createElement('div');
    ov.id = id;
    ov.className = 'fixed inset-0 bg-slate-950/40 flex items-start justify-center p-3 overflow-y-auto';
    ov.style.zIndex = typeof window.zSubventanaSiguiente === 'function' ? window.zSubventanaSiguiente() : 90;
    ov.innerHTML = `
      <div class="w-full max-w-6xl my-2 bg-slate-950 border border-slate-800 rounded-xl p-4 shadow-2xl">
        <div class="flex items-center justify-between gap-3 mb-3">
          <h3 class="text-base font-semibold text-sky-300">➕ ${cfg.titulo} <span class="text-[11px] font-normal text-slate-500">— al guardar regresas a lo que estabas capturando</span></h3>
          <button type="button" data-x class="text-slate-400 hover:text-slate-100 text-xl leading-none" title="Cerrar">&times;</button>
        </div>
        <div data-cuerpo></div>
      </div>`;
    document.body.appendChild(ov);
    ov.querySelector('[data-cuerpo]').appendChild(seccion);
    seccion.classList.remove('hidden');

    const cerrar = () => {
        abierta = null;
        marcador.parentNode?.insertBefore(seccion, marcador);
        marcador.remove();
        seccion.classList.toggle('hidden', estabaOculta);
        ov.remove();
    };
    ov.querySelector('[data-x]').onclick = cerrar;
    abierta = { entidad, cerrar, onGuardado };

    // Modo "nuevo" con el nombre ya escrito (si el módulo aún no terminó de montarse, reintenta un momento).
    let intentos = 0;
    let cargando = false;
    const preparar = async () => {
        let campo = document.getElementById(cfg.campoNombre);
        if (!campo && cfg.cargar && !cargando) {   // catálogo que se arma al abrir su pantalla (ej. Clientes)
            cargando = true;
            try { await cfg.cargar(); } catch (e) { console.warn('alta vinculada (cargar):', e); }
            campo = document.getElementById(cfg.campoNombre);
        }
        if (!campo) { if (intentos++ < 20) setTimeout(preparar, 150); return; }
        document.getElementById(cfg.nuevo)?.click();
        campo.value = nombre;
        campo.focus();
    };
    preparar();
}
