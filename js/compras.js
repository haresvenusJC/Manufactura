import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

let catalogoProveedoresCache = [];
let catalogoUnidadesCache = [];
let listaPartidasCompra = [];
let catalogoProductosCache = []; // Caché local para la búsqueda AJAX de insumos
let ivaFiscalEditadoManualmente = false; // true si el usuario escribió el IVA a mano (no seguir el 16% automático)

export async function configurarFormularioCompras() {
    const formCompra = document.getElementById('formCompra');
    if (!formCompra) return;

    if (!document.getElementById('contenedorPartidasCompra')) {
        formCompra.innerHTML = `
            <!-- BLOQUE 1: Insumos o Productos a Comprar -->
            <div class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800 shadow-xl">
                <h3 class="text-md font-semibold text-slate-200 mb-3">1. Insumos o Productos a Comprar</h3>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-3 mb-3">
                    <div class="relative">
                        <label class="block text-xs font-medium text-slate-400 mb-1">Nombre del Insumo / Producto</label>
                        <input type="text" id="compraInsumoNombre" autocomplete="off" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 focus:outline-none focus:border-emerald-500" placeholder="Escribe para buscar insumo...">
                        
                        <!-- Contenedor desplegable AJAX -->
                        <div id="sugerenciasInsumosCompra" class="hidden absolute left-0 right-0 mt-1 bg-slate-900 border border-slate-700 rounded-lg shadow-2xl z-50 max-h-48 overflow-y-auto"></div>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Unidad de Medida</label>
                        <select id="compraUnidadMedida" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">Seleccione unidad...</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Cantidad</label>
                        <input type="number" step="any" id="compraCantidad" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="0.00">
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Costo Unitario</label>
                        <input type="number" step="any" id="compraCostUnitario" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="0.00">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Número de Lote</label>
                        <input type="text" id="compraLote" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" placeholder="Ej. LOTE-COMPRA">
                    </div>
                </div>
            </div>

            <!-- BLOQUE 2: Datos Generales de la Compra -->
            <div class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800 shadow-xl">
                <h3 class="text-md font-semibold text-slate-200 mb-3">2. Datos Generales de la Compra</h3>
                <div class="grid grid-cols-1 md:grid-cols-4 gap-4">
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Fecha de Compra</label>
                        <input type="date" id="compraFecha" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" required>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Factura / Folio</label>
                        <input type="text" id="compraFactura" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono" placeholder="Ej. FAC-001">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Proveedor</label>
                        <select id="compraProveedorId" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="">Seleccione proveedor...</option>
                        </select>
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Moneda</label>
                        <select id="compraMoneda" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                            <option value="MXN">MXN</option>
                            <option value="USD">USD</option>
                        </select>
                    </div>
                </div>
                <div class="grid grid-cols-1 md:grid-cols-2 gap-4 mt-3 mb-4">
                    <div id="contenedorTipoCambio" style="display: none;">
                        <label class="block text-xs font-medium text-slate-400 mb-1">Tipo de Cambio (USD)</label>
                        <input type="number" step="any" id="compraTipoCambio" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="1.00" value="1.0">
                    </div>
                    <div>
                        <label class="block text-xs font-medium text-slate-400 mb-1">Notas</label>
                        <textarea id="compraNotas" rows="1" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100" placeholder="Detalles de la compra..."></textarea>
                    </div>
                </div>
                <!-- Botón de Agregar Partida al final del Bloque 2 -->
                <div class="flex justify-end pt-3 border-t border-slate-900">
                    <button type="button" id="btnAgregarPartidaCompra" class="bg-emerald-600 hover:bg-emerald-500 text-white font-medium px-5 py-2.5 rounded-lg text-xs transition shadow-md flex items-center gap-1.5" style="cursor: pointer;">
                        <span class="text-sm font-bold">＋</span> Agregar Partida
                    </button>
                </div>
            </div>

            <!-- BLOQUE 3: Partidas en esta Compra -->
            <div id="contenedorPartidasCompra" class="mb-4 space-y-2">
                <h3 class="text-md font-semibold text-slate-200 mb-2">3. Partidas en esta Compra</h3>
                <div class="overflow-x-auto border border-slate-800 rounded-xl">
                    <table class="w-full text-left text-sm text-slate-300 bg-slate-950">
                        <thead class="bg-slate-900 text-xs uppercase text-emerald-400 border-b border-slate-800">
                            <tr>
                                <th class="p-3">Insumo</th>
                                <th class="p-3">Cantidad</th>
                                <th class="p-3">Unidad</th>
                                <th class="p-3">Costo U.</th>
                                <th class="p-3">Lote</th>
                                <th class="p-3 text-center">Acción</th>
                            </tr>
                        </thead>
                        <tbody id="tablaPartidasCompraBody">
                            <tr><td colspan="6" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- BLOQUE 4: Datos fiscales / contabilidad -->
            <div id="bloqueFiscalCompra" class="bg-slate-950 p-4 rounded-xl mb-4 border border-slate-800 shadow-xl hidden">
                <label class="flex items-center gap-2 text-sm font-semibold text-slate-200 mb-3">
                    <input type="checkbox" id="compraContabilizar" checked class="accent-emerald-500"> 4. Generar póliza contable
                </label>
                <div id="camposFiscalesCompra" class="space-y-3">
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-3">
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Subtotal <button type="button" id="compraSubtotalAuto" class="text-[10px] text-emerald-400 hover:underline">auto</button></label>
                            <input type="number" step="0.01" min="0" id="compraSubtotal" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">IVA <button type="button" id="compraIva16" class="text-[10px] text-emerald-400 hover:underline">16%</button></label>
                            <input type="number" step="0.01" min="0" id="compraIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">IEPS</label>
                            <input type="number" step="0.01" min="0" id="compraIeps" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Total</label>
                            <input type="text" id="compraTotalFiscal" readonly value="$0.00" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-emerald-400 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Ret. IVA</label>
                            <input type="number" step="0.01" min="0" id="compraRetIva" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Ret. ISR</label>
                            <input type="number" step="0.01" min="0" id="compraRetIsr" value="0" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 text-right font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Condición</label>
                            <select id="compraCondicion" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                <option value="credito">Crédito (por pagar)</option>
                                <option value="contado">Contado</option>
                            </select>
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">Forma de pago</label>
                            <select id="compraFormaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100">
                                <option value="">—</option><option>efectivo</option><option>transferencia</option><option>tarjeta</option><option>cheque</option>
                            </select>
                        </div>
                    </div>
                    <div id="compraPagoWrap" class="hidden">
                        <label class="block text-xs text-slate-400 mb-1">Pagado desde (caja / banco)</label>
                        <select id="compraCuentaPago" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100"></select>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-2 gap-3">
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">UUID CFDI</label>
                            <input type="text" id="compraUuid" placeholder="folio fiscal" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-xs text-slate-100 font-mono">
                        </div>
                        <div>
                            <label class="block text-xs text-slate-400 mb-1">RFC emisor</label>
                            <input type="text" id="compraRfc" class="w-full bg-slate-900 border border-slate-800 rounded-lg p-2 text-sm text-slate-100 font-mono">
                        </div>
                    </div>
                </div>
            </div>

            <button type="submit" class="w-full bg-emerald-600 hover:bg-emerald-500 text-white font-medium p-3 rounded-lg transition shadow-md text-sm" style="cursor: pointer;">
                Registrar Compra
            </button>
        `;
    }

    const inputFecha = document.getElementById('compraFecha');
    if (inputFecha) {
        inputFecha.value = new Date().toISOString().split('T')[0];
    }

    await cargarProveedoresSelect();
    await cargarUnidadesMedidaSelect();
    await precargarProductosParaBusqueda();
    await cargarBloqueFiscalCompra();

    const monedaSelect = document.getElementById('compraMoneda');
    if (monedaSelect) {
        monedaSelect.addEventListener('change', toggleTipoCambio);
    }

    const inputInsumo = document.getElementById('compraInsumoNombre');
    const contenedorSugerencias = document.getElementById('sugerenciasInsumosCompra');

    if (inputInsumo && contenedorSugerencias) {
        inputInsumo.addEventListener('input', function() {
            const texto = this.value.toLowerCase().trim();
            if (texto.length === 0) {
                contenedorSugerencias.classList.add('hidden');
                return;
            }

            const filtrados = catalogoProductosCache.filter(p => p.nombre.toLowerCase().includes(texto));

            if (filtrados.length > 0) {
                contenedorSugerencias.innerHTML = filtrados.map(prod => `
                    <div class="px-3 py-2 text-sm text-slate-200 hover:bg-emerald-600 hover:text-white cursor-pointer transition border-b border-slate-800/50 last:border-none"
                         onclick="window.seleccionarInsumoAutocomplete('${encodeURIComponent(JSON.stringify(prod))}')">
                        <span class="font-medium">${prod.nombre}</span>
                        <span class="text-xs text-slate-400 block">Costo: $${prod.costo_unitario || 0} ${prod.unidades_medida ? `| Unid: ${prod.unidades_medida.nombre}` : ''}</span>
                    </div>
                `).join('');
                contenedorSugerencias.classList.remove('hidden');
            } else {
                contenedorSugerencias.innerHTML = `<div class="px-3 py-2 text-xs text-slate-500">No se encontraron insumos coincidentes. Se registrará como nuevo.</div>`;
                contenedorSugerencias.classList.remove('hidden');
            }
        });

        document.addEventListener('click', function(e) {
            if (!inputInsumo.contains(e.target) && !contenedorSugerencias.contains(e.target)) {
                contenedorSugerencias.classList.add('hidden');
            }
        });
    }

    const oldBtn = document.getElementById('btnAgregarPartidaCompra');
    if (oldBtn) {
        const btnAgregar = oldBtn.cloneNode(true);
        oldBtn.parentNode.replaceChild(btnAgregar, oldBtn);

        btnAgregar.addEventListener('click', (e) => {
            e.preventDefault();
            agregarPartidaTemporal();
        });
    }

    formCompra.onsubmit = async (e) => {
        e.preventDefault();

        const fecha = document.getElementById('compraFecha')?.value || new Date().toISOString().split('T')[0];
        const folio = document.getElementById('compraFactura')?.value.trim() || '';
        const proveedorId = document.getElementById('compraProveedorId')?.value ? parseInt(document.getElementById('compraProveedorId').value) : null;
        const monedaCodigo = document.getElementById('compraMoneda')?.value || 'MXN';
        const tipoCambio = (monedaCodigo === 'USD') ? (parseFloat(document.getElementById('compraTipoCambio')?.value) || 1.0) : 1.0;
        const notas = document.getElementById('compraNotas')?.value.trim() || '';

        let partidasAProcesar = [...listaPartidasCompra];
        
        if (partidasAProcesar.length === 0) {
            const nombreInsumo = document.getElementById('compraInsumoNombre')?.value.trim() || '';
            const cantidad = parseFloat(document.getElementById('compraCantidad')?.value) || 0;
            let costoUnitario = parseFloat(document.getElementById('compraCostUnitario')?.value) || 0;
            const unidadMedidaId = document.getElementById('compraUnidadMedida')?.value ? parseInt(document.getElementById('compraUnidadMedida').value) : null;
            const numeroLote = document.getElementById('compraLote')?.value.trim() || folio || 'LOTE-COMPRA';

            if (!nombreInsumo || cantidad <= 0 || !unidadMedidaId) {
                alert("Debe ingresar el nombre del insumo, seleccionar la unidad de medida y una cantidad válida (mayor a 0), o bien usar el botón 'Agregar Partida' para acumular varias.");
                return;
            }

            // Aplicar el tipo de cambio manual si es USD al costo unitario base
            costoUnitario = costoUnitario * tipoCambio;

            const uMatch = catalogoUnidadesCache.find(u => u.id === unidadMedidaId);
            partidasAProcesar.push({
                nombreInsumo,
                cantidad,
                costoUnitario,
                unidadMedidaId,
                unidadNombre: uMatch ? uMatch.nombre : 'N/A',
                numeroLote
            });
        } else {
            // Si hay partidas acumuladas, aplicar el factor de tipo de cambio manual si se seleccionó USD
            if (monedaCodigo === 'USD' && tipoCambio > 1.0) {
                partidasAProcesar = partidasAProcesar.map(p => ({
                    ...p,
                    costoUnitario: p.costoUnitario * tipoCambio
                }));
            }
        }

        if (!confirm(`¿Confirma el registro de la compra (${folio || 'Sin Factura'}) con ${partidasAProcesar.length} partida(s)?`)) {
            return;
        }

        try {
            const { data: monedaData, error: errMoneda } = await supabaseClient
                .from('monedas')
                .select('id')
                .eq('codigo', monedaCodigo)
                .single();

            if (errMoneda) throw errMoneda;

            const { data: documento, error: errDoc } = await supabaseClient
                .from('documentos')
                .insert([{
                    tipo_movimiento: 'entrada_compra',
                    folio: folio,
                    proveedor_id: proveedorId,
                    fecha_emision: fecha,
                    notas: notas,
                    estado: 'completado'
                }])
                .select('id')
                .single();

            if (errDoc) throw errDoc;
            const documentoId = documento.id;

            for (const partida of partidasAProcesar) {
                let { data: productoExistente, error: errProdBusq } = await supabaseClient
                    .from('productos')
                    .select('id')
                    .ilike('nombre', partida.nombreInsumo)
                    .maybeSingle();

                if (errProdBusq) throw errProdBusq;

                let productoId;
                if (productoExistente) {
                    productoId = productoExistente.id;
                    await supabaseClient
                        .from('productos')
                        .update({ 
                            costo_unitario: partida.costoUnitario, 
                            proveedor_id: proveedorId,
                            unidad_medida_id: partida.unidadMedidaId 
                        })
                        .eq('id', productoId);
                } else {
                    const { data: nuevoProd, error: errInsProd } = await supabaseClient
                        .from('productos')
                        .insert([{
                            nombre: partida.nombreInsumo,
                            costo_unitario: partida.costoUnitario,
                            proveedor_id: proveedorId,
                            unidad_medida_id: partida.unidadMedidaId,
                            tipo: 'materia_prima',
                            stock_actual: 0
                        }])
                        .select('id')
                        .single();

                    if (errInsProd) throw errInsProd;
                    productoId = nuevoProd.id;
                }

                const subtotal = partida.cantidad * partida.costoUnitario;
                const { error: errDetalle } = await supabaseClient
                    .from('documento_detalles')
                    .insert([{
                        documento_id: documentoId,
                        producto_id: productoId,
                        cantidad: partida.cantidad,
                        costo_unitario: partida.costoUnitario,
                        subtotal: subtotal
                    }]);

                if (errDetalle) throw errDetalle;

                const { error: errRpc } = await supabaseClient.rpc('registrar_movimiento_inventario_fifo', {
                    p_producto_id: productoId,
                    p_cantidad: partida.cantidad,
                    p_tipo_movimiento: 'entrada',
                    p_documento_id: documentoId,
                    p_costo_unitario: partida.costoUnitario,
                    p_numero_lote: partida.numeroLote || 'LOTE-COMPRA'
                });

                if (errRpc) throw errRpc;
            }

            // ---- Contabilizar (genera poliza de Egreso) si el bloque fiscal esta activo ----
            let msgContab = '';
            const chkContab = document.getElementById('compraContabilizar');
            const bloqueVisible = document.getElementById('bloqueFiscalCompra') && !document.getElementById('bloqueFiscalCompra').classList.contains('hidden');
            if (bloqueVisible && chkContab && chkContab.checked) {
                const nf = (id) => parseFloat(document.getElementById(id)?.value) || 0;
                const condicion = document.getElementById('compraCondicion').value;
                let subtotalFiscal = nf('compraSubtotal');
                if (subtotalFiscal <= 0) {
                    subtotalFiscal = partidasAProcesar.reduce((a, p) => a + (p.cantidad * p.costoUnitario), 0);
                }
                const p_datos = {
                    subtotal: subtotalFiscal,
                    iva: nf('compraIva'),
                    ieps: nf('compraIeps'),
                    ret_iva: nf('compraRetIva'),
                    ret_isr: nf('compraRetIsr'),
                    condicion,
                    forma_pago: document.getElementById('compraFormaPago').value || null,
                    cuenta_pago_id: condicion === 'contado' && document.getElementById('compraCuentaPago').value
                        ? parseInt(document.getElementById('compraCuentaPago').value) : null,
                    uuid_cfdi: document.getElementById('compraUuid').value.trim() || null,
                    rfc_emisor: document.getElementById('compraRfc').value.trim() || null,
                };
                try {
                    const { data: cont, error: errCont } = await supabaseClient.rpc('contabilizar_compra', {
                        p_documento_id: documentoId, p_datos
                    });
                    if (errCont) throw errCont;
                    msgContab = `\nPóliza de Egreso generada (total $${Number(cont.total).toFixed(2)}).`;
                } catch (e) {
                    msgContab = `\nLa compra se registró, pero NO se pudo contabilizar: ${e.message || e}`;
                }
            }

            alert("¡Compra registrada correctamente!" + msgContab);
            formCompra.reset();
            listaPartidasCompra = [];
            actualizarTablaPartidasUI();
            ivaFiscalEditadoManualmente = false;
            actualizarSubtotalFiscalAuto();

            if (inputFecha) {
                inputFecha.value = new Date().toISOString().split('T')[0];
            }

            if (typeof cargarInventarioCompleto === 'function') {
                await cargarInventarioCompleto();
            }

        } catch (error) {
            console.error("Error al registrar la compra:", error);
            alert("Error al procesar la compra: " + error.message);
        }
    };
}

// --------- Bloque fiscal / contabilidad de la compra ---------

function recalcularTotalFiscalCompra() {
    const n = (id) => parseFloat(document.getElementById(id)?.value) || 0;
    const total = n('compraSubtotal') + n('compraIva') + n('compraIeps') - n('compraRetIva') - n('compraRetIsr');
    const el = document.getElementById('compraTotalFiscal');
    if (el) el.value = '$' + total.toLocaleString('es-MX', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
}

function subtotalPartidasCompra() {
    if (listaPartidasCompra.length > 0) {
        return listaPartidasCompra.reduce((a, p) => a + (p.cantidad * p.costoUnitario), 0);
    }
    const cant = parseFloat(document.getElementById('compraCantidad')?.value) || 0;
    const cu = parseFloat(document.getElementById('compraCostUnitario')?.value) || 0;
    return cant * cu;
}

// Recalcula Subtotal (y, si no fue editado a mano, el IVA al 16%) cada vez que
// cambian las partidas de la compra. No hace nada si el bloque fiscal no está
// visible (módulo de contabilidad no instalado).
function actualizarSubtotalFiscalAuto() {
    const elSubtotal = document.getElementById('compraSubtotal');
    if (!elSubtotal) return;
    elSubtotal.value = subtotalPartidasCompra().toFixed(2);
    if (!ivaFiscalEditadoManualmente) {
        const elIva = document.getElementById('compraIva');
        if (elIva) elIva.value = (Math.round(parseFloat(elSubtotal.value) * 16) / 100).toFixed(2);
    }
    recalcularTotalFiscalCompra();
}

async function cargarBloqueFiscalCompra() {
    const bloque = document.getElementById('bloqueFiscalCompra');
    if (!bloque) return;

    let cuentasPago = [];
    try {
        const { data, error } = await supabaseClient
            .from('cuentas_contables')
            .select('id, codigo, nombre')
            .eq('afectable', true).eq('activa', true)
            .order('codigo', { ascending: true });
        if (error) throw error;
        cuentasPago = (data || []).filter((c) => /^(101|102)/.test(c.codigo));
    } catch (_) {
        // modulo de contabilidad no instalado -> se deja el bloque oculto
        return;
    }

    bloque.classList.remove('hidden');
    const selPago = document.getElementById('compraCuentaPago');
    selPago.innerHTML = '<option value="">— caja / banco —</option>' +
        cuentasPago.map((c) => `<option value="${c.id}">${c.codigo} · ${c.nombre}</option>`).join('');

    const $ = (id) => document.getElementById(id);
    ivaFiscalEditadoManualmente = false;
    actualizarSubtotalFiscalAuto();

    $('compraSubtotalAuto').addEventListener('click', actualizarSubtotalFiscalAuto);
    $('compraIva16').addEventListener('click', () => {
        ivaFiscalEditadoManualmente = false;
        $('compraIva').value = (Math.round((parseFloat($('compraSubtotal').value) || 0) * 16) / 100).toFixed(2);
        recalcularTotalFiscalCompra();
    });
    $('compraIva').addEventListener('input', () => { ivaFiscalEditadoManualmente = true; });
    ['compraSubtotal', 'compraIva', 'compraIeps', 'compraRetIva', 'compraRetIsr'].forEach((id) =>
        $(id).addEventListener('input', recalcularTotalFiscalCompra));
    $('compraCondicion').addEventListener('change', () => {
        $('compraPagoWrap').classList.toggle('hidden', $('compraCondicion').value !== 'contado');
    });
    $('compraContabilizar').addEventListener('change', () => {
        $('camposFiscalesCompra').style.display = $('compraContabilizar').checked ? '' : 'none';
    });
}

async function cargarProveedoresSelect() {
    try {
        const { data, error } = await supabaseClient
            .from('proveedores')
            .select('id, nombre')
            .order('nombre', { ascending: true });

        if (error) throw error;
        catalogoProveedoresCache = data || [];

        const selectProveedor = document.getElementById('compraProveedorId');
        if (!selectProveedor) return;

        let html = '<option value="">Seleccione proveedor...</option>';
        catalogoProveedoresCache.forEach(prov => {
            html += `<option value="${prov.id}">${prov.nombre}</option>`;
        });
        selectProveedor.innerHTML = html;
    } catch (err) {
        console.warn("Aviso al cargar proveedores:", err);
    }
}

async function cargarUnidadesMedidaSelect() {
    try {
        const { data, error } = await supabaseClient
            .from('unidades_medida')
            .select('id, nombre')
            .order('nombre', { ascending: true });

        if (error) throw error;
        catalogoUnidadesCache = data || [];

        const selectUnidad = document.getElementById('compraUnidadMedida');
        if (!selectUnidad) return;

        let html = '<option value="">Seleccione unidad...</option>';
        catalogoUnidadesCache.forEach(um => {
            html += `<option value="${um.id}">${um.nombre}</option>`;
        });
        selectUnidad.innerHTML = html;
    } catch (err) {
        console.warn("Aviso al cargar unidades de medida:", err);
    }
}

async function precargarProductosParaBusqueda() {
    try {
        const { data, error } = await supabaseClient
            .from('productos')
            .select(`
                id,
                nombre,
                proveedor_id,
                costo_unitario,
                unidad_medida_id,
                unidades_medida!unidad_medida_id (
                    id,
                    nombre
                )
            `)
            .order('nombre', { ascending: true });

        if (error) throw error;
        catalogoProductosCache = data || [];
    } catch (err) {
        console.warn("Aviso al cargar catálogo de productos para AJAX:", err);
    }
}

window.seleccionarInsumoAutocomplete = function(prodEncoded) {
    try {
        const prod = JSON.parse(decodeURIComponent(prodEncoded));
        
        const inputInsumo = document.getElementById('compraInsumoNombre');
        if (inputInsumo) inputInsumo.value = prod.nombre;

        const contenedorSugerencias = document.getElementById('sugerenciasInsumosCompra');
        if (contenedorSugerencias) contenedorSugerencias.classList.add('hidden');

        if (prod.proveedor_id) {
            const selectProv = document.getElementById('compraProveedorId');
            if (selectProv) selectProv.value = prod.proveedor_id;
        }

        if (prod.costo_unitario !== undefined && prod.costo_unitario !== null) {
            const inputCosto = document.getElementById('compraCostUnitario');
            if (inputCosto) inputCosto.value = prod.costo_unitario;
        }

        if (prod.unidad_medida_id) {
            const selectUnidad = document.getElementById('compraUnidadMedida');
            if (selectUnidad) {
                selectUnidad.value = prod.unidad_medida_id;
            }
        }
    } catch (e) {
        console.error("Error al seleccionar insumo autocompletado:", e);
    }
};

function agregarPartidaTemporal() {
    const nombreInsumo = document.getElementById('compraInsumoNombre')?.value.trim() || '';
    const cantidad = parseFloat(document.getElementById('compraCantidad')?.value) || 0;
    const costoUnitario = parseFloat(document.getElementById('compraCostUnitario')?.value) || 0;
    const unidadMedidaId = document.getElementById('compraUnidadMedida')?.value ? parseInt(document.getElementById('compraUnidadMedida').value) : null;
    const folio = document.getElementById('compraFactura')?.value.trim() || '';
    const numeroLote = document.getElementById('compraLote')?.value.trim() || folio || 'LOTE-COMPRA';

    if (!nombreInsumo || !unidadMedidaId || cantidad <= 0) {
        alert("Para agregar la partida, asegúrese de ingresar el nombre del insumo, seleccionar una unidad de medida y una cantidad mayor a 0.");
        return;
    }

    const uMatch = catalogoUnidadesCache.find(u => u.id === unidadMedidaId);
    const unidadNombre = uMatch ? uMatch.nombre : 'N/A';

    listaPartidasCompra.push({
        nombreInsumo,
        cantidad,
        costoUnitario,
        unidadMedidaId,
        unidadNombre,
        numeroLote
    });

    actualizarTablaPartidasUI();
    actualizarSubtotalFiscalAuto();

    document.getElementById('compraInsumoNombre').value = '';
    document.getElementById('compraCantidad').value = '';
    document.getElementById('compraCostUnitario').value = '';
    document.getElementById('compraLote').value = '';
    document.getElementById('compraUnidadMedida').value = '';
    document.getElementById('compraInsumoNombre').focus();
}

function actualizarTablaPartidasUI() {
    const contenedorTabla = document.getElementById('tablaPartidasCompraBody');
    if (!contenedorTabla) return;

    if (listaPartidasCompra.length === 0) {
        contenedorTabla.innerHTML = `<tr><td colspan="6" class="p-4 text-center text-slate-500">No hay partidas agregadas todavía.</td></tr>`;
        return;
    }

    let html = '';
    listaPartidasCompra.forEach((p, index) => {
        html += `
            <tr class="border-b border-slate-900 hover:bg-slate-900/50 transition">
                <td class="p-3 font-medium text-slate-100">${p.nombreInsumo}</td>
                <td class="p-3 text-slate-300">${p.cantidad}</td>
                <td class="p-3 text-slate-400 text-xs">${p.unidadNombre}</td>
                <td class="p-3 text-emerald-400 font-mono">$${p.costoUnitario.toFixed(2)}</td>
                <td class="p-3 font-mono text-xs text-emerald-300">${p.numeroLote}</td>
                <td class="p-3 text-center">
                    <button type="button" onclick="window.eliminarPartidaCompra(${index})" class="text-red-400 hover:text-red-300 font-bold px-2 py-1 rounded bg-red-950 border border-red-900 text-xs" style="cursor: pointer;">✕</button>
                </td>
            </tr>
        `;
    });
    contenedorTabla.innerHTML = html;
}

window.eliminarPartidaCompra = function(index) {
    listaPartidasCompra.splice(index, 1);
    actualizarTablaPartidasUI();
    actualizarSubtotalFiscalAuto();
};

export function toggleTipoCambio() {
    const monedaSelect = document.getElementById('compraMoneda');
    const contenedorTC = document.getElementById('contenedorTipoCambio');
    if (monedaSelect && contenedorTC) {
        contenedorTC.style.display = (monedaSelect.value === 'USD') ? 'block' : 'none';
    }
}