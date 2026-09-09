// =====================================================================
// Lector de CFDI (XML) — extrae encabezado, impuestos y conceptos.
// Compatible con CFDI 3.3 y 4.0 (se navega por localName, sin namespaces).
// =====================================================================

export function parsearCfdi(text) {
    let dom;
    try {
        dom = new DOMParser().parseFromString(text, 'application/xml');
        if (dom.getElementsByTagName('parsererror').length) throw new Error('XML mal formado');
    } catch (e) {
        return { error: 'No se pudo leer el XML: ' + (e.message || e) };
    }

    const all = [...dom.getElementsByTagName('*')];
    const byLocal = (name) => all.filter((el) => el.localName === name);
    const comp = byLocal('Comprobante')[0];
    if (!comp) return { error: 'El archivo no parece un CFDI (falta el nodo Comprobante).' };

    const A = (el, n) => (el && el.getAttribute(n)) || '';
    const toNum = (v) => { const x = parseFloat(v); return Number.isFinite(x) ? x : 0; };
    const r2 = (n) => Math.round((Number(n) || 0) * 100) / 100;

    let iva = 0, ieps = 0, retIva = 0, retIsr = 0;
    const impComp = [...comp.children].find((c) => c.localName === 'Impuestos');
    if (impComp) {
        [...impComp.getElementsByTagName('*')].forEach((nodo) => {
            const v = toNum(A(nodo, 'Importe'));
            if (nodo.localName === 'Traslado') {
                if (A(nodo, 'Impuesto') === '002') iva += v;
                else if (A(nodo, 'Impuesto') === '003') ieps += v;
            } else if (nodo.localName === 'Retencion') {
                if (A(nodo, 'Impuesto') === '002') retIva += v;
                else if (A(nodo, 'Impuesto') === '001') retIsr += v;
            }
        });
    }

    const emisor = byLocal('Emisor')[0];

    return {
        fecha: A(comp, 'Fecha').slice(0, 10),
        folio: [A(comp, 'Serie'), A(comp, 'Folio')].filter(Boolean).join('-'),
        subtotal: r2(toNum(A(comp, 'SubTotal'))),
        descuento: r2(toNum(A(comp, 'Descuento'))),
        total: r2(toNum(A(comp, 'Total'))),
        iva: r2(iva), ieps: r2(ieps), retIva: r2(retIva), retIsr: r2(retIsr),
        moneda: (A(comp, 'Moneda') || 'MXN').toUpperCase(),
        tipoCambio: toNum(A(comp, 'TipoCambio')) || 1,
        formaPago: A(comp, 'FormaPago'),
        metodoPago: A(comp, 'MetodoPago'),
        tipoComprobante: A(comp, 'TipoDeComprobante'),
        lugarExpedicion: A(comp, 'LugarExpedicion'),
        rfcEmisor: A(emisor, 'Rfc').toUpperCase(),
        nombreEmisor: A(emisor, 'Nombre'),
        regimenEmisor: A(emisor, 'RegimenFiscal'),
        usoCfdi: A(byLocal('Receptor')[0], 'UsoCFDI'),
        uuid: A(byLocal('TimbreFiscalDigital')[0], 'UUID'),
        conceptos: byLocal('Concepto').map((c) => ({
            claveSat: A(c, 'ClaveProdServ').trim(),
            noId: A(c, 'NoIdentificacion').trim(),
            cantidad: toNum(A(c, 'Cantidad')),
            valorUnitario: toNum(A(c, 'ValorUnitario')),
            importe: toNum(A(c, 'Importe')),
            descripcion: A(c, 'Descripcion'),
        })),
    };
}

// c_forma_pago del SAT -> lista simple (efectivo / transferencia / tarjeta / cheque)
export function formaPagoSimple(clave) {
    return ({ '01': 'efectivo', '02': 'cheque', '03': 'transferencia', '04': 'tarjeta', '28': 'tarjeta' }[clave]) || '';
}
