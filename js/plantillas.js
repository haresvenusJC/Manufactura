import { supabaseClient } from './supabase.js';
import { invalidarCachePlantillas, imprimirConPlantilla } from './impresion.js';

const BUCKET_LOGOS = 'logos-plantillas';

export async function cargarModuloPlantillas() {
    const contenedor = document.getElementById('view-plantillas');
    if (!contenedor) return;

    contenedor.innerHTML = `
        <div class="space-y-6 max-w-3xl mx-auto">

            <!-- Lista de plantillas ya configuradas -->
            <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <h2 class="text-xl font-bold text-slate-100 mb-1">🖨️ Plantillas de Documentos Imprimibles</h2>
                <p class="text-xs text-slate-400 mb-4">Configura el encabezado, logo, colores y pie de página que se usan al imprimir cada tipo de documento.</p>
                <h3 class="text-xs font-bold uppercase tracking-wider text-slate-400 mb-2">Plantillas ya configuradas</h3>
                <div id="listaPlantillasExistentes" class="grid grid-cols-1 sm:grid-cols-2 gap-3 mb-2">
                    <p class="text-slate-500 text-xs italic">Cargando...</p>
                </div>
            </div>

            <!-- Formulario de edición -->
            <div class="bg-slate-900 border border-slate-800 p-6 rounded-2xl shadow-xl">
                <label class="block text-xs font-medium text-slate-400 mb-1">TIPO DE DOCUMENTO A EDITAR</label>
                <select id="selectTipoPlantilla" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 mb-6">
                    <option value="">Cargando tipos...</option>
                </select>

                <form id="formPlantilla" class="space-y-4">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">NOMBRE DE LA PLANTILLA</label>
                        <input type="text" id="pNombre" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>

                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">LOGO</label>
                        <div class="flex items-center gap-4">
                            <div id="previewLogoWrap" class="w-20 h-20 rounded-lg bg-slate-950 border border-slate-800 flex items-center justify-center overflow-hidden shrink-0">
                                <img id="previewLogo" src="" class="max-w-full max-h-full hidden">
                                <span id="previewLogoVacio" class="text-slate-600 text-[10px] text-center px-1">Sin logo</span>
                            </div>
                            <div class="flex-1 space-y-2">
                                <input type="file" id="pLogoFile" accept="image/*" class="w-full text-xs text-slate-300 file:mr-3 file:py-1.5 file:px-3 file:rounded-lg file:border-0 file:text-xs file:font-semibold file:bg-slate-800 file:text-slate-200 hover:file:bg-slate-700">
                                <div class="flex items-center gap-2">
                                    <span id="estadoSubidaLogo" class="text-[11px] text-slate-500"></span>
                                    <button type="button" id="btnQuitarLogo" class="text-[11px] text-rose-400 hover:text-rose-300 hidden">Quitar logo</button>
                                </div>
                            </div>
                        </div>
                        <input type="hidden" id="pLogo" value="">
                    </div>

                    <div class="grid grid-cols-2 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">TÍTULO DEL ENCABEZADO</label>
                            <input type="text" id="pTitulo" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-slate-400 mb-1">COLOR DE ACENTO</label>
                            <input type="color" id="pColor" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-1 h-10">
                        </div>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">SUBTÍTULO DEL ENCABEZADO</label>
                        <input type="text" id="pSubtitulo" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>
                    <div class="grid grid-cols-2 gap-4">
                        <label class="flex items-center gap-2 text-sm text-slate-300">
                            <input type="checkbox" id="pMostrarCostos" class="rounded"> Mostrar costos en el documento
                        </label>
                        <label class="flex items-center gap-2 text-sm text-slate-300">
                            <input type="checkbox" id="pMostrarLote" class="rounded"> Mostrar número de lote
                        </label>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">NOTAS LEGALES (pie de página)</label>
                        <textarea id="pNotasLegales" rows="2" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></textarea>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">TEXTO ADICIONAL DE PIE DE PÁGINA</label>
                        <input type="text" id="pTextoPie" class="w-full bg-slate-950 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                    </div>

                    <div class="flex items-center gap-3 pt-2">
                        <button type="submit" class="bg-emerald-600 hover:bg-emerald-500 text-white font-semibold py-2 px-4 rounded-lg text-sm shadow-lg">
                            💾 Guardar Plantilla
                        </button>
                        <button type="button" id="btnPreviewPlantilla" class="bg-slate-800 hover:bg-slate-700 text-slate-200 py-2 px-4 rounded-lg text-sm border border-slate-700">
                            👁️ Vista Previa
                        </button>
                    </div>
                </form>
            </div>

            <!-- Área oculta usada solo para generar la vista previa impresa -->
            <div id="areaPreviewPlantilla" style="display:none;">
                <table style="width:100%; border-collapse:collapse; font-size:12px;">
                    <thead><tr><th style="text-align:left; padding:6px; border-bottom:1px solid #ccc;">Concepto</th><th style="text-align:right; padding:6px; border-bottom:1px solid #ccc;">Cantidad</th></tr></thead>
                    <tbody>
                        <tr><td style="padding:6px;">Producto de ejemplo A</td><td style="padding:6px; text-align:right;">10</td></tr>
                        <tr><td style="padding:6px;">Producto de ejemplo B</td><td style="padding:6px; text-align:right;">5</td></tr>
                    </tbody>
                </table>
            </div>
        </div>
    `;

    let plantillasPorTipo = {};
    let nombresPorTipo = {};
    let tipoActual = '';

    async function cargarTipos() {
        const select = document.getElementById('selectTipoPlantilla');
        const { data: tipos, error } = await supabaseClient
            .from('tipos_movimiento')
            .select('codigo, nombre')
            .order('nombre', { ascending: true });

        nombresPorTipo = { generico: 'Plantilla General (respaldo)' };
        let opciones = '<option value="generico">Plantilla General (respaldo para todos)</option>';
        if (!error && tipos) {
            tipos.forEach(t => {
                nombresPorTipo[t.codigo] = t.nombre;
                opciones += `<option value="${t.codigo}">${t.nombre}</option>`;
            });
        }
        select.innerHTML = opciones;
    }

    async function cargarPlantillasExistentes() {
        const { data, error } = await supabaseClient
            .from('plantillas_documentos')
            .select('*')
            .order('updated_at', { ascending: false });

        plantillasPorTipo = {};
        if (!error && data) {
            data.forEach(p => { plantillasPorTipo[p.tipo_documento] = p; });
        }
        renderizarListaExistentes(data || []);
    }

    function renderizarListaExistentes(lista) {
        const cont = document.getElementById('listaPlantillasExistentes');
        if (!lista.length) {
            cont.innerHTML = `<p class="text-slate-500 text-xs italic col-span-2">Todavía no has configurado ninguna plantilla. Elige un tipo abajo y guarda tu primera.</p>`;
            return;
        }
        cont.innerHTML = lista.map(p => `
            <button type="button" class="btn-editar-plantilla text-left bg-slate-950 border border-slate-800 hover:border-slate-600 rounded-xl p-3 flex items-center gap-3 transition" data-tipo="${p.tipo_documento}">
                <div class="w-10 h-10 rounded-lg bg-slate-900 border border-slate-800 flex items-center justify-center overflow-hidden shrink-0">
                    ${p.logo_url ? `<img src="${p.logo_url}" class="max-w-full max-h-full">` : `<span class="w-3 h-3 rounded-full" style="background:${p.color_acento || '#4f46e5'}"></span>`}
                </div>
                <div class="min-w-0">
                    <p class="text-sm font-semibold text-slate-200 truncate">${p.nombre_plantilla || p.tipo_documento}</p>
                    <p class="text-[11px] text-slate-500 truncate">${nombresPorTipo[p.tipo_documento] || p.tipo_documento}</p>
                </div>
            </button>
        `).join('');

        cont.querySelectorAll('.btn-editar-plantilla').forEach(btn => {
            btn.onclick = () => {
                const tipo = btn.dataset.tipo;
                document.getElementById('selectTipoPlantilla').value = tipo;
                tipoActual = tipo;
                rellenarFormulario(tipo);
                document.getElementById('formPlantilla').scrollIntoView({ behavior: 'smooth', block: 'start' });
            };
        });
    }

    function actualizarPreviewLogo(url) {
        const img = document.getElementById('previewLogo');
        const vacio = document.getElementById('previewLogoVacio');
        const btnQuitar = document.getElementById('btnQuitarLogo');
        if (url) {
            img.src = url;
            img.classList.remove('hidden');
            vacio.classList.add('hidden');
            btnQuitar.classList.remove('hidden');
        } else {
            img.src = '';
            img.classList.add('hidden');
            vacio.classList.remove('hidden');
            btnQuitar.classList.add('hidden');
        }
        document.getElementById('pLogo').value = url || '';
    }

    function rellenarFormulario(tipo) {
        const p = plantillasPorTipo[tipo] || {
            nombre_plantilla: `Plantilla ${nombresPorTipo[tipo] || tipo}`,
            logo_url: '',
            titulo_encabezado: 'Hares de México',
            subtitulo_encabezado: 'Comprobante de Movimiento de Almacén',
            color_acento: '#4f46e5',
            mostrar_costos: true,
            mostrar_lote: true,
            notas_legales: '',
            texto_pie: ''
        };
        document.getElementById('pNombre').value = p.nombre_plantilla || '';
        document.getElementById('pTitulo').value = p.titulo_encabezado || '';
        document.getElementById('pSubtitulo').value = p.subtitulo_encabezado || '';
        document.getElementById('pColor').value = p.color_acento || '#4f46e5';
        document.getElementById('pMostrarCostos').checked = !!p.mostrar_costos;
        document.getElementById('pMostrarLote').checked = !!p.mostrar_lote;
        document.getElementById('pNotasLegales').value = p.notas_legales || '';
        document.getElementById('pTextoPie').value = p.texto_pie || '';
        document.getElementById('pLogoFile').value = '';
        document.getElementById('estadoSubidaLogo').textContent = '';
        actualizarPreviewLogo(p.logo_url || '');
    }

    await cargarTipos();
    await cargarPlantillasExistentes();
    tipoActual = document.getElementById('selectTipoPlantilla').value || 'generico';
    rellenarFormulario(tipoActual);

    document.getElementById('selectTipoPlantilla').onchange = (e) => {
        tipoActual = e.target.value;
        rellenarFormulario(tipoActual);
    };

    document.getElementById('btnQuitarLogo').onclick = () => {
        actualizarPreviewLogo('');
    };

    // Subida del logo a Supabase Storage al elegir el archivo
    document.getElementById('pLogoFile').onchange = async (e) => {
        const archivo = e.target.files?.[0];
        if (!archivo) return;

        const estado = document.getElementById('estadoSubidaLogo');
        estado.textContent = '⏳ Subiendo...';

        const extension = archivo.name.split('.').pop();
        const rutaArchivo = `${tipoActual}-${Date.now()}.${extension}`;

        const { error: errSubida } = await supabaseClient
            .storage
            .from(BUCKET_LOGOS)
            .upload(rutaArchivo, archivo, { upsert: true, cacheControl: '3600' });

        if (errSubida) {
            estado.textContent = '❌ Error al subir: ' + errSubida.message;
            return;
        }

        const { data: urlData } = supabaseClient
            .storage
            .from(BUCKET_LOGOS)
            .getPublicUrl(rutaArchivo);

        actualizarPreviewLogo(urlData.publicUrl);
        estado.textContent = '✅ Logo subido. No olvides guardar la plantilla.';
    };

    document.getElementById('formPlantilla').onsubmit = async (e) => {
        e.preventDefault();
        const registro = {
            tipo_documento: tipoActual,
            nombre_plantilla: document.getElementById('pNombre').value.trim() || `Plantilla ${tipoActual}`,
            logo_url: document.getElementById('pLogo').value.trim() || null,
            titulo_encabezado: document.getElementById('pTitulo').value.trim() || 'Hares de México',
            subtitulo_encabezado: document.getElementById('pSubtitulo').value.trim() || '',
            color_acento: document.getElementById('pColor').value || '#4f46e5',
            mostrar_costos: document.getElementById('pMostrarCostos').checked,
            mostrar_lote: document.getElementById('pMostrarLote').checked,
            notas_legales: document.getElementById('pNotasLegales').value.trim() || null,
            texto_pie: document.getElementById('pTextoPie').value.trim() || null,
            updated_at: new Date().toISOString()
        };

        const { error } = await supabaseClient
            .from('plantillas_documentos')
            .upsert([registro], { onConflict: 'tipo_documento' });

        if (error) {
            alert('❌ Error al guardar la plantilla: ' + error.message);
            return;
        }

        invalidarCachePlantillas();
        await cargarPlantillasExistentes();
        alert('✅ Plantilla guardada correctamente.');
    };

    document.getElementById('btnPreviewPlantilla').onclick = async () => {
        await imprimirConPlantilla(tipoActual, `Vista Previa — ${document.getElementById('pNombre').value || tipoActual}`, 'areaPreviewPlantilla');
    };
}
