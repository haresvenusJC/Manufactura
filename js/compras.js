import { supabaseClient } from './supabase.js';
import { cargarInventarioCompleto } from './inventario.js';

export function toggleTipoCambio(selectId, contenedorId, inputId) {
    const select = document.getElementById(selectId);
    const contenedor = document.getElementById(contenedorId);
    const input = document.getElementById(inputId);
    
    if (select && contenedor) {
        if (select.value === 'USD') {
            contenedor.classList.remove('hidden');
            if (input) input.required = true;
        } else {
            contenedor.classList.add('hidden');
            if (input) {
                input.required = false;
                input.value = '';
            }
        }
    }
}

export function configurarFormularioCompras() {
    const formCompras = document.getElementById('formCompras');
    if (!formCompras) return;

    formCompras.addEventListener('submit', async (e) => {
        e.preventDefault();
        
        const fecha = document.getElementById('compraFecha').value;
        const factura = document.getElementById('compraFactura').value;
        const nombreInsumo = document.getElementById('compraNombre').value.trim();
        const proveedor = document.getElementById('compraProveedor').value;
        const unidad = document.getElementById('compraUnidad').value;
        const moneda = document.getElementById('compraMoneda').value;
        const tipoCambio = moneda === 'USD' ? parseFloat(document.getElementById('compraTipoCambio').value) || 1 : 1;
        const costoUnitario = parseFloat(document.getElementById('compraCosto').value) || 0;
        const cantidad = parseFloat(document.getElementById('compraCantidad').value) || 0;

        try {
            let { data: existente, error: errBusqueda } = await supabaseClient
                .from('materias_primas')
                .select('id, stock_actual')
                .ilike('nombre', nombreInsumo)
                .maybeSingle();

            if (errBusqueda) throw errBusqueda;

            let materiaPrimaId;

            if (existente) {
                materiaPrimaId = existente.id;
                const nuevoStock = Number(existente.stock_actual || 0) + cantidad;
                
                const { error: errUpdate } = await supabaseClient
                    .from('materias_primas')
                    .update({ stock_actual: nuevoStock, costo_unitario: costoUnitario, proveedor: proveedor, moneda: moneda, tipo_cambio: tipoCambio })
                    .eq('id', materiaPrimaId);

                if (errUpdate) throw errUpdate;
            } else {
                const { data: nuevaMat, error: errInsert } = await supabaseClient
                    .from('materias_primas')
                    .insert([{
                        nombre: nombreInsumo,
                        unidad_medida: unidad,
                        stock_actual: cantidad,
                        costo_unitario: costoUnitario,
                        proveedor: proveedor,
                        moneda: moneda,
                        tipo_cambio: tipoCambio
                    }])
                    .select('id')
                    .single();

                if (errInsert) throw errInsert;
                materiaPrimaId = nuevaMat.id;
            }

            const { error: errLote } = await supabaseClient
                .from('lotes_materias_primas')
                .insert([{
                    materia_prima_id: materiaPrimaId,
                    numero_lote: factura,
                    stock_actual: cantidad,
                    costo_unitario: costoUnitario,
                    moneda: moneda,
                    tipo_cambio: tipoCambio,
                    fecha_ingreso: fecha
                }]);

            if (errLote) throw errLote;

            alert("¡Compra y lote registrados exitosamente, mi lord!");
            formCompras.reset();
            cargarInventarioCompleto();

        } catch (error) {
            console.error("Error al registrar compra:", error);
            alert("Error al procesar el registro de compra.");
        }
    });
}